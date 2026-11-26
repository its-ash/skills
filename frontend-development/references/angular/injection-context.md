@REF:injection-context
§R{
  inject()⇒req(injection_context);
  valid_ctx:{DI_class(@Injectable|@Component|@Directive|@Pipe)∈{field_init,constructor},factories(useFactory|InjectionToken),Angular_functional_APIs(route_guards|resolvers|interceptors)};
  invalid_ctx:post_init_methods(e.g.onClick)⇒throws;
  dynamic_or_test:runInInjectionContext(EnvironmentInjector|Injector,fn);
  guard_util:assertInInjectionContext(fn)⇒throws_clear_err_if_invalid
}
§PAT{
  runInInjectionContext(inject(EnvironmentInjector),()=>inject(Router));
  export function injectNativeElement<T extends Element>():T{assertInInjectionContext(injectNativeElement);return inject(ElementRef).nativeElement}
}
