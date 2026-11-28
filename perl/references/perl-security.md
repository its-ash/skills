@REF:perl-security
§REL{[../SKILL.md](../SKILL.md),idioms.md,perl-testing.md}
§USE{user_input∨web_app∈{CGI,Mojolicious,Dancer2,Catalyst}∨sec_review∨user_path∨cmd_exec∨DBI_SQL∨auth/crypto∨dep_audit}
§RUNTIME{
  perl_version:stay_on_supported_Perl(≥5.40;5.42_patched_CVE-2024-56406_tr//_heap_overflow+CVE-2025-40909_threads_cwd_race;2026_core_patched_CVE-2026-8376_32bit_regex_overflow);
  baseline:`use v5.40;` (or `use v5.42;` for auto `source::encoding` + no `switch`/smartmatch);
}
§TAINT{
  enable:`#!/usr/bin/perl -T` ∧ `use v5.40;`;
  tainted_src:{`$ARGV[0]`,`$ENV{PATH}`,`<STDIN>`,`$ENV{QUERY_STRING}`,network/file_input};
  env_sanitization:`$ENV{PATH}='/usr/local/bin:/usr/bin:/bin'; delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};`;
  untaint_pat:strict_anchored_capture⇒`$1`_untainted{
    username:`/^([a-zA-Z0-9_]{3,30})$/`,
    filename:`m{^([a-zA-Z0-9._-]+)$}`
  };
  ¬permissive_untaint:`/^(.*)$/s` (defeats_taint);
}
§INPUT{
  allowlist>blocklist:`my %allowed = map { $_ => 1 } qw(name email created_at updated_at); die unless $allowed{$field};`;
  email:`/^([a-zA-Z0-9._%+-]+\@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$/`;
  int:`/^(-?\d{1,10})$/`→`$1 + 0`;
  len_bounds:`length($t) > 0 && length($t) <= 10_000`;
  web_validator:prefer_`Mojo::Validation` (`$c->validation->required('username')->size(3,30)->like(qr/^\w+$/)`);
  ¬blocklist:`/[<>"';&|]/` (misses_encoded_attacks);
}
§REGEX{
  ¬ReDoS_nested_quantifiers:{`qr/^(a+)+$/`,`qr/^([a-zA-Z]+)*$/`,`qr/^(.*?,){10,}$/`};
  safe_flat:`qr/^a+$/`, `qr/^[a-zA-Z]+$/`, possessive:`qr/^[a-zA-Z]++$/`, atomic:`qr/^(?>a+)$/`;
  timeout_untrusted:
  ```perl
  sub safe_match($s, $re, $timeout = 2) {
      my $m;
      eval { local $SIG{ALRM} = sub { die "Regex timeout\n" }; alarm($timeout); $m = $s =~ $re; alarm(0); };
      alarm(0); die $@ if $@; return $m;
  }
  ```
}
§FILE{
  read_3arg:`open my $fh, '<:encoding(UTF-8)', $path or die "Cannot open '$path': $!\n"; local $/; my $c = <$fh>; close $fh;`;
  ¬open_2arg:`open my $fh, $path` ∨ `open my $fh, "< $path"` (cmd/shell_inj e.g.`"|rm -rf /"`);
  atomic_create_TOCTOU:`use Fcntl qw(:DEFAULT :flock); sysopen(my $fh, $path, O_WRONLY|O_CREAT|O_EXCL, 0600) or die "...: $!\n";`;
  temp_lock:`File::Temp::tempfile(UNLINK => 1)` ∧ `flock($fh, LOCK_EX)`;
  traversal_guard:
  ```perl
  use File::Spec; use Cwd qw(realpath);
  sub safe_path($base, $user) {
      my $real = realpath(File::Spec->catfile($base, $user)) // die "Path does not exist\n";
      my $base_real = realpath($base) // die "Base dir does not exist\n";
      die "Path traversal blocked\n" unless $real =~ /^\Q$base_real\E(?:\/|\z)/;
      return $real;
  }
  ```
  write_new_file:`realpath` returns `undef` for non-existent targets⇒validate `realpath` on parent dir + strict filename allowlist (`m{^[a-zA-Z0-9._-]+$}`);
}
§PROC{
  safe_list_form:`system('/usr/bin/grep', '--', $pat, $file) == 0 or die "Command failed\n";` ∧ `exec(@cmd)` (¬shell_interp; `'--'` blocks `--option` arg_injection);
  capture:`IPC::Run3::run3(\@cmd, \undef, \$stdout, \$stderr)` (check `$?`) ∨ `Capture::Tiny`;
  ¬shell_interp:{`system("grep -r '$pat' ...")`,`my $out = \`ls $user_dir\``};
}
§SQL{
  dbi_opts:`DBI->connect($dsn, $user, $pass, { RaiseError => 1, PrintError => 0, AutoCommit => 1, TaintIn => 1, TaintOut => 1 })` (`TaintIn`/`TaintOut` when `-T` active);
  placeholders:`prepare('SELECT * FROM users WHERE email = ?')->execute($email)` ∧ `LIKE ?`→`"%$name%"`;
  ¬interp:`prepare("... '$email'")` (SQLi e.g.`"' OR 1=1 --"`);
  dynamic_order_by:allowlist(`%allowed_cols = map { $_ => 1 } qw(name email created_at)`, `%allowed_dirs = map { $_ => 1 } qw(ASC DESC)` checked via `uc $dir`);
  orm_safe:`DBIx::Class` `$schema->resultset('User')->search({ status => 'active', email => { -like => '%@example.com' } }, { order_by => { -asc => 'name' }, rows => 50 })`;
}
§CRYPTO{
  password_hash:`Crypt::Argon2` **>= 0.031** (fixes **CVE-2026-8463** heap OOB read on empty hash in `argon2_verify`):
  ```perl
  use Crypt::Argon2 qw(argon2id_pass argon2id_verify);
  use Crypt::URandom qw(urandom);
  my $hash = argon2id_pass($password, urandom(16), 3, '64M', 1);
  my $ok   = (defined $hash && length $hash) && argon2id_verify($hash, $password); # ALWAYS guard non-empty
  ```
  JWT:`Crypt::JWT` **>= 0.037_1** / latest patched (fixes **CVE-2026-8748** / **CVE-2026-136795** non-constant-time sig, zip-bomb/memory exhaustion, claim validation);
  random_tokens:`Crypt::URandom::urandom(32)`→`MIME::Base64::encode_base64url(...)` (¬`rand()`);
  const_time_cmp:`Crypt::Misc::slow_equals($a, $b)` (¬`eq` on secrets/HMACs/tokens);
}
§WEB{
  XSS_encode:{
    HTML:`HTML::Entities::encode_entities($s)`,
    URL:`URI::Escape::uri_escape_utf8($v)`,
    JSON:`JSON::MaybeXS::encode_json($data)`,
    Mojolicious:`<%= $in %>`(auto-escaped) vs `<%== $raw %>`(raw,trusted_only),
    TemplateToolkit:`[% user_input | html %]`
  };
  Mojolicious_ver:require **Mojolicious >= 9.48** (fixes **CVE-2026-77568** static session CSRF token BREACH side-channel via per-request masked tokens);
  CSRF_Mojo:render `<%= csrf_field %>` in form + verify `$c->validation->csrf_protect->has_error('csrf_token')` (return 403);
  session_headers_Mojo:
  ```perl
  $app->secrets(['long-random-secret-rotated-regularly']);
  $app->sessions->cookie_name('myapp_session');
  $app->sessions->secure(1);        # HTTPS only (HttpOnly is enabled by default)
  $app->sessions->samesite('Lax');  # or 'Strict'
  $app->sessions->encrypted(1);     # optional: encrypts session payload
  $app->hook(after_dispatch => sub ($c) {
      $c->res->headers->header('X-Content-Type-Options' => 'nosniff');
      $c->res->headers->header('X-Frame-Options' => 'DENY');
      $c->res->headers->header('Content-Security-Policy' => "default-src 'self'");
      $c->res->headers->header('Strict-Transport-Security' => 'max-age=31536000; includeSubDomains');
  });
  ```
}
§DEPS{
  pin_cpanfile:`requires 'DBI', '>= 1.656'; requires 'Mojolicious', '>= 9.48'; requires 'Crypt::Argon2', '>= 0.031';` + lockfile `cpanfile.snapshot` (`carton`/`cpm --snapshot`);
  audit_CLI:`cpan-audit installed` ∧ `cpan-audit cpanfile` ∧ `cpan-audit deps .` (CPAN::Audit vs CPAN Security Advisory DB; fail CI on advisories);
}
§TOOL{
  perlcriticrc:
  ```ini
  severity = 3
  theme = security + core
  [InputOutput::RequireCheckedSyscalls]
  functions = :builtins
  severity = 4
  [BuiltinFunctions::ProhibitStringyEval]
  severity = 5
  [InputOutput::ProhibitBacktickOperators]
  severity = 4
  [InputOutput::ProhibitTwoArgOpen]
  severity = 5
  [InputOutput::ProhibitBarewordFileHandles]
  severity = 5
  ```
  CLI:{`perlcritic --severity 3 --theme security lib/`, CI:`perlcritic --severity 4 --theme security --quiet lib/ || exit 1`};
}
§CHK{
  runtime:Perl≥5.40/5.42/5.44_patched;
  taint:`-T` on CGI/untrusted_CLI + sanitized `$ENV{PATH}`;
  input:allowlist_patterns+len_limits∨`Mojo::Validation`;
  file:3arg_open+`realpath`_traversal_guard+`O_EXCL`_create;
  proc:list_form_system+`'--'`_no_shell;
  sql:DBI_placeholders_never_interp+allowlisted_ORDER_BY;
  crypto:`Crypt::Argon2`≥0.031(non-empty_guard)+`Crypt::JWT`≥0.037_1+`Crypt::URandom`+`slow_equals`;
  html:`encode_entities()`∨template_autoescape;
  csrf:Mojolicious≥9.48+`csrf_field`/`csrf_protect`;
  session:Secure+HttpOnly+SameSite+rotated_secrets;
  headers:CSP+X-Frame-Options+HSTS+nosniff;
  deps:pinned_snapshot+`cpan-audit`_CI_gate;
  regex:¬nested_quantifiers+anchored+alarm_timeout;
  errors:¬stack_trace∨path_leak;
}
§ANTI{
  1:2arg_open_user_input(`open my $fh,$user_input`⇒RCE);
  2:string_system(`system("convert $user_file out.png")`⇒shell_inj)∨missing_`--`(arg_inj);
  3:sql_interp(`$dbh->do("DELETE FROM users WHERE id = $id")`⇒SQLi);
  4:string_eval(`eval $user_code`⇒RCE);
  5:unsanitized_ENV(`$ENV{UPLOAD_DIR}`+`system("ls $path")`⇒2x_vuln);
  6:lazy_untaint(`($in)=$in=~/(.*)/s`);
  7:raw_HTML(`print "<div>$username</div>"`⇒XSS);
  8:unvalidated_redirect(`print $cgi->redirect($user_url)`⇒open_redirect);
  9:empty_hash_verify(`argon2id_verify('',$pw)`_on_<0.031⇒heap_OOB_read);
  10:non_const_cmp(`$sig eq $expected`⇒timing_side_channel)∨`rand()`_for_tokens;
}
