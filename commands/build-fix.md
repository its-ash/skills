---
description: "Detect build system; fix build/type errors incrementally with minimal safe diffs."
---
@CMD:build-fix
§DETECT{
  `package.json`(w/`build`)⇒`npm run build`⊕`pnpm build`;
  `tsconfig.json`(TS)⇒`npx tsc --noEmit`;
  `Cargo.toml`⇒`cargo build 2>&1`;
  `pom.xml`⇒`mvn compile`;
  `build.gradle.kts`⇒`./gradlew compileJava`;
  `go.mod`⇒`go build ./...`;
  `pyproject.toml`⇒`uv run ruff check .`→(`uv run pyright`⊕`uv run mypy --strict .`)
}
§FLOW{
  1:run(§DETECT)+stderr→group(file)→sort(imports/types→logic)→count;
  2:∀err(1_at_a_time):read(±10L)→diagnose(import/type/syntax)→edit(min_diff,¬refactor)→rebuild(fixed∧0_new)→next
}
§GATE{
  STOP+ask_user⇔(new_err>fixed_err)∨(same_err>3_tries)∨(needs_arch_Δ)∨(missing_deps:`npm install`/`cargo add`/etc)
}
§REC{
  missing_import⇒chk_installed→suggest_install;
  type_mismatch⇒read_defs→fix_narrower;
  circular_dep⇒import_graph→suggest_extract;
  ver_conflict⇒chk(`package.json`/`Cargo.toml`);
  misconfig⇒read_cfg→diff_defaults
}
§OUT{fixed(w/paths),remaining,new_errors(target=0),next_steps}
