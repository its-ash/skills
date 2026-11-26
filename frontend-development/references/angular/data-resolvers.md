@REF:data-resolvers
§R{
  purpose:fetch_pre_route_activation⇒comp_has_data_on_render;
  lightweight:critical_data_only;
  feedback:listen(router.events)→global_loading_bar(UI_stays_on_old_page_until_resolved);
  err:fail⇒blocks_nav;{global:withNavigationErrorHandler,local:catchError(()=>of(new RedirectCommand(router.parseUrl('/error'))))∨fallback}
}
§PAT{resolver_and_access}
```ts
export const userResolver: ResolveFn<User> = (route, state) => inject(UserService).getUser(route.paramMap.get('id')!);
// route:{path:'user/:id',component:UserProfile,resolve:{user:userResolver}}
// 1)ActivatedRoute: route=inject(ActivatedRoute); data=toSignal(this.route.data); user=computed(()=>this.data().user);
// 2)Inputs(modern): provideRouter(routes,withComponentInputBinding()) → @Input() | user=input.required<User>();
```
