---
name: perl
description: "AUTO_INVOKE(silent)⇔prompt∈{Perl,.pl,.pm,.t,use_v5.36,signatures,postfix_deref,isa,Try::Tiny,try/catch,Moo,Moose,feature_class,named_regex,qr//,3arg_open,autodie,Path::Tiny,Exporter,Module::Runtime,perltidy,perlcritic,cpanfile,carton,CPAN,Mojolicious,Dancer2,Catalyst,DBI,DBIx::Class,taint_mode,Test2::V0,Test::More,prove,Devel::Cover}|SUB:{perl-security,perl-testing}"
---
@SKL:perl
§R{
  ∀file_start:'use v5.36;'({strict,warnings,say,signatures})∧¬legacy('use strict;use warnings;use feature');
  sub_signatures(defaults,slurpy_params)∧¬manual_unpack(@_);
  context:'my $n=@a'→count∧'scalar @a'→force_scalar;
  chains⇒postfix_deref($r->@*,$r->%*,$r->@[0,1]);
  type_chk(Perl≥5.32):'$o isa Class'∧¬(blessed($o)&&$o->isa(...));
  OO⇒Moo+Types::Standard+namespace::autoclean;Moose⇔req_metaprotocol;
  complex_regex⇒named_captures((?<name>...),$+{name})+/x;reused_pat⇒qr//;
  I/O⇒3arg_open+encoding_layer+autodie∧¬2arg_open;
  file_ops⇒prefer(Path::Tiny);
  export⇒'use Exporter import'+@EXPORT_OK∧¬default_export;
  runtime_load⇒Module::Runtime::require_module∧¬eval('require $m');
  ctor⇒Class->new∧¬indirect_obj_syntax;
  ¬no_strict_refs∧¬sym_refs⇒use_hash;
  mutable_our_cfg_globals→use_constant∨Moo_attr_defaults;
  deps:pin(cpanfile)∧run_install(carton);lint:perlcritic;fmt:perltidy;
}
§D{
  err_handle∧perl<5.40⇒Try::Tiny(try{}catch{$_})¬bare_eval_if($@)_complex;
  err_handle∧perl≥5.40⇒native_try{}catch($e){}¬Try::Tiny_new_code;
  simple_1off_fail_chk⇒eval{...};die("...: $@")if($@)¬silent_eval_without_$@_chk;
  new_class∧perl≥5.38∧¬CPAN_deps⇒use_feature_class(field:param,method,exp)¬blessed_hashref;
  new_class∧req(types∨roles)⇒Moo+Moo::Role+requires¬unneeded_Moose∨blessed_hashref;
  iter_kv⇒for_my($k,$v)(%h)(for_list,stable_5.40)¬manual_each(5.40+);
  booleans⇒use_builtin(true,false)(5.36+,exp)¬magic_1_empty_in_APIs;
}
§REF{
  code_examples,layout,perltidy/perlcritic/cpanfile_cfg,anti-patterns→references/idioms.md;
  input_handling,taint_mode,regex_safety,file_proc_ops,DBI,XSS/CSRF,sessions,perlcritic_sec→references/perl-security.md;
  Test2::V0,Test::More,prove,Test::MockModule,Devel::Cover→references/perl-testing.md;
}
§REL{
  ../secure-coding/SKILL.md:general_sec_checklists;
  ../database-design/SKILL.md:DBI,DBIx::Class_schema_design;
  ../systematic-debugging/SKILL.md:failing_tests,runtime_errors_root_cause;
}
