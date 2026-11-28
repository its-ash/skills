@REF:local-document-pipelines
§SCOPE{
  use:local|offline|PII|PHI|airgapped_doc_processing(extract,RAG_markdown,redact,generate,convert,OCR,sign,archive)∧zero_3p_upload;
  licenses:{permissive(MIT|BSD|Apache|MPL):[docling,pypdf,pdfplumber,markitdown,weasyprint,typst,reportlab,pyhanko,pikepdf,qpdf,python-docx,openpyxl,python-pptx,paddleocr,tesseract],copyleft(AGPL-3.0_or_commercial):[pymupdf]}
}

§PAT[extract_rag]{
  fast_cpu_pdf→md_json:pymupdf>=2.0(`import pymupdf` ¬`import fitz`;`pymupdf4llm`∧`pymupdf-layout`_merged→core;methods:`doc.to_markdown()`,`doc.to_json()`,`doc.to_text()`,`use_layout()`);
  complex_layout_tables_multimodal:docling>=2.x(MIT;PDF|DOCX|PPTX|HTML|imgs→Markdown|JSON|DocTags;reading_order+table_struct+pluggable_OCR;heavier_PyTorch|ONNX_footprint);
  lightweight_multiformat→md:markitdown(MIT;PDF|Office|HTML|imgs→Markdown_for_LLMs);
  precision_born_digital_tables:pdfplumber>=0.11(MIT,`pdfminer.six`;char_bboxes+grid_tables→DataFrame;¬native_OCR);
  pure_py_pdf_ops:pypdf>=7.1(BSD-3,Py>=3.10;merge,split,rotate,crop,metadata,basic_text|forms;¬heavy_bins)
}

§PAT[redact_scrub]{
  rule:true_content_removal∧metadata_scrub∧history_flatten(¬black_rect_overlay∧¬white_text);
  pymupdf_flow:`doc=pymupdf.open(src)`→∀page:`page.add_redact_annot(rect,fill=(0,0,0))`→`page.apply_redactions()`→`doc.scrub(metadata=True,xml_metadata=True,attached_files=True,embedded_files=True,thumbnails=True,reset_fields=True)`→`doc.save(out,garbage=4,deflate=True,clean=True)`;
  qpdf_rewrite:`qpdf --linearize --object-streams=disable in.pdf sanitized.pdf`(eliminates_incremental_updates∧unpacks_`/ObjStm`_for_audit;Py_binding:`pikepdf`);
  audit_surfaces:[content_stream,Info_dict,XMP_streams,incremental_updates,bookmarks_outlines,annotations_comments,form_fields,links,embedded_attachments,image_EXIF,`/StructTreeRoot`_tags];
  verify_post:re_extract(text+metadata+outlines+annots+raw_uncompressed_streams)→fail_if(redacted_token∈any_surface)
}

§PAT[generate_convert]{
  html_css→pdf:weasyprint>=68(BSD-3;HTML5+CSS3_grid|flex|paged_media|SVG→print_PDF) ⊕ Playwright_Chromium_headless(when_JS_charts|complex_web_layout_req);
  structured_typesetting:typst(Apache-2.0;CLI|`typst`_Py_binding;fast_incremental_compiler≻LaTeX_for_reports|manuals|invoices);
  low_level_canvas:reportlab(BSD;exact_coords|charts;req_register_Unicode|CJK_TTFont|CIDFont_for_non_Latin);
  office_edit:{DOCX:`python-docx`,XLSX:`openpyxl`,PPTX:`python-pptx`};
  office→pdf_cli:`soffice --headless -env:UserInstallation=file:///tmp/lo_profile_$$ --convert-to pdf --outdir <dir> <src>`(unique_profile_prevents_concurrent_lock_crash)
}

§PAT[ocr_local]{
  heic_heif_avif:`from pillow_heif import register_heif_opener; register_heif_opener()`→`PIL.ImageOps.exif_transpose(Image.open(p))`(cross_platform);
  macos_native:Apple_Vision(`pyobjc-framework-Vision` `VNRecognizeTextRequest` w/ `VNRequestTextRecognitionLevelAccurate`∧`usesLanguageCorrection=True`∧`recognitionLanguages`,⊕ `ocrmac`|`ocrmypdf-appleocr`;Neural_Engine,zero_weights);
  cross_platform_complex:paddleocr>=3.x(`PP-OCRv5`+`PP-StructureV3`+`PaddleOCR-VL`;multilingual,tables,handwriting,stamps);
  cross_platform_light:tesseract>=5.5(`pytesseract`,⊕ `ocrmypdf`→searchable_PDF/A)
}

§PAT[sign_standards]{
  local_pades:pyhanko>=0.38(MIT,Py>=3.11;PAdES-B-B|B-T|B-LT|B-LTA,TSA_timestamps,OCSP/CRL_LTV,sig_verification);
  lifecycle_order:`modify|fill → redact+scrub+qpdf → flatten → validate(PDF/A-4|PDF/UA-2) → sign_LAST`;
  sig_invalidation:∀byte_mutation_post_sign⇒breaks_crypto_sig(re_redact⇒archive_signed_orig→redact_base→new_sig);
  standards:{archive:`PDF/A-4(ISO 19005-4)`∨`PDF/A-2b`,a11y:`PDF/UA-2(ISO 14289-2)`(sync_or_purge_orphan_`/StructTreeRoot`_post_redaction),e_sig:`eIDAS_2.0/PAdES(EU)`∧`ESIGN/UETA(US)`}
}

§ANTI{
  ¬`import fitz`(deprecated→`import pymupdf`);
  ¬separate_`pymupdf4llm`_install_on_pymupdf>=2.0(stub_only;merged→core);
  ¬ship_AGPL_`pymupdf`_in_closed_source_without_commercial_license;
  ¬black_box_overlay∨save_incremental_post_redaction(recoverable_text|history);
  ¬share_default_LibreOffice_profile_across_parallel_headless_jobs;
  ¬modify_or_redact_after_PAdES_signing
}

§CHK{
  □ license_compatible(AGPL_vs_MIT|BSD|Apache);
  □ PII|PHI_kept_local∧temp_files_wiped;
  □ redaction_verified_zero_leaks(text+XMP+outlines+attachments+linearized_streams);
  □ non_Latin_fonts_embedded∧no_tofu_glyphs;
  □ PDF/A_or_PDF/UA_validated_pre_sign∧PAdES_signed_last
}
