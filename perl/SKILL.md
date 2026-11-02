---
name: perl
description: "Modern Perl 5.36+ idioms: use v5.36, subroutine signatures, context, postfix dereference, isa, error handling with Try::Tiny and try/catch, Moo OO and roles, class keyword, named-capture regex, three-argument open, Path::Tiny, module layout, perltidy, perlcritic, cpanfile, and carton. Use when writing, reviewing, or modernizing .pl, .pm, or .t code, CPAN modules, Mojolicious, Dancer2, Catalyst, DBI, taint mode, or Perl tests. Sub-skills: perl-security, perl-testing."
---
# Modern Perl

Write idiomatic Perl 5.36+ with signatures, explicit modules, and safe I/O.

## Core rules
- Start each file with `use v5.36;` (strict, warnings, say, signatures). Do not write the legacy `use strict; use warnings; use feature` block.
- Use subroutine signatures with defaults and slurpy params. Do not unpack `@_` by hand.
- Know the context: `my $n = @a` gives the count; `scalar @a` forces scalar.
- Use postfix dereference (`$r->@*`, `$r->%*`, `$r->@[0,1]`) in chains.
- Use `$o isa 'Class'` (5.32+), not `blessed($o) && $o->isa(...)`.
- Use Moo with `Types::Standard` and `namespace::autoclean` for OO. Use Moose only when you need its metaprotocol.
- Use named captures (`(?<name>...)`, `$+{name}`) with `/x` for complex regex. Precompile with `qr//` when you reuse a pattern.
- Use three-argument `open` with an encoding layer, plus `autodie`. Never use two-argument `open`.
- Prefer `Path::Tiny` for file operations.
- Export with `use Exporter 'import'` and `@EXPORT_OK`. Do not export by default.
- Load modules at runtime with `Module::Runtime::require_module`. Never use string `eval "require $m"`.
- Call constructors as `Class->new`. Never use indirect object syntax.
- Do not use `no strict 'refs'` or symbolic references; use a hash.
- Replace mutable `our` config globals with `use constant` or Moo attribute defaults.
- Pin deps in `cpanfile`; install and run with `carton`. Lint with `perlcritic` and format with `perltidy`.

## Decisions

| Situation | Do | Avoid |
|---|---|---|
| Error handling, perl < 5.40 | `Try::Tiny` (`try {} catch { $_ }`) | bare `eval {}; if ($@)` for complex flows |
| Error handling, perl ≥ 5.40 | native `try {} catch ($e) {}` | Try::Tiny in new code |
| Simple one-off failure check | `eval { ... }; die "...: $@" if $@` | silent `eval` with no `$@` check |
| New class, perl ≥ 5.38, no CPAN deps wanted | `use feature 'class'` (`field :param`, `method`; experimental) | blessed hashref |
| New class, needs types/roles | Moo + `Moo::Role` with `requires` | Moose without need, blessed hashref |
| Iterate key/value pairs | `for my ($k, $v) (%h)` (`for_list`; stable 5.40) | manual `each` loops on 5.40+ |
| Booleans | `use builtin 'true', 'false';` (5.36+, experimental) | magic `1`/`''` in APIs |

## Load on demand

| Need | Read |
|---|---|
| Code examples, layout, perltidy/perlcritic/cpanfile config, anti-pattern table | [references/idioms.md](references/idioms.md) |
| Input handling, taint mode, regex safety, file and process ops, DBI, XSS/CSRF, sessions, perlcritic security | [references/perl-security.md](references/perl-security.md) |
| Test2::V0, Test::More, prove, Test::MockModule, Devel::Cover | [references/perl-testing.md](references/perl-testing.md) |

## Related skills
- [`secure-coding`](../secure-coding/SKILL.md) — general secure coding checklists.
- [`database-design`](../database-design/SKILL.md) — schema design for DBI and DBIx::Class.
- [`systematic-debugging`](../systematic-debugging/SKILL.md) — root cause of failing tests and runtime errors.
