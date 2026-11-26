@REF:mui
§DEF{MUI_v7:unified_`sx`_prop+theme_tokens+slot_API|imports:`@mui/material`,`@mui/icons-material`}
§WHEN{`sx`_prop_styling|theme_customization/tokens|MUI_breakpoints_responsive|`useTheme`/`useMediaQuery`/MUI_hooks}

§SX{
  type:`import type{SxProps,Theme}from'@mui/material';`→`Record<string,SxProps<Theme>>`;
  inline(simple):`<Box sx={styles.container}><Typography sx={styles.header}>...</Typography></Box>`;
  split_file(complex,styles>100L):`MyComponent.styles.ts`→`export const myStyles:Record<string,SxProps<Theme>>={...}`;
  tokens:`sx={{color:'primary.main',bgcolor:'background.paper',p:2,borderRadius:1}}`;
  callback(dynamic/hover):`sx={(theme)=>({color:theme.palette.primary.main,'&:hover':{color:theme.palette.primary.dark}})}`;
  hook:`const theme=useTheme();`→`theme.palette.primary.{main,contrastText}`,`theme.shape.borderRadius`,`theme.spacing(2)`
}

§LAYOUT{
  primitives:`Box`,`Paper`(`elevation={2}`),`Container`(`maxWidth="lg"`),`Stack`(`spacing={2}`,`direction="row"`);
  prefer_`Box`/`Stack`_for_layout|`Grid`_for_12col:`<Grid container spacing={2}><Grid item xs={12} md={6}>...</Grid></Grid>`|cards:`xs={12} sm={6} md={4} lg={3}`;
  responsive_sx(¬manual_media_queries):`width:{xs:'100%',sm:'80%',md:'60%',lg:'40%',xl:'30%'}`,`display:{xs:'none',md:'block'}`,`fontSize:{xs:'1rem',md:'1.5rem',lg:'2rem'}`,`lineHeight:{xs:1.5,md:1.75}`
}

§COMP{
  typography:`variant="h1"|"h2"|"h4"|"h5"|"body1"|"body2"|"caption"`,`component="div"`,`color="text.secondary"`;
  buttons:`<Button variant="contained"|"outlined" color="secondary" size="small" startIcon={<AddIcon />}>`,`<IconButton onClick={...}><DeleteIcon /></IconButton>`;
  form:`<Box component="form" onSubmit={handleSubmit}><Stack spacing={2}><TextField label="Email" type="email" value={...} onChange={...} fullWidth required error={!!errors.email} helperText={errors.email} /><Button type="submit" variant="contained">Submit</Button></Stack></Box>`;
  card:`<Card><CardContent>...</CardContent><CardActions><Button size="small">...</Button></CardActions></Card>`;
  dialog:`<Dialog open={open} onClose={handleClose}><DialogTitle>...</DialogTitle><DialogContent>...</DialogContent><DialogActions><Button onClick={handleClose}>Cancel</Button><Button onClick={handleConfirm} variant="contained">Confirm</Button></DialogActions></Dialog>`;
  loading:`<CircularProgress />`∈centered_`Box`(`p:3`)∨`<Stack spacing={1}><Skeleton variant="text" width="60%" /><Skeleton variant="rectangular" height={200} /><Skeleton variant="text" width="40%" /></Stack>`;
  hooks_ex:`import{useMuiSnackbar}from'@/hooks/useMuiSnackbar';`→`const{showSuccess,showError}=useMuiSnackbar();`
}

§R{
  1:type_all_`sx`_objects_with_`SxProps<Theme>`;
  2:use_theme_tokens(`primary.main`,`background.paper`,`spacing(2)`,`shape.borderRadius`)∧¬hardcoded_hex;
  3:use_spacing_scale(`p:2`,`mb:3`)∧¬arbitrary_px;
  4:runtime_dynamic_styles⇒callback_`sx`∨`useTheme`;
  5:styles>100_lines⇒separate_`*.styles.ts`_file;
  6:responsive⇒breakpoint_keys(`xs`,`sm`,`md`,`lg`,`xl`)_in_`sx`;
  7:compose_small_reusable_components(`LoadingSpinner`,`ErrorAlert`);
  8:dialogs/interactive⇒add_`aria`+`role`;
  9:test_multiple_viewport_sizes
}
