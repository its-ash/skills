@REF:creating-services
§R{
  purpose:reusable_data_fetch∨business_logic∨state_mgmt(shared_across_comps/svcs);
  default:@Injectable({providedIn:'root'})⇒singleton(app)∧auto_available(¬providers[])∧tree_shakeable(bundled⇔injected);
  inject:inject(Svc)∈class_field_init(Component|Directive|Injectable)
}
§CMD{
  ng generate service my-data
}
§PAT{define_and_inject}
```ts
import {Injectable, Component, inject} from '@angular/core';

@Injectable({providedIn: 'root'})
export class BasicDataStore {
  private advanced = inject(AdvancedDataStore);
  private data: string[] = [];
  addData(item: string): void { this.data.push(item); }
  getData(): string[] { return [...this.data, ...this.advanced.getData()]; }
}

@Component({selector: 'app-example', template: `<p>{{ dataStore.getData().length }}</p>`})
export class Example {
  dataStore = inject(BasicDataStore);
}
```
§PAT{advanced_providers}
- comp_isolated:@Component({providers:[MyService]})
- dynamic_creation:factory_providers(useFactory)
- config_objects:value_providers(useValue)
