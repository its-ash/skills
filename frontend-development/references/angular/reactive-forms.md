@REF:reactive-forms
§R{
  model-driven+observables+sync_model>template-driven;
  core(`@angular/forms`):{`FormControl`:val+validity;`FormGroup`:obj_grp;`FormArray`:indexed_arr;`FormBuilder`:factory_svc}
}
§PAT{
  setup(`imports:[ReactiveFormsModule]`):```ts
private fb=inject(FormBuilder);
profileForm=this.fb.group({firstName:['',Validators.required],lastName:[''],address:this.fb.group({street:[''],city:['']}),aliases:this.fb.array([this.fb.control('')])});
get aliases(){return this.profileForm.get('aliases') as FormArray;}
addAlias(){this.aliases.push(this.fb.control(''));}
```
  tpl:{`[formGroup]`:`<form>`|`<div>`;`formControlName`:ctrl;`formGroupName`:nested_grp;`formArrayName`:nested_arr;`[formControl]`:standalone}:```html
<form [formGroup]="profileForm" (ngSubmit)="onSubmit()">
 <input formControlName="firstName"/>
 <div formGroupName="address"><input formControlName="street"/></div>
 <div formArrayName="aliases">@for(a of aliases.controls;track $index){<input [formControlName]="$index"/>}</div>
 <button type="submit" [disabled]="!profileForm.valid">Submit</button>
</form>
```
  events(v18+,`ValueChangeEvent`,`StatusChangeEvent`←`@angular/forms`,tracks:value|status|pristine|touched|reset|submit):
  `this.profileForm.events.subscribe(e=>{if(e instanceof ValueChangeEvent)console.log(e.value);});`
}
§API{
  upd:{`patchValue(p)`:partial,silent_mismatch;`setValue(v)`:full,strict_struct};
  state:{`markAsTouched()`|`markAllAsTouched()`:err_on_submit;`markAsDirty()`|`markAsPristine()`:modified;`updateValueAndValidity()`:recalc};
  opts:`{emitEvent:false}`⊕`{onlySelf:true}`
}
