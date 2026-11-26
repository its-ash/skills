@REF:components
§R{
  comp≡TS_class+HTML_tpl+CSS_sel∧@Component({...});
  standalone:true≡default(Angular≥19);v<19⇒explicit(standalone:true)∨NgModule;
  naming:¬suffix("Component")UNLESS_proj_cfg(e.g.Profile¬ProfileComponent);
  tree:ComponentTree(parent_hosts_children);
  host_el:DOM_matching_selector;view:DOM_rendered_by_tpl_inside_host;
  consume:add(Child→consumer.imports[])∧tpl:`<app-profile />`
}
§CFG{@Component}
```ts
@Component({
  selector: 'app-profile',
  template: `<img src="profile.jpg" alt="Profile photo" /><button (click)="save()">Save</button>`, // or templateUrl
  styles: `img { border-radius: 50%; }`, // or styleUrl / styleUrls
  imports: [ChildComp, MyPipe], // comps, directives, pipes
})
export class Profile { save() {} }
```
§PAT{control_flow}
```html
@if (user.isAdmin) { <admin-dashboard /> } @else if (user.isModerator) { <mod-dashboard /> } @else { <standard-dashboard /> }
@if (user.settings(); as settings) { <p>Theme: {{ settings.theme }}</p> }

@for (item of items(); track item.id; let i = $index, total = $count) {
  <li>{{ i + 1 }}/{{ total }}: {{ item.name }}</li>
} @empty { <li>No items</li> }
<!-- track REQUIRED(perf/DOM_reuse); implicit:$index,$count,$first,$last,$even,$odd -->

@switch (status()) { @case ('loading') { <app-spinner /> } @case ('error') { <app-error-msg /> } @default { <p>Unknown</p> } }
<!-- strict ===, NO fallthrough; exhaustive check: @default never; -->
```
