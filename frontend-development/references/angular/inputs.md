@REF:inputs
§R{
  pkg:@angular/core;
  prefer:input()→InputSignal¬@Input()(reactivity∧type_safety);
  required:input.required<T>()⇒build_time_error_if_omitted;
  transform_fn:must_be(pure∧statically_analyzable);
  legacy:@Input({required,transform})⇒supported¬new_code;
  anti:¬collide_DOM_props(id,title)
}
§PAT{
  opt:name=input('Guest');req:age=input.required<number>();derived:computed(()=>this.name());
  opts:input('',{alias:'btnLabel'});input(false,{transform:booleanAttribute});
  two_way:value=model(0);this.value.update(v=>v+1);//tpl:<custom-counter [(value)]="mySignal|myProperty"/>
  tpl:<app-user [name]="userName" [age]="25"/>;
  legacy:@Input({required:true})value=0;@Input({transform:trimString})label=''
}
