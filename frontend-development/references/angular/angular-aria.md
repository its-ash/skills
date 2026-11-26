@REF:angular-aria
§CORE{
  pkg:`@angular/aria`(headless_a11y_directives:kbd,ARIA_attrs,focus,SR);
  pre:verify_installed_else(`npm install @angular/aria`);
  role:agent=HTML+CSS,directives=a11y_logic;
  styling:0_default_styles⇒CSS_MUST_target(`[aria-expanded="true"|"false"]`,`[aria-selected="true"]`,`[aria-disabled="true"]`,`[aria-current="page"]`)
}
§R{
  1:¬native(`<select>`)_for_these_patterns⇒use(`ng*`directives);
  2:write_CSS_manually→target_native_ARIA_attrs;
  3:heavy_panels⇒wrap_in(`<ng-template ngAccordionContent|ngTabContent>`)_for_lazy_render
}
§PAT{
  1_Accordion:{
    use:FAQs|long_forms|progressive_disclosure(1_at_a_time:`[multiExpandable]="false"`);¬primary_nav;¬multi_simultaneous;
    imp:`{AccordionContent,AccordionGroup,AccordionPanel,AccordionTrigger}`←`@angular/aria/accordion`;
    dir:`ngAccordionGroup`,`ngAccordionTrigger`,`ngAccordionPanel`,`ngAccordionContent`;
    ```html
    <div ngAccordionGroup [multiExpandable]="false">
      <button ngAccordionTrigger panelId="p1" class="hdr">S1<span class="icon">▼</span></button>
      <div ngAccordionPanel panelId="p1"><ng-template ngAccordionContent>...</ng-template></div>
    </div>
    ```
    css:`.hdr[aria-expanded='true'] .icon{transform:rotate(180deg)}`;panel_dir_handles_DOM_removal(style_panel_transition)
  };
  2_Listbox:{
    use:visible_single|multi_select_list(¬dropdowns);
    imp:`{Listbox,Option}`←`@angular/aria/listbox`;dir:`ngListbox`,`ngOption`;
    ```html
    <ul ngListbox [(values)]="selectedItems" orientation="horizontal" [multi]="true">
      <li ngOption value="apple" class="opt">Apple</li>
    </ul>
    ```
    css:`.opt[aria-selected='true']`;focus=`:focus-visible`∨`[data-active]`(roving_tabindex|activedescendant)
  };
  3_Combobox_Select_Multiselect:{
    kind:{Combobox:text_input+popup(autocomplete);Select:`[readonly]="true"`+single_Listbox;Multiselect:`[readonly]="true"`+multi_Listbox};
    use:low_level_custom_filter|unique_sel|specialized_input_popup_sync;
    imp:`{Combobox,ComboboxInput,ComboboxPopupContainer}`←`@angular/aria/combobox` + `{Listbox,Option}`←`@angular/aria/listbox`;
    dir:`ngCombobox`,`ngComboboxInput`,`ngComboboxPopupContainer`,`ngListbox`,`ngOption`;
    ```html
    <div ngCombobox [readonly]="true">
      <button ngComboboxInput class="sel-trigger">{{ selectedValue() || 'Choose' }}</button>
      <ng-template ngComboboxPopupContainer>
        <ul ngListbox [(values)]="selectedValue" class="menu"><li ngOption value="o1">O1</li></ul>
      </ng-template>
    </div>
    ```
    css:float_dropdown(often_w/_CDK_Overlay)
  };
  4_Menu_Menubar:{
    use:desktop_cmd_bars(File/Edit/View)|actions|context_menus;¬form_sel;¬standalone_action_lists;¬mobile_constrained_horiz;
    imp:`{MenuBar,Menu,MenuContent,MenuItem}`←`@angular/aria/menu`;
    dir:`ngMenuBar`,`ngMenu`,`ngMenuItem`,`ngMenuTrigger`;
    ```html
    <ul ngMenuBar><li ngMenuItem value="file"><button ngMenuTrigger [menu]="fileMenu">File</button></li></ul>
    <ul ngMenu #fileMenu="ngMenu"><li ngMenuItem value="new">New</li></ul>
    ```
    css:menubar=`display:flex`;toggle_submenu_via_trigger_state
  };
  5_Tabs:{
    use:layered_1_visible_panel(settings|docs|dashboards);¬steppers;¬>7-8_sections;
    imp:`{Tab,Tabs,TabList,TabPanel,TabContent}`←`@angular/aria/tabs`;
    dir:`ngTabs`,`ngTabList`,`ngTab`,`ngTabPanel`,`ngTabContent`;
    ```html
    <div ngTabs>
      <ul ngTabList><li ngTab value="p" class="tab-btn">P</li></ul>
      <div ngTabPanel value="p"><ng-template ngTabContent>...</ng-template></div>
    </div>
    ```
    css:`.tab-btn[aria-selected='true']`
  };
  6_Toolbar:{
    use:group_frequent_related_controls(formatting|media)_w/_arrow_nav;
    imp:`{Toolbar,ToolbarWidget,ToolbarWidgetGroup}`←`@angular/aria/toolbar`;
    dir:`ngToolbar`,`ngToolbarWidget`,`ngToolbarWidgetGroup`;
    ```html
    <div ngToolbar>
      <div ngToolbarWidgetGroup [multi]="true" role="group" aria-label="Formatting">
        <button ngToolbarWidget value="bold" class="tool-btn">B</button>
      </div>
    </div>
    ```
    css:`.tool-btn[aria-pressed='true']`(toggle)|`.tool-btn[aria-checked='true']`(radio)
  };
  7_Tree:{
    use:deep_hierarchical_expand_collapse(fs|org|site_arch);¬flat_lists;¬tables;¬simple_menus;
    imp:`{Tree,TreeItem,TreeItemGroup}`←`@angular/aria/tree`;
    dir:`ngTree`,`ngTreeItem`,`ngTreeGroup`;
    ```html
    <ul ngTree><li ngTreeItem value="docs"><span class="lbl">Docs</span><ul ngTreeGroup><li ngTreeItem value="cv">CV</li></ul></li></ul>
    ```
    css:`li[aria-expanded='true']>.lbl::before`(chevron_90deg|show_hide),`padding-left`_on_nested_groups
  };
  8_Grid:{
    use:2D_arrow_nav(data_tables|calendars|spreadsheets|interactive_layouts);
    dir:`ngGrid`,`ngGridRow`,`ngGridCell`,`ngGridCellWidget`;
    ```html
    <table ngGrid [multi]="true" [enableSelection]="true">
      <tr ngGridRow><th ngGridCell role="columnheader">Name</th></tr>
      <tr ngGridRow><td ngGridCell [(selected)]="sel"><button ngGridCellWidget (activated)="onAct()">Act</button></td></tr>
    </table>
    ```
    css:`[ngGridCell][aria-selected='true']`,`[ngGridCell]:focus-visible`(roving_tabindex)∨`[aria-activedescendant]`_on_container
  }
}
