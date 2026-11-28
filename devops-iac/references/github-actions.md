@REF:github-actions
§SCOPE{.github/workflows/*.yml:{ci,deploy,release,cron,pr_triage,sec_scan,matrix,cache,concurrency,OIDC,SHA_pin}}
§DETECT{package.json⇒Node(React|Next.js|Vue|Angular|Svelte);pyproject.toml|uv.lock|requirements.txt⇒Python;go.mod⇒Go;Cargo.toml⇒Rust;pom.xml|build.gradle⇒Java|Kotlin;Gemfile⇒Ruby;composer.json⇒PHP;pubspec.yaml⇒Dart|Flutter;Package.swift⇒Swift;*.csproj|*.sln⇒.NET;.github/workflows/⇒¬conflict;Dockerfile⇒container;compose.yml|docker-compose.yml⇒multi_svc;vercel.json|wrangler.jsonc⇒deploy_target;terraform/|pulumi/⇒IaC;biome.json|eslint.config.*⇒lint;jest.config*|vitest.config*|pytest.ini⇒test_fw;.env.example⇒env_vars;Makefile⇒custom_build}
§CLR{ambiguous⇒ask(1Q)∈{tests∨+lint/typecheck,target(AWS|GCP|CF|GHCR|Vercel),trig(PR∨push_main)};clear⇒skip}
§FILE{kebab-case:{ci.yml,deploy.yml,deploy-<target>.yml,release.yml,scheduled-<task>.yml}}
§TPL{```yaml
name: <Name>
on: {push: {branches: [main], paths-ignore: ['**.md', 'docs/**']}, pull_request: {branches: [main]}}
permissions: {contents: read}
concurrency: {group: "${{ github.workflow }}-${{ github.ref }}", cancel-in-progress: true}
jobs: {<job-id>: {runs-on: ubuntu-latest, timeout-minutes: 15, steps: [{uses: actions/checkout@v7, with: {persist-credentials: false}}]}} # pin 40-char SHA in prod
```}
§PAT{
  ci(push_main∧PR|[lint,test](||)|[cache,matrix]);
  deploy(push_main∨tag|test→build→deploy(needs)|[OIDC,env_prot,status]);
  release(tag(v*)∨workflow_dispatch|test→build→attest→publish→create-release|[changelog,upload-artifact@v7,npm|PyPI|GHCR]);
  cron(schedule+workflow_dispatch|1|[manual,fail_notify]);
  sec(PR+weekly|[dep_audit,CodeQL_v4,Trivy,secret_scan]|[SARIF→Security,fail_critical]);
  docker(push_main∧tags|build→push|[buildx@v4,multi_arch,layer_cache_gha,SBOM/provenance])
}
§ACT{
  runtime:Node24+ESM(requires_runner`>= v2.327.1`;Node20_removed);
  pin_rule:prod⇒40char_commit_SHA`uses: owner/action@<40-char-sha> # vX.Y.Z`⊕workflow_lockfiles;¬`@master`∨`@main`;
  setup:{actions/checkout@v7(blocks_fork_PR_on_pull_request_target/workflow_run),actions/setup-node@v7,actions/setup-python@v7,astral-sh/setup-uv@v5,actions/setup-go@v7,actions/setup-java@v6,actions/setup-dotnet@v6,dtolnay/rust-toolchain@stable,ruby/setup-ruby@v1};
  deploy:{docker/setup-buildx-action@v4,docker/login-action@v4,docker/build-push-action@v7,aws-actions/configure-aws-credentials@v6,google-github-actions/auth@v3,azure/login@v2,cloudflare/wrangler-action@v4};
  sec:{github/codeql-action/analyze@v4(v3_deprecated_Dec_2026),aquasecurity/trivy-action@v0.36.0+(pinned_SHA,¬`@master`),codecov/codecov-action@v4,actions/dependency-review-action@v4};
  util:{actions/cache@v5(or_v6,Cache_v2),actions/upload-artifact@v7(supports`archive:false`),actions/download-artifact@v8,softprops/action-gh-release@v2,slackapi/slack-github-action@v2,peter-evans/create-pull-request@v7}
}
§SEC{
  permissions:min@(wf|job)(default`contents:read`;add`id-token:write`only_on_OIDC_job);
  pin:40char_SHA`# vX.Y.Z`+CODEOWNERS_on`.github/workflows/`+OpenSSF_Scorecard+Dependabot/Renovate;
  oidc:prefer_OIDC(short_lived_JWT:AWS,GCP_WIF,Azure,Vault,PyPI,Docker)>static_keys;scope`sub`claim(`repo:org/repo:environment:production`+immutable_repo_ID);
  checkout:`persist-credentials:false`(unless_pushing);
  secrets:¬echo∧¬("${{ secrets.X }}"∈run);prod⇒GitHub_Environments+prot_rules;
  inj:validate(workflow_dispatch.inputs);¬script_inj:event→`env:`∧¬inline(`run: echo "$ISSUE_TITLE"`+`env:{ISSUE_TITLE:"${{ github.event.issue.title }}"}`);
  tokens:prefer`${{ secrets.GITHUB_TOKEN }}>PAT`;concurrency⇒¬dup_runs
}
§CACHE{
  actions/setup-node@v7:{node-version:26,cache:npm|yarn|pnpm};
  astral-sh/setup-uv@v5:{enable-cache:true,cache-dependency-glob:"uv.lock"};
  actions/setup-python@v7:{python-version:'3.14',cache:pip|poetry};
  actions/setup-go@v7:{go-version:'1.27',cache:true};
  actions/cache@v5:{path:"~/.cargo/bin/\n~/.cargo/registry/**\ntarget/",key:"${{ runner.os }}-cargo-${{ hashFiles('**/Cargo.lock') }}"};
  docker/build-push-action@v7:{cache-from:type=gha,cache-to:"type=gha,mode=max"}
}
§MATRIX{strategy.matrix:{node:{node-version:[24,26],fail-fast:false};py:{python-version:['3.13','3.14','3.15'],fail-fast:false};os:{os:[ubuntu-latest,macos-latest,windows-latest],runs-on:${{ matrix.os }}};exclude:{os:[ubuntu-latest,windows-latest],node-version:[24,26],exclude:[{os:windows-latest,node-version:24}]}}}
§CRON{hourly:"0 * * * *";daily_00UTC:"0 0 * * *";weekdays_09UTC:"0 9 * * 1-5";weekly_sun:"0 0 * * 0";monthly_1st:"0 0 1 * *"}
§CHK{kebab-case;on;min_permissions;concurrency;checkout@v7(`persist-credentials:false`)_1st;OIDC(¬static_cloud_keys);SHA_pin(¬`@master`);lang_setup(Node24_actions);cache;jobs(lint,test,sec,build,deploy)+needs;timeout-minutes;¬echo_secrets;¬script_inj;test(workflow_dispatch)}
