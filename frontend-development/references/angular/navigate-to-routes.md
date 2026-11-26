@REF:navigate-to-routes
§PAT{
  declarative(`RouterLink`,`RouterLinkActive`←`@angular/router`):
`<a routerLink="/dashboard" routerLinkActive="active-link">Dashboard</a>`
`<a [routerLink]="['/user',userId]">Profile</a>`
  paths:{abs:`/`-prefixed(`/settings`);rel:¬`/`∧`../`_up_1}
  programmatic(`inject(Router)`,`inject(ActivatedRoute)`):
`this.router.navigate(['/profile']);`
`this.router.navigate(['/search'],{queryParams:{q:'angular'},fragment:'results'});`
`this.router.navigate(['edit'],{relativeTo:this.route});`
`this.router.navigateByUrl('/products/123?view=details');` // abs|full_URL
`this.router.navigateByUrl('/login',{replaceUrl:true});`
}
§API{params:{route:`/user/123`;query:`/search?q=query`;matrix:`/products;category=books`}}
