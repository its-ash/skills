@REF:idioms
§REL{../SKILL.md:rules}

§OWN{read_only⇒&[u8](fn process(data:&[u8])->usize); store|consume⇒Vec<u8>(fn store(data:Vec<u8>)->Record); ¬(&Vec<u8>+clone); cond_alloc⇒std::borrow::Cow<'_,str>(if s.contains(' '){Cow::Owned(s.replace(' ',"_"))}else{Cow::Borrowed(s)})}

§ERR{
  app⇒anyhow::{bail,Context,Result}(.with_context(||format!(..))?∧bail!(..)); ¬.unwrap();
  lib⇒thiserror::Error(#[derive(Debug,Error)] pub enum StorageError{#[error("record not found: {id}")]NotFound{id:String},#[error("connection failed")]Connection(#[from]std::io::Error),#[error("invalid data: {0}")]InvalidData(String)});
  opt⇒users.iter().find(|u|u.id==id).map(|u|u.email.clone()) ¬nested_match
}

§ENUM{rich_variants(Disconnected|Connecting{attempt:u32}|Connected{session_id:String}|Failed{reason:String,retries:u32}); guards(if *attempt>3|if *retries<5); destructure(..); ¬wildcard(_=>{})_hiding_new_variants}

§API{
  generic_in_concrete_out:fn read_all(r:&mut impl Read)->std::io::Result<Vec<u8>>;
  bounds:T:Display+Send+'static;
  dyn_vs_mono:trait Handler:Send+Sync{fn handle(&self,req:&Request)->Response;} ⇒ Vec<Box<dyn Handler>>(heterogeneous|plugins) ⊕ fn fast<H:Handler>(h:&H,..)(monomorphized);
  newtype:struct UserId(u64);struct OrderId(u64); // prevents arg swap
  builder:ServerConfig::builder(host:impl Into<String>,port:u16)->ServerConfigBuilder{..,max_connections:100}; fn max_connections(mut self,n:usize)->Self; fn build(self)->ServerConfig
}

§ITER{
  filter_map:users.iter().filter(|u|u.is_active).map(|u|u.email.clone()).collect::<Vec<String>>();
  map_lookup:items.iter().map(|i|(i.id,i)).collect::<HashMap<_,_>>();
  join:parts.iter().copied().collect::<String>();
  short_circuit_err:strs.iter().map(|s|s.parse()).collect::<Result<Vec<i32>,_>>()
}

§CONC{
  shared_mut:Arc<Mutex<T>>+Arc::clone+std::thread::spawn(move||*c.lock().expect("mutex poisoned")+=1)+h.join().expect("worker thread panicked");
  bounded_chan:std::sync::mpsc::sync_channel(16)(backpressure)+tx.send(..).expect("receiver disconnected")+drop(tx)_before_for_msg_in_rx;
  async_timeout:tokio::time::timeout(Duration::from_secs(5),reqwest::get(url)).await.context(..)?.context(..)?.text().await;
  async_fanout:tokio::spawn→Vec::with_capacity→h.await.unwrap_or_else(|e|panic!("spawned task panicked: {e}"))
}

§UNSAFE{
  req:doc(/// # Safety)∧cmt(// SAFETY:)∧Rust2024(unsafe{&*ptr} inside unsafe fn);
  ex:unsafe{slice.get_unchecked(index)};
  ¬{bypass_borrow_chk,convenience,missing_SAFETY,transmute(unrelated_types)}
}

§LAY{
  my_app/{Cargo.toml,src/{main.rs,lib.rs,auth/{mod.rs,token.rs,middleware.rs},orders/{mod.rs,model.rs,service.rs},db/{mod.rs,pool.rs}},tests/,benches/};
  vis:pub(crate) fn; pub mod auth; pub use auth::AuthMiddleware; // re-export from lib.rs
}

§CMD{cargo check(type_chk¬codegen); cargo clippy|fmt(lint|fmt); cargo test -- --nocapture(println!); cargo test --lib(unit)|--test integration(1_file); cargo audit(sec); cargo tree|update; cargo bench}

§ANTI{
  map.get("k").unwrap()_prod⇒?|ok_or|context;
  .clone()_borrow_chk⇒restructure_borrows;
  fn greet(name:String)_read⇒fn greet(name:&str);
  Box<dyn Error>_lib_API⇒thiserror_enum;
  let _=validate(x)_Result⇒handle∨propagate;
  std::thread::sleep_async⇒tokio::time::sleep(..).await
}
