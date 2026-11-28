@REF:jpa-patterns
§STACK{SpringBoot_4(4.2.x),SpringDataJPA_4,HibernateORM_7(7.1/7.2;JakartaPersistence_3.2)∨Quarkus_4_HibernateORM_8(JakartaPersistence_4.0,JakartaData_1.1);jakarta.persistence.*}
§ENT{@Entity @Table(name="markets",indexes=@Index(name="idx_markets_slug",columnList="slug",unique=true)) @EntityListeners(AuditingEntityListener.class);@Id @GeneratedValue(strategy=GenerationType.IDENTITY) Long id;@Column(nullable=false,length=200) name;@Column(nullable=false,unique=true,length=120) slug;@Enumerated(EnumType.STRING) Status=ACTIVE;@CreatedDate Instant createdAt;@LastModifiedDate Instant updatedAt;audit:@Configuration @EnableJpaAuditing;H7+:@SoftDelete,@SQLRestriction("status <> 'ARCHIVED'")}
§REL_N1{@OneToMany(mappedBy="market",cascade=CascadeType.ALL,orphanRemoval=true);R:{lazy_def,¬EAGER_colls,JOIN_FETCH∨@EntityGraph,reads→DTO_proj,bulk_no_PC→Hibernate_StatelessSession};ex:@Query("select m from Market m left join fetch m.positions where m.id=:id")}
§REPO{JpaRepository<E,Long>:findBySlug(String),@Query("...where m.status=:status") Page<E> findByStatus(@Param("status") Status,Pageable);proj:record Summary(Long id,String name,Status status)+Page<Summary> findAllBy(Pageable);dyn:Specification(CriteriaAPI);SQL:jOOQ_3.21.x;JakartaData_1.1(Quarkus4/H8):@Repository_CrudRepository}
§TXN{@Transactional(svc),@Transactional(readOnly=true)(reads),short_txns,prop_careful,dirty_chk(mutate_managed)}
§PAGE{offset:PageRequest.of(p,sz,Sort.by("createdAt").descending());cursor:JPQL id>:lastId+ORDER BY(keyset_for_deep_pages)}
§PERF{idx:{status,slug,FKs,composite(status,created_at)};qry:¬select *→proj;batch:saveAll+hibernate.jdbc.batch_size}
§POOL{HikariCP:spring.datasource.hikari.{maximum-pool-size=20,minimum-idle=5,connection-timeout=30000,validation-timeout=5000};spring.threads.virtual.enabled=true⇒pool≤DB_cap(¬threads)}
§CACHE{L1:per_EntityManager(¬cross_txn);L2:read_heavy+eviction_val}
§MIG{Flyway_13.x∨Liquibase_5.0.x;¬Hibernate_auto_DDL_prod;idempotent+additive;plan_col_drops;ref:database-design/references/database-migration.md}
§TEST{Boot4_dep:spring-boot-starter-data-jpa-test;ann:org.springframework.boot.data.jpa.test.autoconfigure.@DataJpaTest+Testcontainers_2(org.testcontainers:testcontainers-postgresql)+@ServiceConnection;SQL:logging.level.org.hibernate.{SQL=DEBUG,orm.jdbc.bind=TRACE}}
