@REF:idioms
§REL{../SKILL.md:rules;./rust-testing.md:nextest,miri,cov,bench}

§CFG{
  edition_2024:edition="2024"∧rust-version="1.85"(MSRV)∧[workspace]resolver="3"(MSRV_aware_dep_resolution);
  ws_deps:[workspace.dependencies]→member:crate={workspace=true,default-features=false}(2024_override);
  ws_lints_rust:[workspace.lints.rust]{unsafe_op_in_unsafe_fn="deny",missing_docs="warn"};
  ws_lints_clippy:[workspace.lints.clippy]{pedantic={level="warn",priority=-1},unwrap_used="deny",expect_used="deny",undocumented_unsafe_blocks="deny",allow_attributes="warn",allow_attributes_without_reason="warn"};
  member_lints:[lints]workspace=true;
  lint_override:#[expect(clippy::expect_used,reason="4-bit mask guarantees 0..=15")]≻#[allow(..)](warns_if_stale);
  layout:my_app/{Cargo.toml,src/{main.rs,lib.rs,auth/{mod.rs,token.rs,middleware.rs},orders/{mod.rs,model.rs,service.rs},db/{mod.rs,pool.rs}},tests/,benches/};
  vis:pub(crate)_default;pub mod auth;pub use auth::AuthMiddleware;@lib.rs;
}

§PAT{
  own:read_only⇒&[u8]|&str(fn process(d:&[u8])->usize);store|consume⇒Vec<u8>|String;cond_alloc⇒Cow<'_,str>(if s.contains(' '){Cow::Owned(..)}else{Cow::Borrowed(s)});
  err_app:anyhow::{bail,Context,Result}(.with_context(||format!(..))?∧bail!(..));¬.unwrap();
  err_lib:thiserror_2(#[derive(Debug,Error)] pub enum StorageError{#[error("not found: {id}")]NotFound{id:String},#[error("io")]Io(#[from]std::io::Error),#[error("invalid: {0}")]Invalid(String)});// no_std ready
  opt_comb:users.iter().find(|u|u.id==id).map(|u|u.email.clone())≻nested_match;
  let_chains:if let Some(cfg)=load_cfg() && cfg.active && let Some(port)=cfg.port{..};// Rust 2024
  enum_state:rich_variants(Disconnected|Connecting{attempt:u32}|Connected{session_id:String}|Failed{reason:String,retries:u32})+guards(if *attempt>3)+destructure(..)+¬_wildcard;
  api_sig:fn read_all(r:&mut impl Read)->io::Result<Vec<u8>>;bounds:T:Display+Send+'static;
  rpit_2024:fn items<'a>(s:&'a State,tmp:&Tmp)->impl Iterator<Item=&'a Item>+use<'a>;// 2024 captures all lifetimes by default; constrain w/ use<..>
  afit_send:fn find(&self,id:u64)->impl Future<Output=Option<User>>+Send;// impl block still uses async fn
  afit_dual:#[trait_variant::make(SendRepo:Send)] pub trait Repo{async fn find(&self,id:u64)->Option<User>;};
  afit_dyn:#[async_trait::async_trait] pub trait DynRepo{async fn find(&self,id:u64)->Option<User>;}∨closed_enum_dispatch;// AFIT ¬dyn-compatible
  dyn_vs_mono:trait Handler:Send+Sync{..}⇒Vec<Box<dyn Handler>>(plugins|heterogeneous)⊕fn fast<H:Handler>(h:&H)(monomorph);
  newtype:struct UserId(u64);struct OrderId(u64);// prevents arg swap
  builder:ServerConfig::builder(host:impl Into<String>,port:u16)->Builder;fn max_conns(mut self,n:usize)->Self;fn build(self)->ServerConfig;
  iter:filter_map⇒users.iter().filter(|u|u.active).map(|u|u.email.clone()).collect::<Vec<_>>();lookup⇒items.iter().map(|i|(i.id,i)).collect::<HashMap<_,_>>();join⇒parts.iter().copied().collect::<String>();fail_fast⇒strs.iter().map(|s|s.parse()).collect::<Result<Vec<i32>,_>>();
  globals:static EMAIL_RE:LazyLock<Regex>=LazyLock::new(||Regex::new(r"..").expect("valid regex"));static CFG:OnceLock<Config>=OnceLock::new();
  scoped_threads:std::thread::scope(|s|{let l=s.spawn(||data[..mid].iter().sum::<i32>());let r=s.spawn(||data[mid..].iter().sum::<i32>());l.join().expect("panicked")+r.join().expect("panicked")});// borrows stack ¬'static
  shared_mut:Arc<Mutex<T>>+Arc::clone+lock().expect("poisoned");
  bounded_chan:std::sync::mpsc::sync_channel(16)∨tokio::sync::mpsc::channel(64)+drop(tx)_to_close_rx;
  async_timeout:tokio::time::timeout(Duration::from_secs(5),client.get(url).send()).await.context("timeout")??;
  async_joinset:let mut set=tokio::task::JoinSet::new();set.spawn(async move{..});while let Some(res)=set.join_next().await{let v=res??;};// drop(set) auto-aborts remaining tasks
  async_cancel:let tok=tokio_util::sync::CancellationToken::new();let child=tok.child_token();tokio::select!{_=child.cancelled()=>{/* flush */},_=work()=>{}};
  async_closures:let inc=async |x|{count+=x;count};// AsyncFn|AsyncFnMut|AsyncFnOnce (Rust 2024)
  async_blocking:tokio::task::spawn_blocking(move||cpu_or_sync_io()).await??;
  unsafe_2024:doc(/// # Safety)∧cmt(// SAFETY:)∧unsafe{..}_inside_unsafe_fn∧unsafe extern "C"{fn raw_call();}∧#[unsafe(no_mangle)] pub extern "C" fn sym(){};
}

§D{
  migrate_edition⇒run(cargo fix --edition)_on_old_edition→bump(edition="2024")→audit(pub_RPIT_use<..>);
  async_trait_multi_runtime⇒trait_variant::make¬#[async_trait];
  async_trait_tokio_only⇒fn f(&self)->impl Future<Output=T>+Send¬unbounded_AFIT;
  async_trait_object⇒#[async_trait]∨closed_enum_dispatch¬AFIT;
  lazy_static_or_once_cell⇒std::sync::LazyLock|OnceLock¬external_crate;
  borrow_local_in_threads⇒std::thread::scope¬Arc_wrapper;
  dynamic_async_fanout⇒tokio::task::JoinSet¬Vec<JoinHandle>;
  graceful_shutdown⇒tokio_util::sync::CancellationToken+JoinSet¬ad_hoc_bool_or_channel;
}

§CMD{
  cargo check --workspace --all-targets          // fast type check ¬codegen
  cargo fmt --all -- --check                     // format gate
  cargo clippy --workspace --all-targets --all-features -- -D warnings
  cargo fix --edition                            // automated 2024 migration
  cargo audit                                    // RustSec vuln scan
  cargo deny check                               // licenses+advisories+bans+sources
  cargo +nightly miri test                       // UB check for unsafe code
  cargo tree -d                                  // inspect duplicate deps
  cargo bench                                    // run benches/
}

§ANTI{
  map.get("k").unwrap()_prod⇒?|ok_or|with_context;
  .clone()_for_borrow_chk⇒restructure_borrows;
  fn greet(name:String)_read⇒fn greet(name:&str);
  &Vec<T>_or_&String_param⇒&[T]_or_&str;
  Box<dyn Error>_lib_API⇒thiserror_2_enum;
  let _=validate(x)_Result⇒handle∨propagate;
  std::thread::sleep_in_async⇒tokio::time::sleep(..).await;
  std::sync::MutexGuard_held_across_.await⇒drop_before_await∨tokio::sync::Mutex;
  lazy_static!|once_cell::sync::Lazy⇒std::sync::LazyLock|OnceLock;
  #[allow(clippy::..)]⇒#[expect(clippy::..,reason="..")];
  Vec<JoinHandle>_untracked⇒tokio::task::JoinSet(prevents_task_leak_on_drop);
  bare_extern"C"|#[no_mangle]_in_2024⇒unsafe extern"C"|#[unsafe(no_mangle)];
  #[async_trait]_without_dyn⇒native_AFIT∨trait_variant;
}

§CHK{
  edition="2024"∧resolver="3"∧MSRV_declared;
  [workspace.lints]_configured∧zero_unreasoned_#[allow];
  clippy_all_targets_all_features_-D_warnings≡0;
  cargo_deny∧cargo_audit≡clean;
  ∀unsafe:doc(# Safety)∧cmt(// SAFETY:)∧miri_pass;
}
