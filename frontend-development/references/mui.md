@REF:mui
§DEF{MUI_v9(`@mui/material@^9`,unified_w/_MUI_X_v9;skips_v8;v7+_Grid/sx_compat)|unified_`sx`_prop+theme_tokens+`slots`/`slotProps`+Base_UI_primitives|imports:`@mui/material`,`@mui/icons-material`}
§WHEN{`sx`_prop_styling|theme_customization/tokens|MUI_breakpoints_responsive|`slots`/`slotProps`|`useTheme`/`useMediaQuery`/MUI_hooks|v9_migration}

§SX{
  type:`import type{SxProps,Theme}from'@mui/material';`→`Record<string,SxProps<Theme>>`;
  inline(simple):`<Box sx={styles.container}><Typography sx={styles.header}>...</Typography></Box>`;
  split_file(complex,styles>100L):`MyComponent.styles.ts`→`export const myStyles:Record<string,SxProps<Theme>>={...}`;
  tokens:`sx={{color:'primary.main',bgcolor:'background.paper',p:2,borderRadius:1}}`;
  callback(dynamic/hover):`sx={(theme)=>({color:theme.palette.primary.main,'&:hover':{color:theme.palette.primary.dark}})}`;
  hook:`const theme=useTheme();`→`theme.palette.primary.{main,contrastText}`,`theme.shape.borderRadius`,`theme.spacing(2)`;
  v9_system_props:direct_shorthand_props_removed_on_`Box`/`Grid`(`<Box mt={2} color="primary.main"/>`❌⇒`<Box sx={{mt:2,color:'primary.main'}}/>`✅)
}

§LAYOUT{
  primitives:`Box`,`Paper`(`elevation={2}`),`Container`(`maxWidth="lg"`),`Stack`(`spacing={2}`,`direction="row"|"column"`);
  vertical⇒ALWAYS_`<Stack spacing={2}>`(v9_removed_`direction="column"|"column-reverse"`_on_`Grid`∧removed_`GridLegacy`);
  2D_12col_Grid(v7+/v9,¬`item`_prop):`<Grid container spacing={2}><Grid size={{xs:12,md:6}}>...</Grid></Grid>`|cards:`<Grid size={{xs:12,sm:6,md:4,lg:3}}>`;
  responsive_sx(¬manual_media_queries):`width:{xs:'100%',sm:'80%',md:'60%',lg:'40%',xl:'30%'}`,`display:{xs:'none',md:'block'}`,`fontSize:{xs:'1rem',md:'1.5rem',lg:'2rem'}`,`lineHeight:{xs:1.5,md:1.75}`
}

§COMP{
  slots(v9_standard):use_`slots`+`slotProps`(legacy_`components`/`componentsProps`/`<Slot>Component`/`<Slot>Props`_removed;v9.1+_native_`data-*`_in_`slotProps`+`DataAttributesOverrides`);
  base_ui_backed(v9):`NumberField`,`Menubar`(nested_submenus+roving_tabindex_a11y);
  typography:`variant="h1"|"h2"|"h4"|"h5"|"body1"|"body2"|"caption"`,`component="div"`,`color="text.secondary"`;
  buttons:`<Button variant="contained"|"outlined" color="secondary" size="small" startIcon={<AddIcon />}>`,`<IconButton aria-label="Delete" onClick={...}><DeleteIcon /></IconButton>`;
  form:`<Box component="form" onSubmit={handleSubmit}><Stack spacing={2}><TextField label="Email" type="email" value={...} onChange={...} fullWidth required error={!!errors.email} helperText={errors.email} /><Button type="submit" variant="contained">Submit</Button></Stack></Box>`;
  card:`<Card><CardContent>...</CardContent><CardActions><Button size="small">...</Button></CardActions></Card>`;
  dialog:`<Dialog open={open} onClose={handleClose}><DialogTitle>...</DialogTitle><DialogContent>...</DialogContent><DialogActions><Button onClick={handleClose}>Cancel</Button><Button onClick={handleConfirm} variant="contained">Confirm</Button></DialogActions></Dialog>`;
  loading:`<CircularProgress />`∈centered_`Box`(`sx={{p:3}}`)∨`<Stack spacing={1}><Skeleton variant="text" width="60%" /><Skeleton variant="rectangular" height={200} /><Skeleton variant="text" width="40%" /></Stack>`;
  hooks_ex:`import{useMuiSnackbar}from'@/hooks/useMuiSnackbar';`→`const{showSuccess,showError}=useMuiSnackbar();`
}

§CMD{
  codemod_sys:`npx @mui/codemod@latest v9.0.0/system-props <path>`;
  codemod_all:`npx @mui/codemod@latest deprecations/all <path>`
}

§R{
  1:type_all_`sx`_objects_with_`SxProps<Theme>`;
  2:use_theme_tokens(`primary.main`,`background.paper`,`spacing(2)`,`shape.borderRadius`)∧¬hardcoded_hex;
  3:use_spacing_scale(`p:2`,`mb:3`)∈`sx`∧¬arbitrary_px∧¬shorthand_system_props_on_`Box`/`Grid`;
  4:Grid_uses_`size={{xs,sm,md,lg}}`(¬legacy_`item`_prop,¬`direction="column"`⇒`Stack`);
  5:inner_slot_customization⇒`slots`/`slotProps`(¬`components`/`componentsProps`);
  6:runtime_dynamic_styles⇒callback_`sx`∨`useTheme`;
  7:styles>100_lines⇒separate_`*.styles.ts`_file;
  8:responsive⇒breakpoint_keys(`xs`,`sm`,`md`,`lg`,`xl`)_in_`sx`;
  9:compose_small_reusable_components(`LoadingSpinner`,`ErrorAlert`)∧dialogs/icon_btns⇒`aria`+`role`;
  10:align_all_`@mui/*`+`@mui/x-*`_to_`^9.0.0`∧test_multiple_viewports
}
