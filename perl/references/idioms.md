@REF:idioms
§REL{[../SKILL.md](../SKILL.md),perl-security.md,perl-testing.md}
§VER{
  v5.40(Jun_2024,prod_baseline):enables{strict,warnings,say,signatures,try/catch(stable),for_list(stable),^^_xor,builtin_lexical_imports(true,false,trim,indexed,is_bool,blessed,reftype,refaddr,weaken,unweaken,is_weak,ceil,floor,is_tainted)}+Test2::Suite_in_core+class(:reader,__CLASS__);
  v5.42(Jul_2025):adds{source::encoding(auto_ascii/utf8_guard),class(:writer,my_method,->&),CORE::chdir_subref,Unicode_16.0,exp:any/all,disable_apostrophe_pkg_sep}+turns_OFF(switch/given/when/~~_by_default)+sec_fixes(CVE-2024-56406,CVE-2025-40909);
  v5.44(Jul_2026,latest_stable):adds{exp:named_sig_params(:$opt),aliased_ref_multi_for(for my($k,\@v)(%h)),exp:enhanced_xx,Unicode_17.0,PRNG_seeding,rewritten_perlxs}+strict(Unicode_ident/regex_group,¬goto_into_block);
  v5.36(legacy_LTS_floor):enables{strict,warnings,say,signatures}+exp(builtin,for_list,defer);use_only_when_targeting_older_OS_Perls;
}
§SIG{
  standard:`use v5.40; sub connect_db($h, $p = 5432, $t = 30) { DBI->connect("dbi:Pg:host=$h;port=$p", undef, undef, { RaiseError => 1, PrintError => 0 }) }`;
  slurpy:`sub log_msg($lvl, @data) { ... }` ∧ optional_unnamed:`sub cb($, $val) { ... }`;
  named_5.44_exp:`use v5.44; use experimental 'signature_named_parameters'; sub create_user($name, :$email, :$active = true) { ... }`;
  ¬manual_unpack:`my ($h, $p) = @_; $p //= 5432;` (obsolete_since_5.36);
}
§CTX{
  list_vs_scalar:`@copy = @items`(list) ∧ `$cnt = @items`(scalar) ∧ `scalar @items`(force_scalar);
  postfix_deref:`$d->{users}->@*`(¬`@{...}`), `$d->{users}[0]->%*`, `$c->{db}{opts}->@[0,1]`(arr_slice), `@sub{qw(host port)} = $c->{db}->%{qw(host port)}`(hash_slice);
  autoviv_guard:`$c->{cache}{host}`_creates`$c->{cache}`_on_read⇒check`exists $c->{cache}`_first_or_use`autovivification`;
  type_chk:`$obj isa 'My::Class'`(≥5.32,¬`blessed($obj) && $obj->isa(...)`);
  iter_5.40:`for my ($k, $v) (%$cfg) { ... }` ∧ `for my ($i, $val) (indexed(@list)) { ... }` (both_stable_in_5.40;indexed_opt_in_5.42);
  iter_alias_5.44:`use v5.44; use experimental 'refaliasing'; for my ($k, \@items) (%hash) { ... }`;
  builtin_5.40:`use v5.40;`⇒`true`,`false`,`trim($s)`(Unicode_whitespace),`indexed(@a)`,`is_bool($v)`_ready_without_explicit_import;
  xor_5.40:`$a ^^ $b`(medium-precedence_logical_XOR);
}
§ERR{
  native_5.40+:`use v5.40; try { my $d = load_cfg($p); return $d; } catch ($e) { warn $e; return; }`;
  defer_5.36+:`use feature 'defer'; defer { close $fh };` (runs_on_scope_exit_even_on_die/return);
  pre_5.40:`use Try::Tiny; try { ... // die "...\n" } catch { warn $_; undef };` (`$_`=err,blk_ret=res);
  simple_eval:`eval { path($p)->slurp_utf8 }; die "Read failed: $@" if $@;`;
}
§OO{
  ¬blessed_hashref:`bless \%args, $class` (avoid_manual_OO);
  Moo_prod:
  ```perl
  package User;
  use v5.40;
  use Moo;
  use Types::Standard qw(Str Int ArrayRef);
  use namespace::autoclean;
  has name  => (is => 'ro', isa => Str, required => 1);
  has age   => (is => 'ro', isa => Int, default => sub { 0 });
  has roles => (is => 'ro', isa => ArrayRef[Str], default => sub { [] });
  sub has_roles($self) { scalar $self->roles->@* }
  1;
  ```
  Moo_Role:`use Moo::Role; use JSON::MaybeXS qw(encode_json); requires 'TO_HASH'; sub to_json($self) { encode_json($self->TO_HASH) }` + `with 'Role::Serializable';`;
  Corinna_core_class(exp_5.38-5.44):
  ```perl
  use v5.42;
  use experimental 'class';
  class Point {
      field $x :param :reader :writer = 0; # :reader(5.40+), :writer(5.42+)
      field $y :param :reader = 0;
      my method sq($n) { $n * $n }         # lexical method (5.42+)
      method magnitude() { sqrt($self->&sq($x) + $self->&sq($y)) }
      method type_name() { __CLASS__ }     # runtime subclass-aware (5.40+)
  }
  ```
  Moose:use_only_when_requiring_full_MOP/metaclass_introspection;
}
§RE{
  named_captures:`qr{^(?<ts>\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})\s+\[(?<lvl>\w+)\]\s+(?<msg>.+)$}x`→`$+{ts}`,`$+{lvl}` (¬`$1`,`$2`);
  precompile:`my $EMAIL_RE = qr/^[A-Za-z0-9._%+-]+\@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;`;
  char_class_5.44:`/xx` restricts unescaped `#` & literal vertical whitespace inside `[...]` (`enhanced_xx` exp allows multiline commented classes);
}
§IO{
  std_3arg:`use autodie; open my $fh, '<:encoding(UTF-8)', $path; local $/; my $text = <$fh>;` (¬2arg_open,cf.perl-security.md);
  Path_Tiny:`use Path::Tiny; my $cfg = path('config', 'app.json')->slurp_utf8; path('out.txt')->spew_utf8($data); my @pl = path('src')->children(qr/\.pl$/);`;
  src_encoding_5.42+:`use source::encoding 'ascii';`(auto_under_`use v5.42;`) catches accidental non-ASCII bytes when `use utf8;` omitted;
}
§MOD{
  layout:`MyApp/{lib/MyApp/{App,Config,DB,Util}.pm,bin/myapp,t/{00-load.t,unit/,integration/},cpanfile,cpanfile.snapshot,Makefile.PL,.perltidyrc,.perlcriticrc,.yath.rc}`;
  exporter:`use Exporter 'import'; our @EXPORT_OK = qw(normalize_slug); our %EXPORT_TAGS = (all => \@EXPORT_OK);` (¬`BEGIN{require Exporter;@ISA=...}`,¬default_`@EXPORT`);
  runtime_load:`use Module::Runtime qw(require_module); require_module($mod);` (portable) ∨ `use builtin 'load_module'; load_module($mod);` (exp_5.40+);
  trim:use_core_`trim($s)`(5.40+)¬manual_`$s =~ s/^\s+|\s+$//gr`;
}
§CFG{
  perltidyrc:`-i=4 -l=100 -ci=4 -ce -bar -nolq` (4ind,100col,cuddled_else,same_brace,no_outdent_long);
  perlcriticrc:`severity=3; theme=core+pbp+security; [InputOutput::RequireCheckedSyscalls](functions=:builtins,exclude_functions=say print); [Subroutines::ProhibitExplicitReturnUndef](severity=4); [ValuesAndExpressions::ProhibitMagicNumbers](allowed_values=0 1 2 -1)` + consider `Perl::Critic::Community`;
  cpanfile:`requires 'perl', '5.040'; requires 'Moo', '>= 2.005'; requires 'Path::Tiny'; requires 'JSON::MaybeXS'; on test => sub { requires 'Test2::V0'; };` (note:`Test2::V0`_in_core_≥5.40,declare_only_for_<5.40_compat);
}
§CMD{
  runtime:`perlbrew install perl-5.44.0 && perlbrew use perl-5.44.0` (or `plenv`);
  deps_fast:`cpm install --cpanfile cpanfile` ∧ locked:`cpm install --snapshot cpanfile.snapshot` (parallel_installer,faster_than_cpanm);
  deps_carton:`carton install && carton exec -- perl bin/myapp` (generates `cpanfile.snapshot`);
  audit:`cpan-audit installed` ∧ `cpan-audit cpanfile` ∧ `cpan-audit deps .`;
  LSP:`PerlNavigator`(default_VSCode/Neovim_LSP,integrates_perltidy+perlcritic) ∨ `PLS`;
}
§ANTI{
  2arg_open:`open FH,$file`⇒`open my $fh,'<:encoding(UTF-8)',$file`;
  indirect_obj:`new Foo(bar=>1)`⇒`Foo->new(bar=>1)`;
  smartmatch:`$x ~~ @y` ∨ `given/when`⇒explicit_`any`/`grep`/`if-elsif`(deprecated_5.38,off_in_5.42+);
  sym_refs:`no strict 'refs'; ${"Pkg::$v"}=1`⇒lexical_hash;
  mutable_our:`our $TIMEOUT=30`⇒`use constant`∨Moo_default;
  string_require:`eval "require $mod"`⇒`Module::Runtime::require_module($mod)`;
  legacy_bool:`return 1 / return ''`⇒`true / false` (stable_auto-import_in_5.40+);
  apostrophe_sep:`Pkg'var`⇒`Pkg::var`(disabled_option_in_5.42+);
  goto_into_block:`goto LABEL`_entering_loop/block⇒refactor(forbidden_in_5.44+);
}
