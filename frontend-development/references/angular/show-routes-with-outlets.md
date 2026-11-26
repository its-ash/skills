@REF:show-routes-with-outlets

§R{
  `RouterOutlet`:renders_routed_cmp_as_immediate_sibling;
  nested_routes⇒parent_tpl_needs_own(`<router-outlet />`);
  default_outlet_name='primary'
}
§PAT{
  basic:`<app-header /><router-outlet /><app-footer />`;
  named:route`{path:'chat',component:Chat,outlet:'sidebar'}`∧tpl`<router-outlet /><router-outlet name="sidebar" />`;
  events:(`activate`→instantiated|`deactivate`→destroyed|`attach`/`detach`→`RouteReuseStrategy`),tpl`<router-outlet (activate)="onActivate($event)" />`;
  outlet_data:parent`<router-outlet [routerOutletData]="{theme:'dark'}" />`∧cmp`outletData=inject(ROUTER_OUTLET_DATA)as Signal<{theme:string}>`
}
