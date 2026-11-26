@REF:nutrient-document-processing
§API{
  url:https://www.nutrient.io/api/|signup:https://dashboard.nutrient.io/sign_up/?product=processor;
  compliance:commercial→review_terms;¬send(PHI|regulated_data)_unless_permitted;
  auth:`export NUTRIENT_API_KEY="pdf_live_..."`;
  req:POST_multipart `https://api.nutrient.io/build` `-H "Authorization: Bearer $NUTRIENT_API_KEY"` `-F "<k>=@<file>"` `-F 'instructions=<JSON>'` `-o <out>`;
  in:[PDF,DOCX,XLSX,PPTX,DOC,XLS,PPT,PPS,PPSX,ODT,RTF,HTML,JPG,PNG,TIFF,HEIC,GIF,WebP,SVG,TGA,EPS]
}
§PAT[instructions]{
  convert:{
    docx→pdf:`{"parts":[{"file":"document.docx"}]}`,
    pdf→docx:`{"parts":[{"file":"document.pdf"}],"output":{"type":"docx"}}`,
    html→pdf:`{"parts":[{"html":"index.html"}]}`
  };
  extract:{text:`{"parts":[{"file":"document.pdf"}],"output":{"type":"text"}}`,xlsx:`{"parts":[{"file":"document.pdf"}],"output":{"type":"xlsx"}}`};
  ocr:{json:`{"parts":[{"file":"scanned.pdf"}],"actions":[{"type":"ocr","language":"english"}]}`,langs:100+_ISO639-2(`eng`,`deu`,`fra`,`spa`,`jpn`,`kor`,`chi_sim`,`chi_tra`,`ara`,`hin`,`rus`)|full_name(`english`,`german`),ref:https://www.nutrient.io/guides/document-engine/ocr/language-support/};
  redact:{
    preset:`{"parts":[{"file":"document.pdf"}],"actions":[{"type":"redaction","strategy":"preset","strategyOptions":{"preset":"social-security-number"}},{"type":"redaction","strategy":"preset","strategyOptions":{"preset":"email-address"}}]}`,
    regex:`{"parts":[{"file":"document.pdf"}],"actions":[{"type":"redaction","strategy":"regex","strategyOptions":{"regex":"\\b[A-Z]{2}\\d{6}\\b"}}]}`,
    presets:[`social-security-number`,`email-address`,`credit-card-number`,`international-phone-number`,`north-american-phone-number`,`date`,`time`,`url`,`ipv4`,`ipv6`,`mac-address`,`us-zip-code`,`vin`]
  };
  watermark:`{"parts":[{"file":"document.pdf"}],"actions":[{"type":"watermark","text":"CONFIDENTIAL","fontSize":72,"opacity":0.3,"rotation":-45}]}`;
  sign:`{"parts":[{"file":"document.pdf"}],"actions":[{"type":"sign","signatureType":"cms"}]}`;
  fillForm:`{"parts":[{"file":"form.pdf"}],"actions":[{"type":"fillForm","formFields":{"name":"Jane Smith","email":"jane@example.com","date":"2026-02-06"}}]}`
}
§CFG[mcp]{
  rule:pin_version∧env_key(¬commit);
  `mcpServers.nutrient-dws`:`{"command":"npx","args":["-y","@nutrient-sdk/dws-mcp-server@<pinned-version>"],"env":{"NUTRIENT_DWS_API_KEY":"${NUTRIENT_API_KEY}","SANDBOX_PATH":"/path/to/working/directory"}}`
}
§REL{playground:https://dashboard.nutrient.io/processor-api/playground/,docs:https://www.nutrient.io/guides/dws-processor/,npm:https://www.npmjs.com/package/@nutrient-sdk/dws-mcp-server}
