@REF:visa-doc-translate
§SCOPE{
  in:image(HEIC|PNG|JPG);
  out:`<original_filename>_Translated.pdf`@(same_dir,A4_bilingual);
  docs:[bank_deposit(`存款证明`),income(`收入证明`),employment(`在职证明`),retirement(`退休证明`),property(`房产证明`),business_license(`营业执照`),ID_cards,passports,official_docs];
  mode:autonomous_sequence(¬ask_confirmation_per_step)
}

§PAT[pipeline]{
  1_heic_conv:if(HEIC)→`sips -s format png <input> --out <output>`;
  2_orient:`PIL.ImageOps.exif_transpose(img)`(EXIF_6→90°_CW)∧test(180°_if_upside_down)⇒auto_pick_upright;
  3_ocr_fallback:[
    1:macOS_Vision(`import Vision; from Foundation import NSURL`),
    2:EasyOCR(`pip install easyocr`),
    3:Tesseract(`brew install tesseract tesseract-lang && pip install pytesseract`)
  ]→extract(all_text)∧classify_doc_type;
  4_translate:{
    style:professional_visa_EN∧preserve(structure,format,numbers,dates,amounts);
    names:original+`(English)`(Chinese⇒pinyin,e.g.`WU Zhengye`)
  };
  5_pdf(PIL+reportlab,A4):{
    page_1:rotated_original_img(centered,scaled_to_A4);
    page_2:EN_translation(title:centered+bold;body:left_aligned+spaced)+footer(`"This is an English translation of the original document"`);
    legal:¬call(`"certified"`)_unless_qualified_translator_certifies(statement+name+signature)
  };
  6_output:write(`<original_filename>_Translated.pdf`)∧report_path
}

§CFG[deps]{
  core:`pip install pillow reportlab`,
  macos_vision:`pip install pyobjc-framework-Vision pyobjc-framework-Quartz`
}

§SEC[privacy_compliance]{
  data:personal_PII⇒keep_local∧delete_temp_OCR_files_post_run;
  jurisdiction:verify_target_authority_rules(AU|US|CA|UK|etc)_pre_submit
}
