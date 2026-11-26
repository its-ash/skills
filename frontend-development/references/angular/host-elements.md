@REF:host-elements
§R{
  host_el:DOM_el_matching_selector(template_renders_inside);
  prefer:@Component({host:{...}})¬(@HostBinding|@HostListener);
  legacy:@HostBinding|@HostListener⇒backwards_compat_only¬new_code;
  collision(host_vs_consumer):static+static⇒consumer;static+dynamic⇒dynamic;dynamic+dynamic⇒component_host;
  host_attr:inject(new HostAttributeToken('attr'))@construction⇒reads_static_attr(throws_if_missing_unless_{optional:true})
}
§PAT{
  @Component({selector:'custom-slider',host:{'role':'slider','[attr.aria-valuenow]':'value','[class.active]':'isActive()','[style.color]':'color()','[tabIndex]':'disabled?-1:0','(keydown)':'onKeyDown($event)'}})
  @HostBinding('tabIndex')get tabIndex(){...} | @HostListener('keydown',['$event'])
  inject(new HostAttributeToken('type'))//<app-btn type="primary">
}
