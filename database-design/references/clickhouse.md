@REF:clickhouse

§USE{schema(MergeTree)∨analytics_qry(agg,window,join)∨qry_opt(partition_prune,projections,MV)∨bulk_ingest(batch,Kafka)∨migrate(PG|MySQL→ClickHouse)∨realtime_dashboards|timeseries}
§CORE{columnar_OLAP_DBMS;compression;parallel_exec;distributed_qry;realtime_analytics}

§ENG{
  MergeTree:`CREATE TABLE markets_analytics(date Date,market_id String,market_name String,volume UInt64,trades UInt32,unique_traders UInt32,avg_trade_size Float64,created_at DateTime) ENGINE=MergeTree() PARTITION BY toYYYYMM(date) ORDER BY (date,market_id) SETTINGS index_granularity=8192`;
  ReplacingMergeTree(dedup):`CREATE TABLE user_events(event_id String,user_id String,event_type String,timestamp DateTime,properties String) ENGINE=ReplacingMergeTree() PARTITION BY toYYYYMM(timestamp) ORDER BY (user_id,event_id,timestamp) PRIMARY KEY (user_id,event_id)`;
  AggregatingMergeTree(pre_agg):`CREATE TABLE market_stats_hourly(hour DateTime,market_id String,total_volume AggregateFunction(sum,UInt64),total_trades AggregateFunction(count,UInt32),unique_users AggregateFunction(uniq,String)) ENGINE=AggregatingMergeTree() PARTITION BY toYYYYMM(hour) ORDER BY (hour,market_id)`→`sumMerge(total_volume),countMerge(total_trades),uniqMerge(unique_users) WHERE hour>=toStartOfHour(now()-INTERVAL 24 HOUR) GROUP BY hour,market_id ORDER BY hour DESC`
}

§QRY{
  filter:indexed_first(`date>='2025-01-01' AND market_id='m123' AND volume>1000 ORDER BY date DESC LIMIT 100`)∧¬non_indexed_first(`volume>1000 AND market_name LIKE '%x%' AND date>=...`);
  agg:`toStartOfDay(created_at) day,market_id,sum(volume),count(),uniq(trader_id),avg(trade_size) WHERE created_at>=today()-INTERVAL 7 DAY GROUP BY day,market_id ORDER BY day DESC,sum(volume) DESC`;
  pct:`quantile(0.50|0.95|0.99)(trade_size) WHERE created_at>=now()-INTERVAL 1 HOUR`≻`percentile`;
  window:`sum(volume) OVER (PARTITION BY market_id ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) WHERE date>=today()-INTERVAL 30 DAY ORDER BY market_id,date`
}

§ING{
  client:`@clickhouse/client`:`createClient({url:CLICKHOUSE_URL??'http://localhost:8123',username:CLICKHOUSE_USER,password:CLICKHOUSE_PASSWORD})`;
  batch:`clickhouse.insert({table:'trades',values:rows.map(r=>({...r,timestamp:r.timestamp.toISOString()})),format:'JSONEachRow'})`;
  stream:`node:stream`:`Readable.from(asyncIter,{objectMode:true})`→`values` (`format:'JSONEachRow'`);
  ¬loop_single_insert
}

§MV{`CREATE MATERIALIZED VIEW market_stats_hourly_mv TO market_stats_hourly AS SELECT toStartOfHour(timestamp) hour,market_id,sumState(amount),countState(),uniqState(user_id) FROM trades GROUP BY hour,market_id`→query_target_with_`sumMerge`|`countMerge`|`uniqMerge`(`hour>=now()-INTERVAL 24 HOUR`)}

§MON{
  slow:`system.query_log`(`query_id,user,query,query_duration_ms,read_rows,read_bytes,memory_usage WHERE type='QueryFinish' AND query_duration_ms>1000 AND event_time>=now()-INTERVAL 1 HOUR ORDER BY query_duration_ms DESC LIMIT 10`);
  stats:`system.parts`(`database,table,formatReadableSize(sum(bytes)) size,sum(rows) rows,max(modification_time) latest_mod WHERE active GROUP BY database,table ORDER BY sum(bytes) DESC`)
}

§ANL{
  DAU:`toDate(timestamp) d,uniq(user_id) WHERE timestamp>=today()-INTERVAL 30 DAY GROUP BY d`;
  retention:`signup,countIf(days=0|1|7|30)`←sub(`min(toDate(timestamp)) signup,toDate(timestamp) act,dateDiff('day',signup,act) days GROUP BY user_id,act`)` GROUP BY signup ORDER BY signup DESC`;
  funnel:`countIf(step='viewed_market') v,countIf(step='clicked_trade') c,countIf(step='completed_trade') d,round(c/v*100,2),round(d/c*100,2) WHERE event_date=today() GROUP BY session_id`;
  cohort:`toStartOfMonth(signup) cohort,toStartOfMonth(act) month,dateDiff('month',cohort,month) m,count(DISTINCT user_id)`←sub(`min(toDate(timestamp)) OVER (PARTITION BY user_id) signup,toDate(timestamp) act`)` GROUP BY cohort,month,m ORDER BY cohort,m`
}

§PIPE{
  ETL:PG_extract→transform(`date:ISO.split('T')[0]`,parseFloat,parseInt)→bulkInsert→`setInterval(etl,3600000)`;
  CDC:`pg.Client({connectionString:DATABASE_URL}).query('LISTEN market_updates')`→`on('notification',m=>{u=JSON.parse(m.payload);clickhouse.insert({table:'market_updates',values:[{market_id:u.id,event_type:u.operation/*INSERT|UPDATE|DELETE*/,timestamp:new Date(),data:JSON.stringify(u.new_data)}],format:'JSONEachRow'})})`
}

§R{partition:by_time(month|day)∧Date_type∧¬many_partitions;order_key:most_filtered_first∧high_cardinality_first(compression);types:smallest(`UInt32`<`UInt64`)∧`LowCardinality`(repeated_str)∧`Enum`(categorical);monitor:{qry_perf,disk,merges,slow_log}}
§ANTI{`SELECT *`|`FINAL`(pre_merge)|excess_JOINs(denormalize)|small_frequent_inserts(batch)}
