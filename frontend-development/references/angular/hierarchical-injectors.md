@REF:hierarchical-injectors
§R{
  EnvironmentInjector:@Injectable({providedIn:'root'})∨ApplicationConfig.providers⇒global_singletons;
  ElementInjector:implicit@DOM_element←@Component|@Directive({providers,viewProviders});
  resolve:1:ElementInjector↑(requester→root_el)→2:EnvironmentInjector↑(closest→root)→3:¬found⇒throw(unless optional);
  providers:component+view+<ng-content>(projected);
  viewProviders:component+view¬<ng-content>(isolate_from_consumer_content)
}
§CFG{
  inject(Token,{optional,self,skipSelf,host}):
  optional⇒null_if_missing;self⇒current_ElementInjector_only;
  skipSelf⇒start@parent_ElementInjector;host⇒stop@host_component_view_boundary
}
§PAT{inject(MyService,{optional:true});inject(ParentService,{skipSelf:true})}
