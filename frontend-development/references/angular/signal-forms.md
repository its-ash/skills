@REF:signal-forms

§R{
  stable_v22(@angular/forms/signals;exp_v21)⇒prefer_signal_forms_when_Angular_supports;
  model_driven∧type_safe∧signal_based;
  ∀field:¬(`null`∨`undefined`)in_val_or_type⇒init(`''`,`0`,`[] as T[]`);
  ¬import{`FormControl`,`FormGroup`,`FormArray`,`FormBuilder`}from`@angular/forms`;¬builder;¬`FormState`(use`FieldState`);
  `FormField`=`FieldTree`(structure)≠`FieldState`(signals)⇒MUST_CALL`f.field()`to_read_signals;
  exception:array`.length`NO`()`(`form.items.length`);
  inside`form()`schema_cb:paths_NOT_signals(¬callable)⇒use`valueOf(p)`∨`stateOf(p)`;
  `when`opt_ONLY_on`required()`,¬other_validators;
  `applyEach(arr,item=>...)`:1_arg_ONLY(¬index);
  `applyWhen(path,condFn,schemaFn)`:3_args;passes_mapped`path`to`schemaFn`(pass_parent_if_parent_needed);
  `submit(f,async()=>{...})`:auto_marks_all_touched,runs_iff_valid,cb_MUST_be`async`→`Promise`;
  validator_ok⇒return`undefined`(¬`null`);
  `validateAsync()`for_async(¬`validate()`):`params:({value})=>value()`∧`onError`REQUIRED;
  `resource()`:use`params:`(¬`request:`);
  `<select>`for_array⇒`<select multiple [formField]="...">`⊕checkboxes;checkboxes_bind`boolean`ONLY;
  nested`@for`:¬`$parent`⇒`let outerIndex=$index`;
  state_updates:mutate_model_signal(`this.model.update(...)`),¬`form.field.set()`
}
§IMP{
  `@angular/forms/signals`:`form`,`FormField`,`submit`,`disabled`,`hidden`,`readonly`,`debounce`,`applyWhen`,`applyEach`,`schema`,`validate`,`validateAsync`,`validateHttp`,`validateStandardSchema`,`metadata`,`required`,`email`,`min`,`max`,`minLength`,`maxLength`,`pattern`;
  `@angular/core`:`signal`,`resource`
}
§API{
  create:`userForm=form(this.userModel,(p)=>{...}[,{injector}])`;
  validators:`required(p.x,{message?,when?:({valueOf})=>bool})`,`email(p.x,{message?})`,`min(p.n,18,{message?})`,`max(p.n,100)`,`minLength(p.s,8)`,`maxLength(p.s,500)`,`pattern(p.s,/^\d{5}$/)`;
  rules:`disabled(p.pw,({valueOf})=>!valueOf(p.acct))`,`hidden(p.ship,({valueOf})=>valueOf(p.same))`(keeps_in_model),`readonly(p.u)`,`debounce(p.u,300)`(ms_UI→model);
  state_sigs:`f.x().value()`,`f().valid()`,`f().invalid()`,`f().errors():ValidationError[]`,`f.x().getError('minLength')`,`f().pending()`,`f().touched()`,`f().dirty()`,`f().disabled()`,`f().hidden()`,`f().readonly()`,`f().reset()`;
  err_shape:`interface ValidationError{readonly kind:string;readonly message?:string;}`;
  rule_ctx:`({value,fieldTree,state,valueOf,stateOf,pathKeys})=>{...}`(`value:Signal<T>`,`fieldTree:FieldTree<T>`,`state:FieldState<T>`,`valueOf:(p)=>T`,`stateOf:(p)=>FieldState`,`pathKeys:Signal<string[]>`)
}
§PAT{
```ts
validate(p.user, ({value, state}) => {
  if (state.touched() && value() === 'admin') return {kind: 'reserved', message: '...'};
  return undefined;
});
validateAsync(p.user, {
  params: ({value}) => value(),
  factory: (sig) => resource({params: sig, loader: async ({params: v}) => v === 'taken'}),
  onSuccess: (taken) => (taken ? {kind: 'taken', message: '...'} : undefined),
  onError: () => ({kind: 'error', message: '...'}),
});
applyWhen(p.ssn, ({stateOf}) => stateOf(p.ssn).touched(), (ssnPath) => { required(ssnPath); });
applyEach(p.items, (item) => { required(item.name); });
```
```html
<form (submit)="onSubmit(); $event.preventDefault()">
  <input [formField]="f.name" />
  <input type="checkbox" [formField]="f.isAdmin" />
  <input type="radio" value="economy" [formField]="f.tier" />
  <select [formField]="f.country"><option value="us">US</option></select>
  <select multiple [formField]="f.extras"><option value="wifi">WiFi</option></select>
  @for (item of f.items; track $index; let outerIndex = $index) {
    @for (opt of item.options; track $index) {
      <button type="button" (click)="removeOpt(outerIndex, $index)">Remove</button>
    }
  }
  <button [disabled]="f().invalid() || f().pending()">Submit</button>
</form>
```
}
§ANTI{
  forbidden_attrs_with_`[formField]`:`name`,`min`,`max`,`[attr.min]`,`[attr.max]`,`value`,`[value]`,`[attr.value]`,`[disabled]`,`[readonly]`;
  `form.field.valid()`|`form.field.value()`|`form.invalid()`|`form.field()()`|`form.items().length`⇒always`form.field().valid()`|`.value()`|`form().invalid()`,except`form.items.length`;
  `({touched})=>touched()`⇒`({state})=>state.touched()`;
  `applyWhen(p.x,()=>p.x()==='a')`⇒`({valueOf})=>valueOf(p.x)==='a'`;
  `validate(s.x,{value}=>...)`⇒`validate(s.x,({value})=>...)`;
  `<select [formField]="f.tags">`on`string[]`⇒`<select multiple [formField]="f.tags">`
}
§ERR{
  `Property 'value' does not exist on type 'FieldTree'`⇒call_field_first:`this.form.field().value()`;
  `Property 'set' does not exist on type 'FieldTree'`⇒update_model_sig:`this.model.update(m=>({...m,...}))`;
  `Type 'string[]' is not assignable to type 'string'`⇒use`<select multiple [formField]="...">`
}
