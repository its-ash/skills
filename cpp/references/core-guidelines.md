# C++ Core Guidelines: rule catalog

Source: [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines). Each section: rules, one example, anti-patterns.

## Cross-cutting principles
| Principle | Rules |
|---|---|
| RAII everywhere | P.8, R.1, E.6, CP.20 |
| Immutability by default | P.10, Con.1-5, ES.25 |
| Type safety | P.4, I.4, ES.46-49, Enum.3 |
| Express intent | P.3, F.1, NL.1-2, T.10 |
| Minimize complexity | F.2-3, ES.5, Per.4-5 |
| Value over pointer semantics | C.10, R.3-5, F.20, CP.31 |

## Philosophy and interfaces (P, I)
| Rule | Summary |
|---|---|
| P.1 / P.3 | Express ideas and intent directly in code |
| P.4 / P.5 | Static type safety; compile-time over run-time checks |
| P.8 | Do not leak resources |
| P.10 | Prefer immutable data |
| I.1 / I.4 | Explicit, precisely and strongly typed interfaces |
| I.2 | No non-const globals |
| I.11 | Never transfer ownership by raw pointer or reference |
| I.23 | Keep argument count low |

```cpp
struct Temperature { double kelvin; };
Temperature boil(const Temperature& water);  // good: typed, clear units
double boil(double* temp);                   // bad: unclear ownership and units
```

## Functions (F)
| Rule | Summary |
|---|---|
| F.1-F.3 | Named, single-purpose, short functions |
| F.4 | `constexpr` if compile-time evaluable |
| F.6 | `noexcept` if it must not throw |
| F.8 | Prefer pure functions |
| F.16 | "In" params: cheap types by value, others by `const&`; sinks by value then move |
| F.20 / F.21 | Return values (a struct for several) over out-params |
| F.43 | Never return pointer/reference to a local |

```cpp
struct ParseResult { std::string token; int position; };
ParseResult parse(std::string_view input);                    // good
void parse(std::string_view in, std::string& tok, int& pos);  // bad: out-params
constexpr int factorial(int n) noexcept { return n <= 1 ? 1 : n * factorial(n - 1); }
static_assert(factorial(5) == 120);
```
Avoid: returning `T&&` (F.45); C variadics / `va_arg` (F.55); by-reference lambda capture for other threads (F.53); returning `const T` (blocks move, F.49).

## Classes (C)
| Rule | Summary |
|---|---|
| C.2 | `class` if invariant; `struct` if members vary independently |
| C.9 | Minimize member exposure |
| C.20 | Rule of Zero: avoid defining default operations |
| C.21 | Rule of Five: define or `=delete` one copy/move/dtor → handle all |
| C.35 | Base dtor: public virtual or protected non-virtual |
| C.41 | Constructor creates a fully initialized object |
| C.46 | Single-arg constructors `explicit` |
| C.67 | Polymorphic class suppresses public copy/move |
| C.121 | Pure interface = abstract class of pure virtuals |
| C.128 | Exactly one of `virtual`, `override`, `final` |

```cpp
struct Employee { std::string name; std::string department; int id; };  // Rule of Zero

class Shape {
public:
    virtual ~Shape() = default;
    virtual double area() const = 0;
};
class Circle : public Shape {
public:
    explicit Circle(double r) : radius_(r) {}
    double area() const override { return std::numbers::pi * radius_ * radius_; }
private:
    double radius_;
};
```
Avoid: virtual calls in ctor/dtor (C.82); `memset`/`memcpy` on non-trivial types (C.90); different default args in virtual and overrider (C.140); `const` or reference data members (block copy/move, C.12).

## Resource management (R)
| Rule | Summary |
|---|---|
| R.1 | RAII for all resources |
| R.3 | Raw `T*` is non-owning |
| R.5 | Prefer scoped objects; no needless heap |
| R.10 / R.11 | No `malloc`/`free`; no explicit `new`/`delete` |
| R.13 | One resource allocation per expression (exception safety) |
| R.20 / R.21 | `unique_ptr`/`shared_ptr` for ownership; `unique_ptr` unless shared |
| R.22 | `make_shared` for `shared_ptr` |

RAII handle (Rule of Five, move-only):
```cpp
class FileHandle {
public:
    explicit FileHandle(const std::string& path) : h_(std::fopen(path.c_str(), "r")) {
        if (!h_) throw std::runtime_error("Failed to open: " + path);
    }
    ~FileHandle() { if (h_) std::fclose(h_); }
    FileHandle(const FileHandle&) = delete;
    FileHandle& operator=(const FileHandle&) = delete;
    FileHandle(FileHandle&& o) noexcept : h_(std::exchange(o.h_, nullptr)) {}
    FileHandle& operator=(FileHandle&& o) noexcept {
        if (this != &o) { if (h_) std::fclose(h_); h_ = std::exchange(o.h_, nullptr); }
        return *this;
    }
private:
    std::FILE* h_;
};
```
For a copyable owner, copy-assign via a temp then move (`auto tmp = make_unique<char[]>(n); copy_n(...); data_ = std::move(tmp);`) for strong exception safety; `= default` the moves with `noexcept`.

## Expressions and statements (ES)
| Rule | Summary |
|---|---|
| ES.5 | Small scopes |
| ES.12 | Do not reuse names in nested scopes |
| ES.20 / ES.23 | Always initialize; prefer `{}` |
| ES.25 | `const`/`constexpr` unless mutation intended |
| ES.28 | Immediately invoked lambda for complex `const` init |
| ES.45 | Named constants, no magic numbers |
| ES.46 | No narrowing conversions |
| ES.47 | `nullptr`, not `0`/`NULL` |
| ES.48 / ES.50 | Avoid casts (named casts only); never cast away `const` |
| ES.100 | Do not mix signed and unsigned arithmetic |

```cpp
const auto config = [&] {
    Config c;
    c.timeout = std::chrono::seconds{30};
    c.retries = max_retries;
    return c;
}();
```

## Error handling (E)
| Rule | Summary |
|---|---|
| E.1 | Define the error strategy early |
| E.2 | Throw when a function cannot do its task |
| E.3 | No exceptions for flow control |
| E.6 | RAII prevents leaks |
| E.12 | `noexcept` when throwing is impossible or unacceptable |
| E.14 | Purpose-designed exception types, never `int` or string literals |
| E.15 | Throw by value, catch by reference (no slicing) |
| E.16 | Destructors, deallocation, `swap` never fail |
| E.17 | Do not catch everything in every function |
| E.28 | No error handling via globals like `errno` |

```cpp
class AppError : public std::runtime_error { using std::runtime_error::runtime_error; };
class NetworkError : public AppError {
public:
    NetworkError(const std::string& msg, int code) : AppError(msg), status_code(code) {}
    int status_code;
};
try { fetch_data(url); }
catch (const NetworkError& e) { log_error(e.what(), e.status_code); }
catch (const AppError& e) { log_error(e.what()); }  // let unknown errors propagate
```
Avoid empty catch blocks.

## Constants (Con)
| Rule | Summary |
|---|---|
| Con.1 | Objects immutable by default |
| Con.2 | Member functions `const` by default |
| Con.3 | Pass pointers/references to `const` by default |
| Con.4 | `const` for values fixed after construction |
| Con.5 | `constexpr` for compile-time values |

## Concurrency (CP)
| Rule | Summary |
|---|---|
| CP.2 / CP.3 | No data races; minimize shared writable data |
| CP.4 | Think in tasks, not threads |
| CP.8 | No `volatile` for sync (hardware I/O only) |
| CP.20 | RAII locks, never plain `lock()`/`unlock()` |
| CP.21 | `std::scoped_lock` for multiple mutexes |
| CP.22 | Never call unknown code (callbacks) under a lock |
| CP.26 | Do not detach threads |
| CP.42 | Never wait without a condition |
| CP.44 | Name every `lock_guard`/`unique_lock` |
| CP.50 | Keep the mutex with the data it guards |
| CP.100 | No lock-free code unless you must |

```cpp
void push(int v) { std::lock_guard lock(m_); q_.push(v); cv_.notify_one(); }
int pop() {
    std::unique_lock lock(m_);
    cv_.wait(lock, [this] { return !q_.empty(); });
    const int v = q_.front(); q_.pop(); return v;
}
void transfer(Account& a, Account& b, double amt) { std::scoped_lock lock(a.m_, b.m_); a.bal_ -= amt; b.bal_ += amt; }
std::lock_guard<std::mutex>(m_);  // bad: unnamed, unlocks at once
```

## Templates (T)
| Rule | Summary |
|---|---|
| T.1 / T.2 | Templates raise abstraction; algorithms over many types |
| T.10 / T.11 | Concepts on every template argument; standard concepts first |
| T.13 | Shorthand syntax for simple concepts |
| T.43 | `using`, not `typedef` |
| T.47 | No unconstrained templates in visible namespaces |
| T.120 | Metaprogramming only when `constexpr` cannot do it |
| T.144 | Overload; do not specialize function templates |

```cpp
template<std::integral T> T gcd(T a, T b) { while (b != 0) a = std::exchange(b, a % b); return a; }
void sort(std::ranges::random_access_range auto& r) { std::ranges::sort(r); }
template<typename T>
concept Serializable = requires(const T& t) { { t.serialize() } -> std::convertible_to<std::string>; };
```

## Standard library (SL)
| Rule | Summary |
|---|---|
| SL.1 / SL.2 | Use libraries; standard library first |
| SL.con.1 / SL.con.2 | `std::array`/`std::vector` over C arrays; `vector` by default |
| SL.str.1 / SL.str.2 | `std::string` owns; `std::string_view` observes |
| SL.io.50 | `'\n'`, not `std::endl` (forces flush) |

## Enumerations (Enum)
| Rule | Summary |
|---|---|
| Enum.1 | Enums (or `constexpr`) over macros |
| Enum.3 | `enum class` over plain `enum` |
| Enum.5 | No ALL_CAPS enumerators |
| Enum.6 | No unnamed enums |

```cpp
enum class Color { red, green, blue };  // good
enum { RED, GREEN, BLUE };              // bad: Enum.3, .5, .6
#define MAX_SIZE 100                     // bad: Enum.1, use constexpr
```

## Source files and naming (SF, NL)
| Rule | Summary |
|---|---|
| SF.1 | `.cpp` for code, `.h` for interfaces |
| SF.7 | No global `using namespace` in headers |
| SF.8 | Include guards (or `#pragma once`) in every header |
| SF.10 / SF.11 | Self-contained headers; no include-order dependency |
| NL.5 | No Hungarian notation (`strName`, `iCount`) |
| NL.8 / NL.10 | Consistent `underscore_style` |
| NL.9 | ALL_CAPS only for macros |

```cpp
#ifndef PROJECT_MODULE_WIDGET_H
#define PROJECT_MODULE_WIDGET_H
#include <string>
namespace project::module {
constexpr int max_buffer_size = 4096;
class tcp_connection {
public:
    void send_message(std::string_view msg);
private:
    std::string host_;  // trailing underscore for members
};
}  // namespace project::module
#endif  // PROJECT_MODULE_WIDGET_H
```

## Performance (Per)
| Rule | Summary |
|---|---|
| Per.1 / Per.2 | No optimization without reason; not prematurely |
| Per.4 / Per.5 | Clear abstractions over "clever" low-level code |
| Per.6 | No performance claims without measurement |
| Per.7 | Design to enable optimization |
| Per.10 | Rely on the static type system |
| Per.11 | Move computation to compile time |
| Per.19 | Access memory predictably (contiguous data) |

```cpp
constexpr auto squares = [] { std::array<int, 256> t{}; for (int i = 0; i < 256; ++i) t[i] = i * i; return t; }();
std::vector<Point> points;                        // good: contiguous
std::vector<std::unique_ptr<Point>> indirect;     // bad: pointer chasing
```
