@REF:template-driven-forms

§R{
  two_way_binding`[(ngModel)]`for_simple_forms;
  import`FormsModule`from`@angular/forms`;
  directives:`NgModel`(`[(ngModel)]`),`NgForm`(auto_top_FormGroup_on`<form>`),`NgModelGroup`(nested_FormGroup);
  EVERY`[(ngModel)]`element_MUST_have`name`attr(registers_with_parent`NgForm`);
  submit:`(ngSubmit)`on`<form>`,disable_btn`[disabled]="!userForm.form.valid"`;
  reset:`userForm.reset()`(clears_vals+flags→pristine)
}
§CLS{
  visited:`ng-touched`/`ng-untouched`;
  changed:`ng-dirty`/`ng-pristine`;
  valid:`ng-valid`/`ng-invalid`;
  submitted(`<form>`only):`ng-submitted`
}
§PAT{
```html
<form #userForm="ngForm" (ngSubmit)="onSubmit()">
  <input type="text" required [(ngModel)]="user.name" name="name" #nameCtrl="ngModel" />
  @if (nameCtrl.invalid && (nameCtrl.dirty || nameCtrl.touched)) {
    @if (nameCtrl.errors?.['required']) { <div>Name is required.</div> }
  }
  <select [(ngModel)]="user.role" name="role">
    <option value="Admin">Admin</option>
  </select>
  <button type="submit" [disabled]="!userForm.form.valid">Submit</button>
  <button type="button" (click)="userForm.reset()">Reset</button>
</form>
```
```css
.ng-valid[required], .ng-valid.required { border-left: 5px solid #42a948; }
.ng-invalid:not(form) { border-left: 5px solid #a94442; }
```
}
