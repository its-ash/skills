@REF:perl-testing
§USE{TDD(RED→GREEN→REFACTOR)∨suite_design∨coverage_review∨CI_setup∨Test::More→Test2::V0_migration∨debug_failures}
§TDD{
  1_RED:`t/unit/calculator.t` (`use v5.36; use Test2::V0; use lib 'lib'; use Calculator; subtest 'addition' => sub { ... }; done_testing;`);
  2_GREEN:`lib/Calculator.pm` (`package Calculator; use v5.36; use Moo; sub add($self,$a,$b){return $a+$b;} 1;`);
  3_REFACTOR:keep green via `prove -lv t/unit/calculator.t`
}
§TEST_MORE{
  plan:`plan tests => 5;` ⊕ `done_testing;`;
  asserts:`is($got,$exp,$m)`, `isnt($got,$unexp,$m)`, `ok($cond,$m)`, `is_deeply($got,\%exp,$m)`, `like($s,qr//,$m)`, `unlike($s,qr//,$m)`, `isa_ok($o,'Cls')`, `can_ok($o,'m1','m2')`;
  skip:`SKIP: { skip 'reason', $n unless $cond; ... }`;
  todo:`TODO: { local $TODO = 'reason'; ... }`
}
§TEST2{
  base:`use v5.36; use Test2::V0;` (modern default; richer diagnostics; extensible `Test2::Tools::*`; backward-compat w/`Test::More`);
  builders:
  ```perl
  is($user->to_hash, hash {
      field name => 'Alice'; field email => match(qr/\@example\.com$/);
      field age => validator(sub { $_ >= 18 }); etc();
  }, 'user fields');
  is($res, array { item 'first'; item match(qr/^second/); item DNE(); }, 'exact list');
  is($tags, bag { item 'perl'; item 'testing'; item 'tdd'; }, 'order-independent');
  ```
  subtest_warn:`subtest 'name' => sub { my $u=...; };` ∧ `my $w = warns { ... };`;
  exceptions:`like(dies { divide(10, 0) }, qr/Division by zero/, 'msg');` ∧ `ok(lives { divide(10, 2) }, 'msg') or note($@);`;
  required:`done_testing;` at EOF (¬omit⇒silent skip bugs)
}
§ORG{
  tree:`t/{00-load.t,01-basic.t,unit/*.t,integration/*.t,lib/TestHelper.pm,fixtures/*}`;
  shared_helpers:`t/lib/TestHelper.pm` (`use lib 't/lib'`, `Exporter`: `create_test_db()`, `create_temp_dir()`, `fixture_path()`);
  isolation:
  ```perl
  use File::Temp qw(tempdir); use Path::Tiny;
  subtest 'file processing' => sub {
      my $dir = tempdir(CLEANUP => 1);
      my $file = path($dir, 'input.txt'); $file->spew_utf8("line1\nline2\n");
      ...
  };
  ```
}
§PROVE{
  cmds:{
    all:`prove -l t/`,
    verbose:`prove -lv t/` | `prove -lv t/unit/user.t`,
    recursive:`prove -lr t/`,
    parallel:`prove -lr -j8 t/`,
    failed_only:`prove -l --state=failed t/`,
    color_timer:`prove -l --color --timer t/`,
    CI_JUnit:`prove -l --formatter TAP::Formatter::JUnit t/ > results.xml`
  };
  proverc:`-l`, `--color`, `--timer`, `-r`, `-j4`, `--state=save`
}
§MOCK{
  MockModule:
  ```perl
  use Test::MockModule;
  subtest 'mock API' => sub {
      my $mock = Test::MockModule->new('MyApp::API');
      my $calls = 0;
      $mock->mock(fetch_user => sub ($self, $id) { $calls++; return { id => $id, name => 'Mock' }; });
      ...
      is($calls, 1, 'called once');
  }; # auto-restored when $mock leaves scope
  ```
  MockObject:`Test::MockObject` (`->mock()`, verify w/`->called_ok()`);
  ¬monkey_patch:`*MyApp::API::fetch_user = sub {...};` (leaks across tests)
}
§COVER{
  cmds:{
    basic:`cover -test`,
    manual:`perl -MDevel::Cover -Ilib t/unit/user.t && cover`,
    html:`cover -report html` (`cover_db/coverage.html`),
    text:`cover -test -report text | grep 'Total'`,
    CI_gate_80:`cover -test && cover -report text -select '^lib/' | perl -ne 'if (/Total.*?(\d+\.\d+)/) { exit 1 if $1 < 80 }'`
  }
}
§INT{
  SQLite_mem:`my $dbh = DBI->connect('dbi:SQLite:dbname=:memory:', '', '', { RaiseError => 1 });`;
  HTTP:mock `HTTP::Tiny` for API tests
}
§R{
  DO:{TDD_red_green_refactor, `Test2::V0`, `subtest`+`my`_isolation, mock_boundaries(net,DB,FS), `prove -l`, descriptive_names, edge_cases(`''`,`undef`,0,bounds), cov≥80%_business_logic, fast_in_mem_IO}
}
§ANTI{
  1:forget_`done_testing`⇒silent_skipped_tests;
  2:omit_`-l`⇒`Can't locate ... in @INC`;
  3:over_mock⇒mocking_code_under_test_instead_of_dependencies;
  4:test_pollution⇒`our`_vars_or_shared_state_across_subtests;
  5:test_internals_instead_of_behavior;
  6:new_code_using_`Test::More`_instead_of_`Test2::V0`;
  7:testing_CPAN_modules∨brittle_exact_string_matching∨merging_with_failures
}
