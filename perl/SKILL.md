---
name: perl
description: "AUTO_INVOKE(silent)⇔prompt∈{Perl,.pl,.pm,.t,use_v5.40,v5.42,v5.44,v5.36,signatures,postfix_deref,isa,try/catch,Try::Tiny,builtin,true/false,trim,indexed,Moo,Moose,feature_class,Corinna,named_regex,qr//,3arg_open,autodie,Path::Tiny,Exporter,Module::Runtime,perltidy,perlcritic,PerlNavigator,cpanfile,cpm,carton,cpan-audit,CPAN,Mojolicious,Dancer2,Catalyst,DBI,DBIx::Class,Crypt::Argon2,taint_mode,Test2::V0,Test::More,yath,prove,Devel::Cover}|SUB:{perl-security,perl-testing}"
---
@SKL:perl
§R{
  ∀file_start:'use v5.40;'(strict,warnings,say,sigs,try/catch,for_list,stable_builtin:true/false/trim/indexed,^^);'use v5.42;'(+source::encoding,¬switch/smartmatch);latest_stable:v5.44(Jul_2026);'use v5.36;'⇔legacy_LTS_only;¬legacy('use strict;use warnings;use feature');
  sub_signatures(defaults,slurpy_@rest;5.44_exp:named_:$param)∧¬manual_unpack(@_);
  context:'my $n=@a'→count∧'scalar @a'→force_scalar;chains⇒postfix_deref($r->@*,$r->%*,$r->@[0,1]);
  type_chk(≥5.32):'$o isa Class'∧¬(blessed($o)&&$o->isa(...));
  OO_prod⇒Moo+Types::Standard+namespace::autoclean;Moose⇔req_MOP;core_class(exp_5.38-5.44):'use experimental "class";'(:param,:reader/5.40+,__CLASS__/5.40+,:writer+my_method/->&/5.42+);
  complex_regex⇒named_captures((?<name>...),$+{name})+/x;reused_pat⇒qr//;¬ReDoS_nested_quantifiers;
  I/O⇒3arg_open+':encoding(UTF-8)'+autodie∧¬2arg_open;file_ops⇒prefer(Path::Tiny);
  src_encoding:non-ASCII_src⇒'use utf8;'∧5.42+_enforces_source::encoding('ascii'|'utf8');
  export⇒'use Exporter "import";'+@EXPORT_OK∧¬default_@EXPORT;
  runtime_load⇒Module::Runtime::require_module(portable)∨builtin::load_module(exp_5.40+)∧¬eval('require $m');
  ctor⇒Class->new∧¬indirect_obj_syntax;¬no_strict_refs∧¬sym_refs⇒use_hash;
  ¬deprecated_syntax:{given/when,smartmatch(~~)(deprecated_5.38,off_in_5.42+),apostrophe_pkg_sep(Pkg'var),goto_into_block(5.44+)};
  mutable_our_cfg_globals→use_constant∨Moo_attr_defaults;
  deps:pin(cpanfile+cpanfile.snapshot)∧install(cpm_parallel∨carton)∧audit(cpan-audit);
  quality:lint(perlcritic:core+pbp+security)∧fmt(perltidy)∧LSP(PerlNavigator∨PLS);
  tests⇒Test2::V0(in_core_≥5.40)+Test2::Tools::Mock(mock)+done_testing;runner:yath∨prove -lr;
}
§D{
  err_handle∧perl≥5.40⇒native_try{}catch($e){}¬Try::Tiny_new_code;
  err_handle∧perl<5.40⇒Try::Tiny(try{}catch{$_})¬bare_eval_if($@)_complex;
  simple_1off_fail_chk⇒eval{...};die("...: $@")if $@¬silent_eval_without_$@_chk;
  new_class∧req(roles∨types∨prod_stability)⇒Moo+Moo::Role+Types::Standard¬unneeded_Moose∨blessed_hashref;
  new_class∧perl≥5.40∧¬CPAN_deps⇒use_experimental_class(:param,:reader,:writer_5.42+,my_method_5.42+)¬blessed_hashref;
  iter_kv∨idx⇒for_my($k,$v)(%h)∧for_my($i,$v)(indexed(@a))(stable_5.40;5.44:aliased_ref)¬manual_each;
  booleans∧perl≥5.40⇒true/false(auto-imported_by_use_v5.40)¬magic_1_empty_in_APIs;
  booleans∧perl∈5.36..5.38⇒use_builtin_qw(true_false)(exp)¬magic_1_empty;
  scope_cleanup∧perl≥5.36⇒use_feature_defer(defer{...})¬manual_DESTROY_guard;
  CI_dep_install⇒cpm_install_--snapshot¬serial_cpanm;
  web/crypto_deps⇒Mojolicious≥9.48∧Crypt::Argon2≥0.031∧Crypt::JWT≥0.037_1+cpan-audit¬unpatched_CVEs;
  test_mocking⇒Test2::Tools::Mock(mock_Pkg=>override=>[...])¬typeglob_monkey_patch;
}
§REF{
  versions_5.40-5.44,code_examples,Corinna_class,builtin,layout,cpm/carton/PerlNavigator/perltidy/perlcritic_cfg,anti-patterns→references/idioms.md;
  input_handling,taint_mode,regex_safety,file_proc_ops,DBI,XSS/CSRF,Mojolicious≥9.48,Crypt::Argon2≥0.031,Crypt::JWT,cpan-audit,perlcritic_sec→references/perl-security.md;
  Test2::V0(core_5.40+),Test2::Tools::Mock,yath,prove,Test::Mojo,Plack::Test,Test::More,Devel::Cover→references/perl-testing.md;
}
§REL{
  ../secure-coding/SKILL.md:general_sec_checklists;
  ../database-design/SKILL.md:DBI,DBIx::Class_schema_design;
  ../systematic-debugging/SKILL.md:failing_tests,runtime_errors_root_cause;
}
