@REF:visa-doc-translate
§SCOPE{
  in:image(HEIC|HEIF|PNG|JPG|WEBP);
  out:`<original_filename>_Translated.pdf`@(same_dir,A4_bilingual);
  docs:[bank_deposit(`存款证明`),income(`收入证明`),employment(`在职证明`),retirement(`退休证明`),property(`房产证明`),business_license(`营业执照`),ID_cards,passports,official_docs];
  mode:autonomous_sequence(¬ask_confirmation_per_step)
}

§PAT[pipeline]{
  1_decode_orient:{
    heic:cross_platform_`from pillow_heif import register_heif_opener; register_heif_opener()`(fallback_macOS_CLI:`sips -s format png <in> --out <out>`);
    orient:`PIL.ImageOps.exif_transpose(img)`(fixes_EXIF_rotation)∧check(90°|180°|270°_when_EXIF_stripped_by_chat_apps)⇒auto_pick_upright
  };
  2_ocr_fallback:[
    1_macos_vision:`pyobjc-framework-Vision`(`VNRecognizeTextRequest` w/ `VNRequestTextRecognitionLevelAccurate`∧`usesLanguageCorrection=True`∧explicit_`recognitionLanguages`,e.g.`["zh-Hans","zh-Hant","en-US"]`,⊕ `ocrmac`;Neural_Engine,zero_weights),
    2_paddleocr:`paddleocr>=3.x`(`PP-OCRv5`+`PP-StructureV3`;best_cross_platform_CJK|tables|stamps;alt:`easyocr`),
    3_tesseract:`tesseract>=5.5`(`brew install tesseract tesseract-lang`∧`pytesseract`;lightweight_clean_scans)
  ]→extract(all_text+stamps+tables)∧classify_doc_type;
  3_translate:{
    style:formal_visa_EN∧preserve(structure,tables,stamp_text,numbers,dates,currency_amounts,ID_codes);
    names:original+`(English)`(Chinese⇒pinyin_matching_passport_MRZ_if_known,e.g.`WU Zhengye`)
  };
  4_pdf_bilingual(A4):{
    page_1:upright_original_img(centered,aspect_preserved,scaled_to_A4_margins);
    page_2+:EN_translation(title:centered+bold;body:structured_sections|tables;stamps:`[Official Seal: ...]`;footer:`"This is an English translation of the original document"`);
    fonts:CRITICAL⇒if_rendering_original_CJK|non-Latin_in_reportlab,register_Unicode_TTF(`TTFont`)∨`UnicodeCIDFont('STSong-Light')`(default_Helvetica_prints_tofu) ⊕ use_WeasyPrint(HTML+CSS_w/_system_CJK_fonts)_for_complex_tables;
    legal:¬label(`"certified"`)_unless_qualified|accredited_translator_certifies(statement+credentials+name+date+signature)
  };
  5_output:write(`<original_filename>_Translated.pdf`)∧verify(page_count≥2,no_tofu_glyphs,numbers|dates|names_match)∧report_path
}

§CFG[deps]{
  uv_ephemeral:`uv run --with pillow --with pillow-heif --with reportlab <script.py>`;
  core:`pip install pillow pillow-heif reportlab`(or_`weasyprint`_for_HTML_tables);
  macos_vision:`pip install pyobjc-framework-Vision pyobjc-framework-Quartz`(or_`ocrmac`);
  cross_platform_ocr:`pip install paddleocr`(or_`pytesseract`)
}

§SEC[privacy_compliance]{
  data:passports|IDs|bank_records≡high_risk_PII⇒keep_100%_local∧use_`tempfile.TemporaryDirectory()`_to_wipe_temp_OCR_images_post_run;
  jurisdiction:verify_target_authority_rules_pre_submit(AU:NAATI_certified;US/USCIS:signed_translator_competency_cert;UK/UKVI:accredited_statement+contact;CA/IRCC:certified_translator_or_affidavit)
}
