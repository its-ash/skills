---
description: "Fix Android/KMP Gradle build errors"
---
@CMD:gradle-build
§CMD{
  `build.gradle.kts`+`composeApp/`(KMP)⇒`./gradlew composeApp:compileKotlinMetadata 2>&1`
  `build.gradle.kts`+`app/`(Android)⇒`./gradlew app:compileDebugKotlin 2>&1`
  `settings.gradle.kts`+mods⇒`./gradlew assemble 2>&1`
  detekt⇒`./gradlew detekt 2>&1`
  cfg:`gradle.properties`,`local.properties`
}
§FLOW{
  1:detect_cfg→run_build→capture_out
  2:split(Kotlin_compile vs Gradle_cfg)→group(mod,file)→sort(cfg→compile_by_dep)
  3:∀err:{read_ctx→diag(missing_import/ref|type_mismatch|missing_dep(`build.gradle.kts`)|expect/actual|Compose)→min_fix→re-run→next}
}
§GATE{
  STOP∧ask_user⇔(fix_adds>errs)∨(same_err≥3)∨(req_new_dep∨mod_struct_Δ)∨(sync/cfg_fail)∨(err∈gen(Room|SQLDelight|KSP))
}
§FIX{
  unresolved(`commonMain`)⇒chk `commonMain.dependencies {}`
  `expect`¬`actual`⇒add `actual` ∀platform_src
  Compose_mismatch⇒align Kotlin∧Compose in `libs.versions.toml`
  dup_class⇒`./gradlew dependencies`
  KSP⇒`./gradlew kspCommonMainKotlinMetadata`
  cfg_cache⇒chk non-serializable task inputs
}
§OUT{fixed(mod,file,desc),remaining,new_errs(0),next_steps}
