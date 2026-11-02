# Rust Idioms

Examples for the rules in [`../SKILL.md`](../SKILL.md).

## Ownership

```rust
fn process(data: &[u8]) -> usize { data.len() }          // borrow when you only read
fn store(data: Vec<u8>) -> Record { Record { payload: data } } // own when you store/consume
// Bad: fn f(d: &Vec<u8>) { let c = d.clone(); c.len() }  (needless clone; take &[u8])

use std::borrow::Cow;
fn normalize(s: &str) -> Cow<'_, str> {
    if s.contains(' ') { Cow::Owned(s.replace(' ', "_")) } else { Cow::Borrowed(s) } // zero-cost path
}
```

## Errors

```rust
use anyhow::{bail, Context, Result};   // application
fn load_config(path: &str) -> Result<Config> {
    let s = std::fs::read_to_string(path).with_context(|| format!("failed to read config from {path}"))?;
    toml::from_str(&s).with_context(|| format!("failed to parse config from {path}"))
}
fn run() -> Result<()> {
    let cfg = load_config("app.toml")?;
    if cfg.workers == 0 { bail!("worker count must be > 0"); }
    Ok(())
}
// Bad: std::fs::read_to_string(path).unwrap()

use thiserror::Error;                  // library
#[derive(Debug, Error)]
pub enum StorageError {
    #[error("record not found: {id}")] NotFound { id: String },
    #[error("connection failed")]      Connection(#[from] std::io::Error),
    #[error("invalid data: {0}")]      InvalidData(String),
}

fn email(users: &[User], id: u64) -> Option<String> {   // Option combinators, not nested match
    users.iter().find(|u| u.id == id).map(|u| u.email.clone())
}
```

## Enums and matching

```rust
enum ConnectionState {
    Disconnected,
    Connecting { attempt: u32 },
    Connected { session_id: String },
    Failed { reason: String, retries: u32 },
}
match state {
    ConnectionState::Disconnected => connect(),
    ConnectionState::Connecting { attempt } if *attempt > 3 => abort(),
    ConnectionState::Connecting { .. } => wait(),
    ConnectionState::Connected { session_id } => use_session(session_id),
    ConnectionState::Failed { retries, .. } if *retries < 5 => retry(),
    ConnectionState::Failed { reason, .. } => log_failure(reason),
}
// Bad: match cmd { Command::Start => start(), _ => {} }  (hides new variants)
```

## Traits, generics, newtypes, builders

```rust
fn read_all(r: &mut impl Read) -> std::io::Result<Vec<u8>> {   // generic in, concrete out
    let mut buf = Vec::new(); r.read_to_end(&mut buf)?; Ok(buf)
}
fn process<T: Display + Send + 'static>(item: T) -> String { format!("processed: {item}") }

trait Handler: Send + Sync { fn handle(&self, req: &Request) -> Response; }
struct Router { handlers: Vec<Box<dyn Handler>> }               // heterogeneous / plugins
fn fast<H: Handler>(h: &H, req: &Request) -> Response { h.handle(req) } // monomorphized

struct UserId(u64);
struct OrderId(u64);
fn get_order(user: UserId, order: OrderId) -> Result<Order> { ... } // cannot swap args

impl ServerConfig {
    fn builder(host: impl Into<String>, port: u16) -> ServerConfigBuilder {
        ServerConfigBuilder { host: host.into(), port, max_connections: 100 }
    }
}
impl ServerConfigBuilder {
    fn max_connections(mut self, n: usize) -> Self { self.max_connections = n; self }
    fn build(self) -> ServerConfig { ServerConfig { host: self.host, port: self.port, max_connections: self.max_connections } }
}
// ServerConfig::builder("localhost", 8080).max_connections(200).build()
```

## Iterators

```rust
let active: Vec<String> = users.iter().filter(|u| u.is_active).map(|u| u.email.clone()).collect();
let names: Vec<_> = items.iter().map(|i| &i.name).collect();
let lookup: HashMap<_, _> = items.iter().map(|i| (i.id, i)).collect();
let joined: String = parts.iter().copied().collect();
let parsed: Result<Vec<i32>, _> = strs.iter().map(|s| s.parse()).collect(); // stops at first error
```

## Concurrency

```rust
let counter = Arc::new(Mutex::new(0));
let hs: Vec<_> = (0..10).map(|_| {
    let c = Arc::clone(&counter);
    std::thread::spawn(move || { *c.lock().expect("mutex poisoned") += 1; })
}).collect();
for h in hs { h.join().expect("worker thread panicked"); }

let (tx, rx) = std::sync::mpsc::sync_channel(16);   // bounded = backpressure
for i in 0..5 { let tx = tx.clone(); std::thread::spawn(move || tx.send(format!("message {i}")).expect("receiver disconnected")); }
drop(tx);                                           // else `for msg in rx` never ends
for msg in rx { println!("{msg}"); }

async fn fetch_with_timeout(url: &str) -> Result<String> {
    let res = tokio::time::timeout(Duration::from_secs(5), reqwest::get(url))
        .await.context("request timed out")?.context("request failed")?;
    res.text().await.context("failed to read body")
}
async fn fetch_all(urls: Vec<String>) -> Vec<Result<String>> {
    let hs: Vec<_> = urls.into_iter().map(|u| tokio::spawn(async move { fetch_with_timeout(&u).await })).collect();
    let mut out = Vec::with_capacity(hs.len());
    for h in hs { out.push(h.await.unwrap_or_else(|e| panic!("spawned task panicked: {e}"))); }
    out
}
```

## Unsafe

```rust
/// # Safety
/// `ptr` must be a valid, aligned pointer to an initialized `Widget`.
unsafe fn widget_from_raw<'a>(ptr: *const Widget) -> &'a Widget {
    // SAFETY: caller guarantees ptr is valid and aligned
    unsafe { &*ptr }   // Rust 2024: unsafe block required inside unsafe fn
}
// SAFETY: index < len due to loop bound
unsafe { slice.get_unchecked(index) }
```
Reject: unsafe to bypass the borrow checker, unsafe for convenience, unsafe without `SAFETY`, `transmute` between unrelated types.

## Crate layout and visibility

```text
my_app/
├── src/{main.rs, lib.rs}
├── src/auth/{mod.rs, token.rs, middleware.rs}    # domain
├── src/orders/{mod.rs, model.rs, service.rs}     # domain
├── src/db/{mod.rs, pool.rs}                      # infrastructure
├── tests/     # integration
├── benches/
└── Cargo.toml
```
```rust
pub(crate) fn validate_input(s: &str) -> bool { !s.is_empty() }
pub mod auth;
pub use auth::AuthMiddleware;   // re-export public API from lib.rs
```

## Cargo commands

| Command | Use |
|---|---|
| `cargo check` | fast type check, no codegen |
| `cargo clippy` / `cargo fmt` | lint / format |
| `cargo test -- --nocapture` | show `println!` output |
| `cargo test --lib` / `--test integration` | unit only / one integration file |
| `cargo audit` | security audit of deps |
| `cargo tree` / `cargo update` | dependency tree / update |
| `cargo bench` | benchmarks |

## Anti-patterns

| Bad | Good |
|---|---|
| `map.get("k").unwrap()` in production | `?`, `ok_or`, `context` |
| `.clone()` only to silence the borrow checker | restructure borrows |
| `fn greet(name: String)` that only reads | `fn greet(name: &str)` |
| `Box<dyn Error>` in a library API | `thiserror` enum |
| `let _ = validate(x);` on a `Result` | handle or propagate |
| `std::thread::sleep` in async | `tokio::time::sleep(..).await` |
