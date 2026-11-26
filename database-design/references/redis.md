@REF:redis
§USE{cache,rate_limit,dist_lock,session,pubsub,streams,prod(pool,evict,cluster,sentinel)}
§CORE{in_mem;1_cmd≡atomic(1_node);multi_step⇒Lua∨MULTI/EXEC∨sync;persist∈{RDB,AOF};TCP_RESP;pool⇒¬handshake_overhead}
§DS{cache→String(`product:123`);session→Hash(`session:abc`);leaderboard→SortedSet(`scores:weekly`);uniques→Set(`visitors:2024-01-01`);feed→List(`feed:user:456`);stream→Stream(`events:orders`);cnt|rl→String(INCR,`ratelimit:user:123`);card→HyperLogLog(`hll:pageviews`)}
§PAT{
cache_aside(read_heavy,stale_ok):`r.get(k)`→hit?`json.loads`:DB→`r.setex(k,3600,json.dumps(v))`;
write_through(strong_cons):DB_write→`r.setex(f"product:{id}",3600,json.dumps(d))`;
tag_inval:`p=r.pipeline(transaction=True);p.setex(k,3600,v);p.sadd(tag,k);p.expire(tag,3600);p.execute()`;inval:`ks=r.smembers(tag);r.delete(*ks) if ks else None;r.delete(tag)`;
session(Hash,ttl=86400):`k=f"session:{uuid.uuid4()}";p=r.pipeline(transaction=True);p.hset(k,mapping={"user_id":uid,"created_at":int(time.time())});p.expire(k,ttl);p.execute()`;get:`r.hgetall(k) or None`;del:`r.delete(k)`
}
§RATE{
fixed(low_traf):`k=f"ratelimit:{uid}:{int(time.time())//win}";p=r.pipeline(transaction=True);p.incr(k);p.expire(k,win);c,_=p.execute();return c>limit` (def:100/60s);
sliding(accurate,Lua):`r.register_script(lua)(keys=[f"ratelimit:sliding:{uid}"],args=[int(time.time()*1000),60000,100])`
```lua
local k,now,win,lim=KEYS[1],tonumber(ARGV[1]),tonumber(ARGV[2]),tonumber(ARGV[3])
redis.call('ZREMRANGEBYSCORE',k,0,now-win)
if redis.call('ZCARD',k)<lim then local sk=k..':seq';local seq=redis.call('INCR',sk);local t=math.ceil(win/1000);redis.call('EXPIRE',sk,t);redis.call('ZADD',k,now,now..'-'..seq);redis.call('EXPIRE',k,t);return 1 end
return 0
```
}
§LOCK{
single(ttl_ms=5000>job_dur):acq:`t=str(uuid.uuid4());t if r.set(f"lock:{res}",t,px=ttl_ms,nx=True) else None`;
rel(finally,Lua):`bool(r.eval("if redis.call('get',KEYS[1])==ARGV[1] then return redis.call('del',KEYS[1]) else return 0 end",1,f"lock:{res}",t))`;
multi_node⇒`redlock-py`
}
§MSG{
pubsub(fire_forget,¬guar):`r.publish(ch,json.dumps(p))`;sub(thread/proc):`ps=r.pubsub();ps.subscribe(ch);[handle(json.loads(m['data'])) for m in ps.listen() if m['type']=='message']`;
streams(durable,at_least_once,groups,replay⇒prefer>pubsub):prod:`r.xadd(stream,ev,maxlen=10000)`;grp:`r.xgroup_create('events:orders','processor',id='0',mkstream=True)`(ignore_exists);cons:`r.xreadgroup(grp,cons,{stream:'>'},count=10,block=2000)`→proc→`r.xack(stream,grp,msg_id)`
}
§KEY_TTL{
fmt∈{`resource:id:field`(`user:123:profile`,`order:456:status`,`cache:product:789`),`namespace:resource:id`(`myapp:session:abc123`,`myapp:ratelimit:user:123`),`resource:date`(`stats:pageviews:2024-01-01`)};
ttl:{sess:24h(`86400`),api:5-15m(Django/Flask_req_params:5m),rl:match_win,tok:5-10m,lb:1-24h,ref:1h-1w};
∀key⇒TTL(¬OOM)
}
§CONN{
pool:`Redis(connection_pool=ConnectionPool(host='localhost',port=6379,db=0,max_connections=20,decode_responses=True,socket_connect_timeout=2,socket_timeout=2))`;
cluster:`redis.cluster.RedisCluster(startup_nodes=[{"host":"redis-1","port":6379}],decode_responses=True,skip_full_coverage_check=True)`;
sentinel:`s=redis.sentinel.Sentinel([('sentinel-1',26379),('sentinel-2',26379)],socket_timeout=0.5);master=s.master_for('mymaster',decode_responses=True);replica=s.slave_for('mymaster',decode_responses=True)`
}
§EVICT(`redis.conf`:`maxmemory-policy <p>`){`noeviction`:write_err(queues/crit);`allkeys-lru`:LRU_all(cache);`volatile-lru`:LRU_ttl(mixed);`allkeys-lfu`:LFU_all(skewed);`volatile-ttl`:soonest_exp(keep_long)}
§ANTI{¬TTL⇒OOM⇒set_TTL;`KEYS *`∈prod⇒O(N)_block⇒`SCAN`;blob>100KB⇒slow_serde+mem⇒ref+obj_store;1_Redis_∀⇒¬isol⇒sep_DBs|inst;¬pool_lim⇒exhaust⇒size_pool;¬stampede⇒thundering_herd⇒double_check_lock(`threading.Lock`/key|dist_lock)∨prob_early_exp;`FLUSHALL`⇒wipe⇒del_by_pattern}
§REL{`database-design/references/postgresql.md`;`backend-development/SKILL.md`;`database-design/references/database-migration.md`;`backend-development/references/django.md`}
