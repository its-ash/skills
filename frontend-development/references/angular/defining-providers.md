@REF:defining-providers
§R{
  auto:@Injectable({providedIn:'root'})∨InjectionToken<T>('id',{providedIn:'root',factory:()=>...})(non-class:cfg,fn,primitive);
  manual(providers[]):lacks_providedIn∨comp_scoped_instance∨runtime_cfg;
  scopes:{app_bootstrap:global_singleton(HTTP,log,app_cfg);comp_dir:isolated,destroyed_with_comp(state,forms);route:feature_svc_loaded_only_with_route}
}
§PAT{tokens_and_providers}
```ts
export const APP_CONFIG = new InjectionToken<AppConfig>('app.config',{providedIn:'root',factory:()=>({apiUrl:'https://api.example.com'})});
// providers:[...] variants:
LocalService // ≡ {provide:LocalService,useClass:LocalService}
{provide:Logger,useClass:BetterLogger} // swap impl
{provide:API_URL_TOKEN,useValue:'https://api.example.com'} // static
{provide:ApiClient,useFactory:(http=inject(HttpClient))=>new ApiClient(http)}
{provide:OldLogger,useExisting:NewLogger} // alias
{provide:INTERCEPTOR_TOKEN,useClass:AuthInterceptor,multi:true} // array
export function provideAnalytics(cfg:AnalyticsConfig):Provider[]{return[{provide:ANALYTICS_CONFIG,useValue:cfg},AnalyticsService];}
```
