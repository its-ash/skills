@REF:di-fundamentals
§R{
  DI:provide(objects|fns|primitives)∧inject(request_values)⇒maintainability,scalability,testability;
  participants(auto):@Component,@Directive,@Injectable;
  svc:@Injectable({providedIn:'root'})⇒app_singleton(recommended_default);
  svc_uses:{data_API_clients,state_mgmt,auth_authz,logging_err_handle,utils}
}
§PAT{inject_contexts}
valid(inject()):
1:class_field_initializers(recommended)∈{Component,Directive,Service}
2:constructor_body
3:functional_route_guards∧resolvers
4:provider_useFactory_fns
```ts
@Injectable({providedIn: 'root'})
export class MyService { private http = inject(HttpClient); }

@Component({selector: 'app-nav', template: ``})
export class Navbar {
  private router = inject(Router);        // field initializer
  private s2: MyService;
  constructor() { this.s2 = inject(MyService); } // constructor body
}

@Directive({})
export class MyDirective { private el = inject(ElementRef); }

export const authGuard = () => inject(AuthService).isAuthenticated();
```
