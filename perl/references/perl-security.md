@REF:perl-security
§USE{user_input∨web_app∈{CGI,Mojolicious,Dancer2,Catalyst}∨sec_review∨user_path∨cmd_exec∨DBI_SQL}
§TAINT{
  enable:`#!/usr/bin/perl -T` ∧ `use v5.36;`;
  tainted_src:{$ARGV[0],$ENV{PATH},<STDIN>,$ENV{QUERY_STRING}};
  env_sanitization:`$ENV{PATH}='/usr/local/bin:/usr/bin:/bin'; delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};`;
  untaint_pat:strict_anchored_capture⇒$1_untainted{
    username:`/^([a-zA-Z0-9_]{3,30})$/`,
    filename:`m{^([a-zA-Z0-9._-]+)$}`
  };
  ¬permissive_untaint:`/^(.*)$/s` (defeats_taint)
}
§INPUT{
  allowlist>blocklist:`%allowed=map{$_=>1}qw(name email created_at updated_at); die unless $allowed{$field};`;
  email:`/^([a-zA-Z0-9._%+-]+\@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$/`;
  int:`/^(-?\d{1,10})$/`→`$1+0`;
  len_bounds:`length($t)>0 ∧ length($t)<=10_000`;
  ¬blocklist:`/[<>"';&|]/` (misses_encoded_attacks)
}
§REGEX{
  ¬ReDoS_nested_quantifiers:{`qr/^(a+)+$/`,`qr/^([a-zA-Z]+)*$/`,`qr/^(.*?,){10,}$/`};
  safe_flat:`qr/^a+$/`, `qr/^[a-zA-Z]+$/`, possessive(v5.10+):`qr/^[a-zA-Z]++$/`, atomic:`qr/^(?>a+)$/`;
  timeout_untrusted:`use POSIX qw(alarm);`($timeout=2):
  ```perl
  sub safe_match($s, $re, $timeout = 2) {
      my $m;
      eval { local $SIG{ALRM} = sub { die "Regex timeout\n" }; alarm($timeout); $m = $s =~ $re; alarm(0); };
      alarm(0); die $@ if $@; return $m;
  }
  ```
}
§FILE{
  read_3arg:`open my $fh,'<:encoding(UTF-8)',$path or die "Cannot open '$path': $!\n"; local $/; my $c=<$fh>; close $fh;`;
  ¬open_2arg:`open my $fh,$path` ∨ `open my $fh,"< $path"` (cmd/shell_inj e.g.`"|rm -rf /"`);
  atomic_create_TOCTOU:`use Fcntl qw(:DEFAULT :flock); sysopen(my $fh,$path,O_WRONLY|O_CREAT|O_EXCL,0600) or die "...: $!\n";`;
  temp_lock:`File::Temp::tempfile(UNLINK=>1)` ∧ `flock(LOCK_EX)`;
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
}
§PROC{
  safe_list_form:`system(@cmd)==0 or die "Command failed: @cmd\n";` ∧ `exec(@cmd)` (¬shell_interp);
  capture:`IPC::Run3::run3(\@cmd,\undef,\$stdout,\$stderr)`(check `$?`) ∨ `Capture::Tiny`;
  ¬shell_interp:{`system("grep -r '$pat' ...")`,`my $out=\`ls $user_dir\``}
}
§SQL{
  dbi_opts:`DBI->connect($dsn,$user,$pass,{RaiseError=>1,PrintError=>0,AutoCommit=>1})`;
  placeholders:`prepare('SELECT * FROM users WHERE email = ?')->execute($email)` ∧ `LIKE ?`→`"%$name%"`;
  ¬interp:`prepare("... '$email'")` (SQLi e.g.`"' OR 1=1 --"`);
  dynamic_order_by:allowlist(`%allowed_cols=qw(name email created_at)`, `%allowed_dirs=qw(ASC DESC)` checked via `uc $dir`);
  orm_safe:`DBIx::Class` `$schema->resultset('User')->search({status=>'active',email=>{-like=>'%@example.com'}},{order_by=>{-asc=>'name'},rows=>50})`
}
§WEB{
  XSS_encode:{
    HTML:`HTML::Entities::encode_entities($s)`,
    URL:`URI::Escape::uri_escape_utf8($v)`,
    JSON:`JSON::MaybeXS::encode_json($data)`,
    Mojolicious:`<%= $in %>`(auto-escaped) vs `<%== $raw %>`(raw,trusted_only),
    TemplateToolkit:`[% user_input | html %]`
  };
  CSRF:`Crypt::URandom::urandom(32)`→`MIME::Base64::encode_base64url(...)` + constant_time_cmp; prefer framework built-ins(Mojolicious,Dancer2,Catalyst);
  session_headers_Mojo:
  ```perl
  $app->secrets(['long-random-secret-rotated-regularly']);
  $app->sessions->secure(1); $app->sessions->samesite('Lax');
  $app->hook(after_dispatch => sub ($c) {
      $c->res->headers->header('X-Content-Type-Options' => 'nosniff');
      $c->res->headers->header('X-Frame-Options' => 'DENY');
      $c->res->headers->header('Content-Security-Policy' => "default-src 'self'");
      $c->res->headers->header('Strict-Transport-Security' => 'max-age=31536000; includeSubDomains');
  });
  ```
}
§DEPS{
  pin_cpanfile:`requires 'DBI', '== 1.643';`;
  audit:{check MetaCPAN recent releases, minimize dep count}
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
  CLI:{`perlcritic --severity 3 --theme security lib/MyApp/Handler.pm`, `perlcritic --severity 3 --theme security lib/`, CI:`perlcritic --severity 4 --theme security --quiet lib/ || exit 1`}
}
§CHK{
  taint:`-T` on CGI/web;
  input:allowlist_patterns+len_limits;
  file:3arg_open+realpath_traversal_guard;
  proc:list_form_system_no_shell;
  sql:DBI_placeholders_never_interp;
  html:`encode_entities()`∨template_autoescape;
  csrf:gen+verify_on_state_change;
  session:Secure+HttpOnly+SameSite;
  headers:CSP+X-Frame-Options+HSTS+nosniff;
  deps:pinned+audited;
  regex:¬nested_quantifiers+anchored;
  errors:¬stack_trace∨path_leak
}
§ANTI{
  1:2arg_open_user_input(`open my $fh,$user_input`⇒RCE);
  2:string_system(`system("convert $user_file out.png")`⇒shell_inj);
  3:sql_interp(`$dbh->do("DELETE FROM users WHERE id = $id")`⇒SQLi);
  4:string_eval(`eval $user_code`⇒RCE);
  5:unsanitized_ENV(`$ENV{UPLOAD_DIR}`+`system("ls $path")`⇒2x_vuln);
  6:lazy_untaint(`($in)=$in=~/(.*)/s`);
  7:raw_HTML(`print "<div>$username</div>"`⇒XSS);
  8:unvalidated_redirect(`print $cgi->redirect($user_url)`⇒open_redirect)
}
