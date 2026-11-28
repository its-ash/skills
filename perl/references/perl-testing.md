@REF:perl-testing
§REL{[../SKILL.md](../SKILL.md),idioms.md,perl-security.md}
§USE{TDD(RED→GREEN→REFACTOR)∨suite_design∨coverage_review∨CI_setup∨Test::More→Test2::V0_migration∨mocking∨web_integration∨debug_failures}
§TDD{
  1_RED:`t/unit/calculator.t` (`use v5.40; use Test2::V0; use lib 'lib'; use Calculator; subtest 'addition' => sub { is(Calculator->new->add(2,3), 5, 'sums ints'); }; done_testing;`);
  2_GREEN:`lib/Calculator.pm` (`package Calculator; use v5.40; use Moo; sub add($self,$a,$b){ return $a + $b } 1;`);
  3_REFACTOR:keep green via `yath test t/unit/calculator.t` ∨ `prove -lv t/unit/calculator.t`;
}
§TEST2{
  core_status:`Test2::Suite` (`Test2::V0`,`Test2::V1`,`Test2::Tools::Mock`) shipped in **Perl core since v5.40** (zero_CPAN_bootstrap_deps_on_5.40+; declare in `cpanfile` `on test` only if targeting `<5.40`);
  base:`use v5.40; use Test2::V0;` (default_modern_bundle; auto-enables `strict`,`warnings`; rich diagnostics; extensible `Test2::Tools::*`; backward-compat w/`Test::More`; add `use utf8; use Test2::Plugin::UTF8;` for UTF-8 source+TAP);
  builders:
  ```perl
  is($user->to_hash, hash {
      field name  => 'Alice';
      field email => match(qr/\@example\.com$/);
      field age   => validator(sub { $_ >= 18 });
      etc();
  }, 'user fields');
  is($res, array { item 'first'; item match(qr/^second/); item DNE(); }, 'exact list');
  is($tags, bag { item 'perl'; item 'testing'; item 'tdd'; }, 'order-independent');
  ```
  subtest_warn:`subtest 'name' => sub { my $u = ...; };` ∧ `my $w = warns { ... };`;
  exceptions:`like(dies { divide(10, 0) }, qr/Division by zero/, 'throws');` ∧ `ok(lives { divide(10, 2) }, 'succeeds') or note($@);`;
  required:`done_testing;` at EOF (¬omit⇒silent_skip_bugs);
}
§MOCK{
  Test2_native(preferred,core_≥5.40):
  ```perl
  use Test2::V0; # re-exports mock() from Test2::Tools::Mock (or explicit: use Test2::Tools::Mock;)
  subtest 'mock API' => sub {
      my $calls = 0;
      my $mock = mock 'MyApp::API' => (
          override => [
              fetch_user => sub ($self, $id) { $calls++; return { id => $id, name => 'Mock' } },
          ],
      );
      ...
      is($calls, 1, 'called once');
  }; # auto-restored when $mock leaves scope; also supports add, before, after, around, track
  ```
  legacy_fallback:`Test::MockModule` (`$mock->mock(...)`) ∨ `Test::MockObject` (`->called_ok()`) for existing `Test::More` suites;
  ¬monkey_patch:`*MyApp::API::fetch_user = sub { ... };` (leaks_across_tests);
}
§YATH{
  role:`yath` (`App::Yath`/`Test2::Harness`):modern Test2-native runner (parallel, preloading `-P`, structured event logs, resource tracking);
  cmds:{
    all:`yath test -j8`,
    single:`yath test -v t/unit/user.t`,
    preload:`yath test -j8 -PMyApp::Schema`,
    failed_only:`yath test --changed-only` ∨ `yath test --retry 2`
  };
  yath_rc:`.yath.rc` (`[test]` section: `-j8`, `-Ilib`, `-PMyApp::Base`, `-B` compressed_logs);
}
§PROVE{
  role:core TAP runner (ubiquitous, zero extra deps);
  cmds:{
    all:`prove -l t/`,
    verbose:`prove -lv t/` | `prove -lv t/unit/user.t`,
    recursive:`prove -lr t/`,
    parallel:`prove -lr -j8 t/`,
    failed_only:`prove -l --state=failed t/`,
    color_timer:`prove -l --color --timer t/`,
    CI_JUnit:`prove -l --formatter TAP::Formatter::JUnit t/ > results.xml`
  };
  proverc:`.proverc` (`-l`, `--color`, `--timer`, `-r`, `-j4`, `--state=save`);
}
§TEST_MORE{
  status:legacy/maintenance_only (prefer `Test2::V0` for new tests);
  plan:`plan tests => 5;` ⊕ `done_testing;`;
  asserts:`is($got,$exp,$m)`, `isnt($got,$unexp,$m)`, `ok($cond,$m)`, `is_deeply($got,\%exp,$m)`, `like($s,qr//,$m)`, `unlike($s,qr//,$m)`, `isa_ok($o,'Cls')`, `can_ok($o,'m1','m2')`;
  skip:`SKIP: { skip 'reason', $n unless $cond; ... }`;
  todo:`TODO: { local $TODO = 'reason'; ... }`;
}
§ORG{
  tree:`t/{00-load.t,01-basic.t,unit/*.t,integration/*.t,lib/TestHelper.pm,fixtures/*}`;
  shared_helpers:`t/lib/TestHelper.pm` (`use lib 't/lib'`, `Exporter`: `create_test_db()`, `create_temp_dir()`, `fixture_path()`);
  isolation:
  ```perl
  use Path::Tiny;
  subtest 'file processing' => sub {
      my $dir  = Path::Tiny->tempdir; # auto-cleaned when $dir leaves scope
      my $file = $dir->child('input.txt');
      $file->spew_utf8("line1\nline2\n");
      ...
  };
  ```
}
§INT{
  SQLite_mem:`my $dbh = DBI->connect('dbi:SQLite:dbname=:memory:', '', '', { RaiseError => 1 });`;
  Mojolicious:`use Test::Mojo; my $t = Test::Mojo->new('MyApp'); $t->get_ok('/health')->status_is(200)->json_is('/ok' => true);`;
  PSGI_Dancer2:`use Plack::Test; my $test = Plack::Test->create($app); my $res = $test->request(GET '/health'); is($res->code, 200);`;
  HTTP_client:mock `HTTP::Tiny` via `Test2::Tools::Mock` (`mock 'HTTP::Tiny' => (override => [ get => sub { ... } ])`);
}
§COVER{
  cmds:{
    basic:`cover -test`,
    manual:`perl -MDevel::Cover -Ilib t/unit/user.t && cover`,
    html:`cover -report html` (`cover_db/coverage.html`),
    text:`cover -test -report text | grep 'Total'`,
    CI_gate_80:`cover -test && cover -report text -select '^lib/' | perl -ne 'if (/Total.*?(\d+\.\d+)/) { exit 1 if $1 < 80 }'`
  };
}
§R{
  DO:{TDD_red_green_refactor, `Test2::V0`(core_≥5.40), `Test2::Tools::Mock`, `subtest`+`my`_isolation, mock_boundaries(net,DB,FS), `yath`∨`prove -lr`, descriptive_names, edge_cases(`''`,`undef`,0,bounds,Unicode), cov≥80%_business_logic, fast_in_mem_IO};
}
§ANTI{
  1:forget_`done_testing`⇒silent_skipped_tests;
  2:omit_`-l`/`-Ilib`⇒`Can't locate ... in @INC`;
  3:over_mock⇒mocking_code_under_test_instead_of_dependencies;
  4:test_pollution⇒`our`_vars_or_shared_state_across_subtests;
  5:test_internals_instead_of_behavior;
  6:new_code_using_`Test::More`_instead_of_`Test2::V0`;
  7:typeglob_monkey_patch_instead_of_`Test2::Tools::Mock`;
  8:testing_CPAN_modules∨brittle_exact_string_matching∨merging_with_failures;
}
