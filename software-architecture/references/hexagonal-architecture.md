@REF:hexagonal-architecture
§USE{maintainability_testability;decouple(domain,IO);multi_iface(HTTP,CLI,queue,cron);swappable_infra(DB,API,bus);boundary_refactor}
§CORE{
  Domain:business_rules+entities/VOs;deps≡∅_ext(¬fw,¬infra);
  Application(UseCases):orchestrate_domain+workflow→plain_DTOs;deps≡ports+domain;
  InboundPort:cmd/query/usecase_ifaces;
  OutboundPort:capability_contracts(repo,gateway,event_pub,clock,UUID)∈app(∨domain_iff_domain_level);
  Adapters:inbound(protocol→DTO),outbound(port→DB/API/queue/SDK);deps→app/domain;mapping∈adapters;
  CompositionRoot:single_wiring_site(¬service_locator);
  dep_dir:Adapters→App/Domain→Ports→∅_infra
}
§FLOW{
  1:usecase_DTO_boundary(¬{req,context,job_wrappers})→
  2:outbound_ports_first(capabilities¬tech:UserRepositoryPort,BillingGatewayPort,LoggerPort,ClockPort)→
  3:pure_usecase(ctor/arg_DI,app_invariants)→
  4:edge_adapters(mapping∈adapters)→
  5:composition_root→
  6:test/boundary(unit_fakes,int_real_infra,E2E_inbound)
}
§TOPOLOGY{
  `Client(HTTP/CLI/Worker)→InboundAdapter→UseCase→OutboundPort←OutboundAdapter→Ext(DB/API/Queue)` ∧ `UseCase→DomainModel`;
  tree:`src/features/<feat>/{domain/{Order.ts,OrderPolicy.ts},application/{ports/{inbound/CreateOrder.ts,outbound/{OrderRepositoryPort.ts,PaymentGatewayPort.ts}},use-cases/CreateOrderUseCase.ts},adapters/{inbound/http/createOrderRoute.ts,outbound/{postgres/PostgresOrderRepository.ts,stripe/StripePaymentGateway.ts}},composition/ordersContainer.ts}`
}
§PAT_TS{
  ```ts
  export interface OrderRepositoryPort { save(o: Order): Promise<void>; findById(id: string): Promise<Order | null>; }
  export interface PaymentGatewayPort { authorize(i: { orderId: string; amountCents: number }): Promise<{ authorizationId: string }>; }
  export class CreateOrderUseCase {
    constructor(private repo: OrderRepositoryPort, private pg: PaymentGatewayPort) {}
    async execute(i: { orderId: string; amountCents: number }): Promise<{ orderId: string; authorizationId: string }> {
      const o = Order.create({ id: i.orderId, amountCents: i.amountCents });
      const a = await this.pg.authorize({ orderId: o.id, amountCents: o.amountCents });
      await this.repo.save(o.markAuthorized(a.authorizationId));
      return { orderId: o.id, authorizationId: a.authorizationId };
    }
  }
  export class PostgresOrderRepository implements OrderRepositoryPort {
    constructor(private db: SqlClient) {}
    async save(o: Order): Promise<void> { await this.db.query("insert into orders (id, amount_cents, status, authorization_id) values ($1, $2, $3, $4)", [o.id, o.amountCents, o.status, o.authorizationId]); }
    async findById(id: string): Promise<Order | null> { const r = await this.db.oneOrNone("select * from orders where id = $1", [id]); return r ? Order.rehydrate(r) : null; }
  }
  export const buildCreateOrderUseCase = (d: { db: SqlClient; stripe: StripeClient }) =>
    new CreateOrderUseCase(new PostgresOrderRepository(d.db), new StripePaymentGateway(d.stripe));
  ```
}
§LANG{
  TS/JS:ports∈`application/ports/*`,DI(ctor/arg),adapters∈`adapters/{inbound,outbound}/*`,explicit_factory/container(¬globals);
  Java:pkgs(`domain|application.port.{in,out}|application.usecase|adapter.{in,out}`),ports=ifaces,usecase=plain(`@Service`_opt),comp=Spring_cfg|manual;
  Kotlin:mirror_Java,ifaces,ctor_DI(Koin/Dagger/Spring/manual),module_defs|fns(¬service_locator);
  Go:pkgs(`internal/<feat>/{domain,application,ports,adapters/{inbound,outbound}}`),small_consumer_ifaces,struct+`New...`,wire∈`cmd/<app>/main.go`
}
§ANTI{domain_imports(ORM,web_fw,SDK);usecase_reads(req,res,queue_meta);usecase_returns_raw_DB_rows;adapter→adapter_direct;hidden_global_singletons}
§MIG{
  strangler:pick_slice(high_churn,low_blast)→extract_DTO_boundary→facade_legacy_w_outbound_ports→move_orch_from_ctrl→old_adapters_delegate→freeze_comp_early→char+unit+int_tests→reversible_toggle/route→repeat_per_slice(¬big_bang)
}
§TEST{
  domain:pure(¬mocks,¬fw);
  usecase_unit:fakes/stubs(outcomes+port_calls);
  outbound_contract:shared_port_suite_per_impl;
  inbound_adapter:protocol↔DTO+err_map;
  adapter_int:real_DB/API/queue(ser,query,retry,timeout);
  E2E:inbound→usecase→outbound;
  refactor:char_tests_until_stable
}
§CHK{inward_imports_only∧port/ext_dep∧boundary_val(in+invariants)∧immutable_transforms∧err_translation∧auditable_comp_root∧in_mem_fakes∧slice_refactor_w_char_tests∧fw_in_adapters_only}
