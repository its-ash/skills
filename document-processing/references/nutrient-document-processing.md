@REF:nutrient-document-processing
§API{
  url:https://www.nutrient.io/api/|signup:https://dashboard.nutrient.io/sign_up/?product=processor;
  compliance:commercial→review_terms;¬send(PHI|regulated_data)_unless_policy∧BAA_permit(else⇒references/local-document-pipelines.md);
  auth:`export NUTRIENT_API_KEY="pdf_live_..."`;
  build_req:POST_multipart `https://api.nutrient.io/build` `--fail` `-H "Authorization: Bearer $NUTRIENT_API_KEY"` `-F "document=@<file>"` `-F 'instructions=<JSON>'` `-o <out>`(`parts[].file`≡multipart_field_name);
  sign_req:POST_multipart `https://api.nutrient.io/sign` `--fail` `-H "Authorization: Bearer $NUTRIENT_API_KEY"` `-F "file=@<file>"` `-F 'data=<JSON>'` `-o <out>`;
  py_sdk:`nutrient-dws`(`NutrientClient`, `BuildInstructions`);
  in:[PDF,DOCX,XLSX,PPTX,DOC,XLS,PPT,PPS,PPSX,ODT,RTF,HTML,JPG,PNG,TIFF,HEIC,GIF,WebP,SVG,TGA,EPS]
}

§PAT[build_instructions]{
  convert:{
    docx→pdf:`{"parts":[{"file":"document"}]}`,
    pdf→docx:`{"parts":[{"file":"document"}],"output":{"type":"docx"}}`,
    html→pdf:`{"parts":[{"html":"index"}]}`,
    pdf→pdfa:`{"parts":[{"file":"document"}],"output":{"type":"pdfa","conformance":"pdfa-2a"}}`
  };
  extract:{
    markdown_rag:`{"parts":[{"file":"document"}],"output":{"type":"markdown"}}`,
    json_content:`{"parts":[{"file":"document"}],"output":{"type":"json-content"}}`,
    text:`{"parts":[{"file":"document"}],"output":{"type":"text"}}`,
    xlsx:`{"parts":[{"file":"document"}],"output":{"type":"xlsx"}}`
  };
  ocr:{
    json:`{"parts":[{"file":"document"}],"actions":[{"type":"ocr","language":"eng"}]}`,
    note:prepend_pre_extract|redact_on_scans;langs:80+_ISO639-2(`eng`,`deu`,`fra`,`spa`,`jpn`,`kor`,`chi_sim`,`chi_tra`,`ara`,`hin`,`rus`)|full_name;py_sdk_uses_`languages:["eng"]`
  };
  redact_2step:{
    rule:ALWAYS_chain_`createRedactions`→`applyRedactions`(omitting_`applyRedactions`_leaves_removable_annotations∧unredacted_text);
    preset:`{"parts":[{"file":"document"}],"actions":[{"type":"createRedactions","strategy":"preset","strategyOptions":{"preset":"social-security-number"}},{"type":"createRedactions","strategy":"preset","strategyOptions":{"preset":"email-address"}},{"type":"applyRedactions"}]}`,
    regex:`{"parts":[{"file":"document"}],"actions":[{"type":"createRedactions","strategy":"regex","strategyOptions":{"regex":"\\b[A-Z]{2}\\d{6}\\b"}},{"type":"applyRedactions"}]}`,
    strategies:[`preset`,`regex`,`text`],
    presets:[`social-security-number`,`email-address`,`credit-card-number`,`international-phone-number`,`north-american-phone-number`,`date`,`time`,`url`,`ipv4`,`ipv6`,`mac-address`,`us-zip-code`,`vin`]
  };
  watermark:`{"parts":[{"file":"document"}],"actions":[{"type":"watermark","text":"CONFIDENTIAL","fontSize":72,"opacity":0.3,"rotation":-45}]}`;
  forms:{
    instant_json:`{"parts":[{"file":"document"}],"actions":[{"type":"applyInstantJson","file":"form_data"},{"type":"flatten"}]}`(attach_`-F "form_data=@form_data.json"`),
    fill_form:`{"parts":[{"file":"document"}],"actions":[{"type":"fillForm","formFields":{"name":"Jane Smith","email":"jane@example.com"}},{"type":"flatten"}]}`
  }
}

§PAT[sign_endpoint]{
  endpoint:`POST https://api.nutrient.io/sign`;
  rule:run_all_edits|fill|redact|flatten_via_`/build`_FIRST→sign_LAST_via_`/sign`;
  pades_ltv:`{"signatureType":"cades","cadesLevel":"b-lt","signatureMetadata":{"signerName":"Jane Doe","signatureReason":"Approval","signatureLocation":"New York"}}`(LTV=timestamps+revocation_data_for_post_expiry_verify);
  types:[`cades`(PAdES_compliant;`b-b`,`b-t`,`b-lt`,`b-lta`),`cms`]
}

§CFG[mcp]{
  hosted_current:`https://mcp.nutrient.io/mcp`(Streamable_HTTP+browser_OAuth;¬local_npm_install∧¬hardcoded_API_keys);
  claude_code:`claude mcp add --transport http --scope user nutrient https://mcp.nutrient.io/mcp`→`/mcp`→`Authenticate`;
  codex:`codex mcp add nutrient --url https://mcp.nutrient.io/mcp && codex mcp login nutrient`;
  other_clients:add_`https://mcp.nutrient.io/mcp`_as_remote_HTTP_MCP_server;
  deprecated:¬use_`@nutrient-sdk/dws-mcp-server`(unsupported_legacy_local_pkg)
}

§ANTI{
  ¬use_deprecated_`@nutrient-sdk/dws-mcp-server`;
  ¬run_`createRedactions`_without_`applyRedactions`;
  ¬omit_`curl --fail`(HTTP_4xx/5xx_error_JSON_corrupts_output_file);
  ¬sign_before_form_fill|redact|flatten;
  ¬send_PHI|unapproved_PII→cloud_API
}

§REL{
  playground:https://dashboard.nutrient.io/processor-api/playground/,
  docs:https://www.nutrient.io/guides/dws-processor/,
  ocr_langs:https://www.nutrient.io/guides/document-engine/ocr/language-support/,
  mcp:https://mcp.nutrient.io/mcp
}
