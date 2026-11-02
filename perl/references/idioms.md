# Modern Perl Idioms

Examples for the rules in [`../SKILL.md`](../SKILL.md).

## Preamble and signatures

```perl
use v5.36;   # strict + warnings + say + signatures

sub connect_db($host, $port = 5432, $timeout = 30) {
    DBI->connect("dbi:Pg:host=$host;port=$port", undef, undef,
        { RaiseError => 1, PrintError => 0 });
}
sub log_message($level, @details) { say "[$level] " . join(' ', @details) }

# Bad: use strict; use warnings; use feature 'signatures'; my ($host, $port) = @_; $port //= 5432;
```

## Context, dereference, isa

```perl
my @copy  = @items;            # list context: all elements
my $count = @items;            # scalar context: count
say "Items: " . scalar @items; # force scalar

my @users = $data->{users}->@*;          # not @{ $data->{users} }
my %first = $data->{users}[0]->%*;
my @two   = $cfg->{db}{options}->@[0, 1]; # array slice
@subset{qw(host port)} = @{$cfg->{db}}{qw(host port)}; # hash slice
my $miss  = $cfg->{cache}{host};          # undef, no error (autovivifies {cache})

if ($obj isa 'My::Class') { ... }         # 5.32+, not blessed($o) && $o->isa(...)

use feature 'for_list'; no warnings 'experimental::for_list'; # stable in 5.40
for my ($k, $v) (%$cfg) { say "$k => $v" }
```

## Error handling

```perl
my $content = eval { path($p)->slurp_utf8 };
die "Config error: $@" if $@;

use Try::Tiny;   # pre-5.40; $_ holds the error; return value of block is the result
my $user = try { $rs->find($id) // die "User $id not found\n" }
           catch { warn "Failed $id: $_"; undef };

use v5.40;       # native
try { die "Division by zero" if $y == 0; return $x / $y }
catch ($e) { warn "Error: $e"; return }
```

## OO: Moo, roles, class

```perl
package User;
use Moo;
use Types::Standard qw(Str Int ArrayRef);
use namespace::autoclean;
has name  => (is => 'ro', isa => Str, required => 1);
has age   => (is => 'ro', isa => Int, default => sub { 0 });
has roles => (is => 'ro', isa => ArrayRef[Str], default => sub { [] });
sub is_admin($self) { grep { $_ eq 'admin' } $self->roles->@* }
1;
# Bad: sub new { my ($c, %a) = @_; bless \%a, $c }  (no validation, no accessors)

package Role::Serializable;
use Moo::Role;
use JSON::MaybeXS qw(encode_json);
requires 'TO_HASH';
sub to_json($self) { encode_json($self->TO_HASH) }
1;
# in class: with 'Role::Serializable';

use v5.38; use feature 'class'; no warnings 'experimental::class';
class Point {
    field $x :param;
    field $y :param;
    method magnitude() { sqrt($x**2 + $y**2) }
}
```

## Regex

```perl
my $log_re = qr{
    ^ (?<timestamp> \d{4}-\d{2}-\d{2} \s \d{2}:\d{2}:\d{2} )
    \s+ \[ (?<level> \w+ ) \]
    \s+ (?<message> .+ ) $
}x;
say "$+{timestamp} $+{level}" if $line =~ $log_re;   # not $1, $2

my $email_re = qr/^[A-Za-z0-9._%+-]+\@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;  # compile once
sub validate_emails(@e) { grep { $_ =~ $email_re } @e }
```

## File I/O

```perl
use autodie;   # core; removes `or die`
sub read_file($path) {
    open my $fh, '<:encoding(UTF-8)', $path;
    local $/;
    return scalar <$fh>;
}
# Bad: open FH, $path;  open FH, "< $path";  (see perl-security.md)

use Path::Tiny;
my $f = path('config', 'app.json');
my $c = $f->slurp_utf8;  $f->spew_utf8($new);
say $_->basename for path('src')->children(qr/\.pl$/);
```

## Modules and layout

```text
MyApp/
├── lib/MyApp/{App,Config,DB,Util}.pm
├── bin/myapp            # entry point
├── t/00-load.t, t/unit/, t/integration/
├── cpanfile
├── Makefile.PL
└── .perlcriticrc
```

```perl
package MyApp::Util;
use v5.36;
use Exporter 'import';          # not BEGIN { require Exporter; @ISA = ... }
our @EXPORT_OK   = qw(trim);
our %EXPORT_TAGS = (all => \@EXPORT_OK);
sub trim($s) { $s =~ s/^\s+|\s+$//gr }
1;
```

## Tooling

`.perltidyrc`: `-i=4 -l=100 -ci=4 -ce -bar -nolq` (4 indent, 100 cols, cuddled else, brace on same line, no outdent of long strings).

`.perlcriticrc`:
```ini
severity = 3
theme = core + pbp + security
[InputOutput::RequireCheckedSyscalls]
functions = :builtins
exclude_functions = say print
[Subroutines::ProhibitExplicitReturnUndef]
severity = 4
[ValuesAndExpressions::ProhibitMagicNumbers]
allowed_values = 0 1 2 -1
```

cpanfile + carton:
```perl
requires 'Moo', '>= 2.005';
requires 'Path::Tiny';
requires 'JSON::MaybeXS';
requires 'Try::Tiny';
on test => sub { requires 'Test2::V0'; requires 'Test::MockModule'; };
```
```bash
cpanm App::cpanminus Carton && carton install && carton exec -- perl bin/myapp
```

## Anti-patterns

| Bad | Good |
|---|---|
| `open FH, $file` | three-arg `open my $fh, '<', $file` |
| `new Foo(bar => 1)` (indirect object) | `Foo->new(bar => 1)` |
| `map { f($_) } grep { g($_) } @x` chains | split into named steps |
| `no strict 'refs'; ${"Pkg::$v"} = 1` | use a hash |
| `our $TIMEOUT = 30` mutable global | `use constant` or Moo attribute default |
| `eval "require $mod"` (code injection) | `Module::Runtime::require_module($mod)` |
| `builtin::true` without import | `use builtin 'true', 'false';` (5.36+, experimental) |
