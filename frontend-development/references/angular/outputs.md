@REF:outputs
§R{
  prefer_`output()`(@angular/core→`OutputEmitterRef`)_over_legacy_`@Output()`+`EventEmitter`;
  naming:camelCase∧¬`on`_prefix(`valueChanged`¬`onValueChanged`);
  ¬DOM_bubbling(unlike_native_events);
  ¬collide_native_DOM_events(`click`,`submit`,etc)
}
§PAT{
  modern:```ts
import { output } from '@angular/core';
panelClosed = output<void>();
valueChanged = output<number>();
changed = output<number>({ alias: 'valueChanged' }); // template:(valueChanged),class:changed
this.valueChanged.emit(newVal);
  ```
  tpl:`<custom-slider (panelClosed)="savePanelState()" (valueChanged)="logValue($event)" />`
  dynamic_sub:```ts
const ref = viewContainerRef.createComponent(CustomSlider);
const sub = ref.instance.valueChanged.subscribe(v => console.log(v));
sub.unsubscribe(); // optional:Angular auto-cleans destroyed cmps
  ```
  legacy(supported,¬recommended):```ts
@Output() valueChanged = new EventEmitter<number>();
@Output('customEventName') changed = new EventEmitter<void>();
  ```
}
