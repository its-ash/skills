@REF:shadcn-ui
§CFG{CLI:shadcn_v3;S∈{`npx shadcn@latest`,`pnpm dlx shadcn@latest`,`bunx --bun shadcn@latest`}←`packageManager`;use:{add,style/compose/debug,init/switch_presets,docs/examples/API}}

§CMD{INFO
  `$S info --json`→{`aliases`:use_prefix(`@/`, `~/`,¬hardcode);`isRSC`:true⇒`"use client"`_if(`useState`,`useEffect`,events,browser_API);`tailwindVersion`:`"v4"`⇒`@theme inline`|`"v3"`⇒`npx @tailwindcss/upgrade`_1st;`tailwindCssFile`:edit_in_place(¬new);`style`:e.g.`nova`,`vega`;`base`:`radix`∨`base`(BaseUI_1.0)⇒API/props;`iconLibrary`:`lucide`→`lucide-react`,`tabler`→`@tabler/icons-react`,etc.(¬assume);`resolvedPaths`:dest(ui,utils,hooks);`framework`:Next_AppRouter|Vite_SPA;`packageManager`:non-shadcn_deps}
}

§R{CRITICAL
  principles:search_registries>custom;compose(Settings=Tabs+Card+ctrls;Dash=Sidebar+Card+Chart+Table);built-in_variants(`variant="outline"`,`size="sm"`);semantic_colors(`bg-primary`,`text-muted-foreground`,¬`bg-blue-500`);
  style:`className`=layout_only(¬color/typo);`flex`+`gap-*`(¬`space-[xy]-*`);`size-*`(¬`w-* h-*`);`truncate`(¬`overflow-hidden text-ellipsis whitespace-nowrap`);¬manual_`dark:`⇒semantic_tokens;`cn()`(¬ternaries);¬manual_`z-index`_on_overlays(Dialog,Sheet,Popover);
  forms:`FieldGroup`+`Field`(¬`div`+`space-y-*`/`grid gap-*`);`InputGroup`⇒`InputGroupInput`/`InputGroupTextarea`(¬raw_`Input`/`Textarea`)+`InputGroupAddon`(btns);2-7_opts⇒`ToggleGroup`(¬Btn_loop);cb/radio_grp⇒`FieldSet`+`FieldLegend`(¬`div`+heading);val⇒`data-invalid`@`Field`+`aria-invalid`@ctrl;dis⇒`data-disabled`@`Field`+`disabled`@ctrl;
  struct:items∈grp(`SelectItem`∈`SelectGroup`,`DropdownMenuItem`∈`DropdownMenuGroup`,`CommandItem`∈`CommandGroup`);custom_trig⇒`asChild`(radix)∨`render`(base);`Dialog`/`Sheet`/`Drawer`⇒req_`DialogTitle`/`SheetTitle`/`DrawerTitle`(`sr-only`_if_hidden);full_Card(`CardHeader`/`CardTitle`/`CardDescription`/`CardContent`/`CardFooter`);Btn_load=`Spinner`+`data-icon`+`disabled`(¬`isPending`/`isLoading`);`TabsTrigger`∈`TabsList`;`Avatar`+`AvatarFallback`;
  components>markup:callout⇒`Alert`;empty⇒`Empty`;toast⇒`sonner`(`toast()`);hr⇒`Separator`(¬`<hr>`/`border-t`);load⇒`Skeleton`(¬`animate-pulse`);status⇒`Badge`(¬styled_`span`);
  icons:in_Btn⇒`data-icon="inline-start|inline-end"`;¬sizing_cls(`size-4`,`w-4 h-4`);pass_obj(`icon={CheckIcon}`,¬str_key);
  cli:¬decode/fetch_preset⇒`$S init --preset <code>`
}

§PAT{JSX_EXACT
```tsx
<FieldGroup><Field data-invalid><FieldLabel htmlFor="e">Email</FieldLabel><Input id="e" aria-invalid /><FieldDescription>Invalid.</FieldDescription></Field></FieldGroup>
<Button><SearchIcon data-icon="inline-start" />Search</Button>
```
}

§MAP{SELECT
  action⇒Button;inputs⇒Input,Select,Combobox,Switch,Checkbox,RadioGroup,Textarea,InputOTP,Slider;toggle(2-5)⇒ToggleGroup+ToggleGroupItem;data⇒Table,Card,Badge,Avatar;nav⇒Sidebar,NavigationMenu,Breadcrumb,Tabs,Pagination;overlay⇒Dialog(modal),Sheet(side),Drawer(bot),AlertDialog(confirm);feedback⇒sonner,Alert,Progress,Skeleton,Spinner;cmd⇒Command∈Dialog;chart⇒Chart(Recharts);layout⇒Card,Separator,Resizable,ScrollArea,Accordion,Collapsible;empty⇒Empty;menu⇒DropdownMenu,ContextMenu,Menubar;tip⇒Tooltip,HoverCard,Popover
}

§CMD{WORKFLOW
  1:`$S info`;2:check_`info.components`∨`resolvedPaths.ui`(¬import_missing,¬re-add);3:`$S search`;4:`$S docs <c>`→fetch_URLs,`$S view`(uninstalled),`$S add --diff`(preview);5:`$S add`(upd:`--dry-run`+`--diff`_1st);6:3p(@bundui,@magicui)⇒rewrite_non-UI_`@/components/ui/...`→`info.aliases.ui`(`@workspace/ui/components`);7:read_added_files,verify(sub-comps,imports,composition,CRITICAL),swap_icons→`info.iconLibrary`(`lucide-react`→`hugeicons`);8:¬guess_registry(@shadcn,@tailark)⇒ask_user;9:switch_preset⇒ask_user∈{reinstall:`$S init --preset <code> --force --reinstall`(overwrite_all);merge:`$S init --preset <code> --force --no-reinstall`→`info`→per_comp:`--dry-run`+`--diff`;skip:`$S init --preset <code> --force --no-reinstall`(cfg+CSS_only)};
  upd(¬raw_GitHub):`$S add <c> --dry-run`→`$S add <c> --diff <file>`→(no_local_Δ⇒overwrite|local_Δ⇒merge|user_approved⇒`--overwrite`);¬`--overwrite`_wo_approval
}

§CMD{QUICK_REF
```bash
S="npx shadcn@latest" # or pnpm dlx / bunx --bun
$S init --name my-app --preset base-nova [--template vite|next] [--monorepo]
$S init --preset a2r6bw --template vite # or --defaults (--template=next --preset=base-nova)
$S add button card dialog | $S add @magicui/shimmer-button | $S add --all
$S add button --dry-run | $S add button --diff button.tsx | $S add @acme/form --view button.tsx
$S search @shadcn -q "sidebar" | $S search @tailark -q "stats"
$S docs button dialog select | $S view @shadcn/button
```
  presets:{`base-nova`,`radix-nova`};tpl:{`next`,`vite`,`start`,`react-router`,`astro`(all_`--monorepo`),`laravel`(¬monorepo)};codes:Base62_`a*`(e.g.`a2r6bw`,https://ui.shadcn.com/)
}

§CHK{PRE_DELIVER[ ]:∀(§CMD.INFO,§R.CRITICAL,§CMD.WORKFLOW)}
