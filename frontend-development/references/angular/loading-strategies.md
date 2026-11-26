@REF:loading-strategies
§PAT{
  eager(in_init_bundle⇒immediate_nav,↑init_bundle):`{ path: 'home', component: Home }`
  lazy_cmp(separate_chunk_on_nav):`{ path: 'admin', loadComponent: () => import('./admin/admin.component').then(m => m.AdminComponent) }`
  lazy_routes:`{ path: 'settings', loadChildren: () => import('./settings/settings.routes') }`
  inject_ctx(loaders_run_in_route_inject_ctx⇒`inject()`_ok):
  ```ts
{ path: 'dashboard', loadComponent: () => inject(FeatureFlags).isPremium ? import('./premium-dashboard') : import('./basic-dashboard') }
  ```
}
§D{
  primary_landing_pages⇒eager;
  all_other_features⇒lazy(↓init_bundle)
}
