@REF:flox-environments
§SCOPE{
  reproducible_macOS_Linux(Nix,1_TOML,no_containers_VM)+OCI_export(`flox containerize`);
  auto_trigger:`.flox/`|`manifest.toml`|`flox activate`|FloxHub|"works on my machine";
  use_if:{sys+lang_deps,reproducibility,coexisting_tools(Py3.14+PG18+Redis+Node26),macOS+Linux,agent_install_no_sudo_no_pollute_no_sandbox};
  ¬use_if:{single_runtime_no_sys(nvm|pyenv|rustup),full_OS_iso(⇒[docker.md](docker.md))};
  prereq:https://flox.dev/docs/install-flox/install/
}
§PATHS{
  `.flox/env/manifest.toml`(commit);
  `$FLOX_ENV`(`bin/,lib/,include/`);
  `$FLOX_ENV_CACHE`(persistent_across_rebuilds);
  `$FLOX_ENV_PROJECT`(proj_root)
}
§CMD{
  `flox init`;`flox search <pkg> [--all]`(case_sens);`flox show <pkg>`;`flox install <pkg>`;
  `flox list`(-c=raw);`flox activate`(-- <cmd>=no_subshell,--start-services,-r owner/env-name);
  `flox edit [-f <file>]`;`flox push`;
  `flox build`(run`[build]`recipes);
  `flox containerize [--file out.tar] [--runtime docker|podman] [--label k=v]`(export_env→OCI_image_without_Dockerfile)
}
§MANIFEST{
  schema:`version = 1`⊕`schema-version = "1.19.0"`(managed_by_CLI);
  `[install]`:`pkg.pkg-path="..."`,opt:`version="^26.0"|"18.0"`,opt:`systems=[...]`,opt:`priority=N`(low_wins),opt:`pkg-group="grp"`(resolve_together);
  `[vars]`:static_env;
  `[hook].on-activate`:non-interactive,fast,idempotent,every_activate;
  `[profile].common`:interactive_fns+aliases;
  `[services].<name>.command`;
  `[build].<name>.command`:reproducible_source_builds_inside_env;
  `[containerize].config`:OCI_image_export_opts;
  `[options].systems=["x86_64-linux","aarch64-linux","x86_64-darwin","aarch64-darwin"]`;
  `[include].<name>.floxhub="org/env"`
}
§PLAT{
  linux:`["x86_64-linux","aarch64-linux"]`(`valgrind`,`gdb`);
  macos:`["x86_64-darwin","aarch64-darwin"]`(`darwin.apple_sdk.frameworks.Security`,`coreutils`)
}
§RECIPES{
  py_uv:{install:{python:`python314`,uv:`uv`},vars:{UV_CACHE_DIR:`$FLOX_ENV_CACHE/uv-cache`},hook:`venv="$FLOX_ENV_CACHE/venv";[ ! -d "$venv" ]&&uv venv "$venv" --python python3;[ -f "$venv/bin/activate" ]&&source "$venv/bin/activate";[ -f uv.lock ]&&[ ! -f "$FLOX_ENV_CACHE/.deps_installed" ]&&uv sync --frozen --quiet&&touch "$FLOX_ENV_CACHE/.deps_installed"`};
  node:{install:{nodejs:`nodejs`^`^26.0`},hook:`[ -f package.json ]&&[ ! -d node_modules ]&&npm ci --silent`};
  rust:{install:{rustup,pkg-config,openssl},vars:{RUSTUP_HOME:`$FLOX_ENV_CACHE/rustup`,CARGO_HOME:`$FLOX_ENV_CACHE/cargo`},profile:`export PATH="$CARGO_HOME/bin:$PATH"`};
  go:{install:{go,gopls,delve},vars:{GOPATH:`$FLOX_ENV_CACHE/go`,GOBIN:`$FLOX_ENV_CACHE/go/bin`},profile:`export PATH="$GOBIN:$PATH"`};
  cpp:{install:{gcc:`gcc14`(pkg-group:"compilers"),gcc-unwrapped:`gcc-unwrapped`(pkg-group:"libraries"#req_libstdc++_hdrs),cmake(pkg-group:"build"),gnumake(pkg-group:"build"),gdb(linux)}};
  fullstack_py_pg_redis:{
    install:{python:`python314`,uv,postgresql:`postgresql_18`,redis,jq,curl};
    vars:{UV_CACHE_DIR:`$FLOX_ENV_CACHE/uv-cache`,DATABASE_URL:`postgres://localhost:5432/myapp`,REDIS_URL:`redis://localhost:6379`};
    hook:`[ ! -d "$FLOX_ENV_CACHE/pgdata" ]&&initdb -D "$FLOX_ENV_CACHE/pgdata" --no-locale --encoding=UTF8`+py_uv.hook;
    profile:`serve(){ uvicorn app.main:app --reload --host 0.0.0.0 --port 8000; }; migrate(){ alembic upgrade head; }`;
    services:{postgres:`postgres -D $FLOX_ENV_CACHE/pgdata -k $FLOX_ENV_CACHE`,redis:`redis-server --port 6379 --daemonize no`};
    options:§MANIFEST.systems;
    run:`flox activate --start-services`
  }
}
§ANTI{
  abs_paths⇒`$FLOX_ENV_PROJECT`;
  `exit 1`_in_hook(kills_shell)⇒`return 1`;
  secrets_in_`[vars]`⇒`API_KEY="${API_KEY:-}"`+`API_KEY=... flox activate`;
  unguarded_hook⇒`$FLOX_ENV_CACHE/.deps_installed`;
  user_cmds_in_hook⇒`[profile].common`(auto→`[hook]`,typed→`[profile]`)
}
§SHARE{
  git:commit(`.flox/`)→`git clone <repo> && cd <repo> && flox activate`;
  floxhub:`flox push`→`flox activate -r owner/env-name`;
  compose:`[include] base.floxhub="myorg/python-base"`+`[install] fastapi.pkg-path="python314Packages.fastapi"`;
  oci:`flox containerize --runtime docker`⇒identical_env_in_container
}
§AGENT{
  traits:{no_sudo,proj_scoped,sandbox_ok,reversible(`manifest.toml`),git_repro};
  flow:`flox search <pkg>`→`flox install <pkg>`∨(`tmp=$(mktemp); flox list -c > "$tmp"`→edit→`flox edit -f "$tmp"`)→`flox activate -- <cmd>`
}
§DBG{
  `flox list -c`;`flox activate -- which python`;`flox activate -- env | grep FLOX`;`flox search <pkg> --all`;
  not_found⇒`--all`(case_sens);conflict⇒`priority`;hook_fail⇒`return`¬`exit`∧`${FLOX_ENV_CACHE:-}`;stale_deps⇒rm(`$FLOX_ENV_CACHE/.deps_installed`)
}
§REL{[devops-iac](../SKILL.md);[docker.md](docker.md);docs:https://flox.dev/docs/}
