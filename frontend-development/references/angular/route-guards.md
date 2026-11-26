@REF:route-guards
§R{
functional(Angular≥15),inject();arrays⇒ordered;
ret∈{bool(true=allow,false=block),UrlTree|RedirectCommand,Observable|Promise};
SEC:client_guards≠server_auth⇒verify_on_server
}
§API{
CanActivate:route;CanActivateChild:children;
CanDeactivate:leave(unsaved);CanMatch:match(flags;false⇒try_next_route)
}
§PAT{
```ts
export const authGuard:CanActivateFn=(r,s)=>inject(AuthService).isLoggedIn()?true:inject(Router).parseUrl('/login');
// {path:'admin',component:Admin,canActivate:[authGuard],canActivateChild:[c],canDeactivate:[d]}
```
}
