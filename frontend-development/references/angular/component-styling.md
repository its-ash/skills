@REF:component-styling
§DEF{
  @Component({ selector:'app-photo', styles:`img{border-radius:50%;}` /* OR */ styleUrl:'photo.component.css' })
}
§ENCAP{
  pkg:`ViewEncapsulation`←`@angular/core`;
  set:`@Component({ encapsulation: ViewEncapsulation.<Mode> })`;
  modes:{
    Emulated(default):scopes_via_unique_HTML_attrs∧global_styles_can_leak_in;
    ShadowDom:native_Shadow_DOM_complete_isolation;
    None:disables_encap⇒styles_global;
    ExperimentalIsolatedShadowDom:strict_only_component_styles_apply
  }
}
§SELECTORS{
  `:host`:targets_component_host_el;
  `:host-context(.theme-dark)`:targets_host_if_any_ancestor_matches;
  `::ng-deep`:disables_encap_leaks_to_children⇒STRONGLY_DISCOURAGED(backwards_compat_only)
}
§EDGE{
  template_style:`<style>...</style>`_in_template⇒view_encap_still_applies;
  external:`<link>`∨CSS_`@import`⇒¬affected_by_`Emulated`_encap
}
