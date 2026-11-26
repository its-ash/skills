@REF:github-actions
§SCOPE{.github/workflows/*.yml:{ci,deploy,release,cron,pr_triage,sec_scan,matrix,cache,concurrency}}
§DETECT{package.json⇒Node(React|Next.js|Vue|Angular|Svelte);requirements.txt|pyproject.toml|setup.py⇒Python;go.mod⇒Go;Cargo.toml⇒Rust;pom.xml|build.gradle⇒Java|Kotlin;Gemfile⇒Ruby;composer.json⇒PHP;pubspec.yaml⇒Dart|Flutter;Package.swift⇒Swift;*.csproj|*.sln⇒.NET;.github/workflows/⇒¬conflict;Dockerfile⇒container;docker-compose.yml⇒multi_svc;vercel.json|netlify.toml⇒deploy_target;terraform/|pulumi/⇒IaC;.eslintrc*|eslint.config.*⇒ESLint;prettier*⇒Prettier;jest.config*|vitest.config*|pytest.ini⇒test_fw;.env.example⇒env_vars;Makefile⇒custom_build}
§CLR{ambiguous⇒ask(1Q)∈{tests∨+lint/typecheck,target(AWS|GCP|DockerHub|Vercel),trig(PR∨push_main)};clear⇒skip}
§FILE{kebab-case:{ci.yml,deploy.yml,deploy-<target>.yml,release.yml,scheduled-<task>.yml}}
§TPL{```yaml
name: <Name>
on: {push: {branches: [main], paths-ignore: ['**.md', 'docs/**']}, pull_request: {branches: [main]}}
permissions: {contents: read}
concurrency: {group: "${{ github.workflow }}-${{ github.ref }}", cancel-in-progress: true}
jobs: {<job-id>: {runs-on: ubuntu-latest, timeout-minutes: 15, steps: [{uses: actions/checkout@v4}]}}
```}
§PAT{on|jobs|feat:ci(push_main∧PR|[lint,test](||)|[cache,matrix]);deploy(push_main∨tag|test→build→deploy(needs)|[env_prot,secrets,status]);release(tag(v*)∨workflow_dispatch|test→build→publish→create-release|[changelog,upload-artifact,npm|PyPI|Docker]);cron(schedule+workflow_dispatch|1|[manual,fail_notify]);sec(PR+weekly|[dep_audit,SAST,secret_scan]|[SARIF→Security,fail_critical]);docker(push_main∧tags|build→push|[multi_arch,layer_cache,tags])}
§ACT{pin:@major;setup:{actions/checkout@v4,actions/setup-node@v4,actions/setup-python@v5,actions/setup-go@v5,actions/setup-java@v4,dtolnay/rust-toolchain@stable,ruby/setup-ruby@v1,actions/setup-dotnet@v4};deploy:{docker/build-push-action@v6,docker/login-action@v3,aws-actions/configure-aws-credentials@v4,google-github-actions/auth@v2,azure/login@v2,cloudflare/wrangler-action@v3,amondnet/vercel-action@v25};sec:{github/codeql-action/analyze@v3,aquasecurity/trivy-action@master,codecov/codecov-action@v4,actions/dependency-review-action@v4};util:{actions/cache@v4,actions/upload-artifact@v4,actions/download-artifact@v4,softprops/action-gh-release@v2,slackapi/slack-github-action@v2,peter-evans/create-pull-request@v7}}
§SEC{min(permissions)@(wf|job);pin(@vN);¬echo(secrets)∧¬("${{ secrets.X }}"∈run);prod⇒GitHub_Environments+prot_rules;validate(workflow_dispatch.inputs);¬script_inj:event→env:∧¬inline(`run: echo "$ISSUE_TITLE"`+`env:{ISSUE_TITLE:"${{ github.event.issue.title }}"}`);prefer:${{ secrets.GITHUB_TOKEN }}>PAT;concurrency⇒¬dup_runs}
§CACHE{actions/setup-node@v4:{node-version:20,cache:npm|yarn|pnpm};actions/setup-python@v5:{python-version:'3.12',cache:pip|poetry|pipenv};actions/setup-go@v5:{go-version:'1.22',cache:true};actions/cache@v4:{path:"~/.cargo/bin/\n~/.cargo/registry/**\ntarget/",key:"${{ runner.os }}-cargo-${{ hashFiles('**/Cargo.lock') }}"};docker/build-push-action@v6:{cache-from:type=gha,cache-to:"type=gha,mode=max"}}
§MATRIX{strategy.matrix:{node:{node-version:[18,20,22],fail-fast:false};os:{os:[ubuntu-latest,macos-latest,windows-latest],runs-on:${{ matrix.os }}};exclude:{os:[ubuntu-latest,windows-latest],node-version:[18,20],exclude:[{os:windows-latest,node-version:18}]}}}
§CRON{hourly:"0 * * * *";daily_00UTC:"0 0 * * *";weekdays_09UTC:"0 9 * * 1-5";weekly_sun:"0 0 * * 0";monthly_1st:"0 0 1 * *"}
§CHK{kebab-case;on;min_permissions;concurrency;checkout@v4_1st;lang_setup;cache;jobs(lint,test,build,deploy)+needs;pin_@vN;timeout-minutes;¬echo_secrets;summary(purpose,secrets,trig);test(workflow_dispatch)}
