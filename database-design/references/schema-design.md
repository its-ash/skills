@REF:schema-design
§CAT{Rel:PostgreSQL,MySQL,MariaDB,SQL_Server,SQLite(simple/local);Doc:MongoDB,Firestore,CouchDB;KV:Redis,DynamoDB,Memcached;Wide:Cassandra,ScyllaDB,HBase;TS:TimescaleDB,InfluxDB,ClickHouse;Graph:Neo4j,Amazon_Neptune;Search:Elasticsearch,OpenSearch,Meilisearch;NewSQL:CockroachDB,TiDB,Google_Spanner}
§FLOW{1:Analysis(entities,rels,R/W_access)→2:Conceptual(Mermaid_ERD)→3:Logical(SQL⇒3NF,denorm⇔proven_read;NoSQL⇒embed_fast_read,ref_flex|large)→4:Physical(types,constraints,idx)}
§IDX{B-tree:eq+range;Composite:multi_col(most_sel_first);GIN/GiST:JSONB+FTS+spatial;Partial:row_subset(save_space)}
§SCALE{Vert:CPU,RAM,IOPS;Horiz:read_replicas,sharding(careful_shard_key),partitioning(range,hash,list);Cache:cache_aside|write_through(Redis|Memcached→[redis.md](redis.md))}
§ANTI{`VARCHAR(255)`_∀⇒size/field;`FLOAT`_money⇒err⇒`DECIMAL(10,2)`;¬FK⇒orphans⇒FK+`ON DELETE`;str_date⇒¬sort/cmp⇒`DATE`/`TIMESTAMP`;irrev_mig⇒¬recov⇒`DOWN`;full_SQL_trivial⇒SQLite|NoSQL;`SELECT *`⇒IO+brittle⇒list_cols;N+1⇒round_trips⇒JOIN|eager}
§CHK{PK∈∀tbl;FK+`ON DELETE`∈∀rel;idx∈∀FK+high_card;`DECIMAL`_money∧`TIMESTAMP`_date;`NOT NULL`_req;`created_at`∧`updated_at`∈∀tbl;mig≡rev∧back_compat;access⇒norm|denorm}
