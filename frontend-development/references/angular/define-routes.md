@REF:define-routes
§R{
  cfg:routes:Routes[]∧ApplicationConfig:{providers:[provideRouter(routes)]};
  match:first_match_wins⇒specific_before_generic;
  paths:{static:'admin',param:'user/:id',wildcard:'**'(NotFound,MUST_be_last)};
  redirect:{path:'articles',redirectTo:'/blog'};
  title:{path:'home',component:Home,title:'Home Page'}(a11y;static∨ResolveFn∨TitleStrategy);
  meta:{data:{...},providers:[...](scoped_to_route+children)};
  nested:children[]⇒parent_tpl_MUST_have_<router-outlet />
}
§CFG{nested_route}
```ts
{path: 'product/:id', component: Product, children: [{path: 'info', component: ProductInfo}, {path: 'reviews', component: ProductReviews}]}
```
