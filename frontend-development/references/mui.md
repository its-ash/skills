# MUI v7 Patterns

Material‑UI v7 introduces a unified `sx` styling system, theme tokens, and a slot‑based component API. Use these patterns to build consistent, responsive UIs with type safety.

## When to Use
- You need to style MUI components with the `sx` prop.
- You are customizing the MUI theme or accessing theme values.
- You require responsive layouts using MUI breakpoints.
- You use MUI utilities such as `useTheme`, `useMediaQuery`, or custom MUI hooks.

---

## Styling with the `sx` Prop
### Inline Styles (simple components)
```tsx
import { Box, Typography, Button } from '@mui/material';
import type { SxProps, Theme } from '@mui/material';

const styles: Record<string, SxProps<Theme>> = {
  container: { p: 2, display: 'flex', flexDirection: 'column', gap: 2 },
  header: { mb: 3, fontSize: '1.5rem', fontWeight: 600 },
};

export function SimpleCard() {
  return (
    <Box sx={styles.container}>
      <Typography sx={styles.header}>Title</Typography>
      <Button variant="contained">Action</Button>
    </Box>
  );
}
```
### Separate Styles File (complex components)
```tsx
// MyComponent.styles.ts
import type { SxProps, Theme } from '@mui/material';
export const myStyles: Record<string, SxProps<Theme>> = {
  container: { p: 3, maxWidth: 800, mx: 'auto' },
  header: { display: 'flex', justifyContent: 'space-between', mb: 3 },
  // add more entries as needed
};
```
```tsx
// MyComponent.tsx
import { Box, Typography } from '@mui/material';
import { myStyles } from './MyComponent.styles';

export function MyComponent() {
  return (
    <Box sx={myStyles.container}>
      <Typography sx={myStyles.header}>Header</Typography>
      {/* component body */}
    </Box>
  );
}
```
---

## Layout Components
```tsx
import { Box, Paper, Container, Stack } from '@mui/material';

<Box sx={{ p: 2, bgcolor: 'background.paper' }}>Content</Box>
<Paper elevation={2} sx={{ p: 3 }}>Content</Paper>
<Container maxWidth="lg">Content</Container>
<Stack spacing={2} direction="row">
  <Box>Item 1</Box>
  <Box>Item 2</Box>
</Stack>
```
---

## Grid System
```tsx
import { Grid } from '@mui/material';

{/* 12‑column layout */}
<Grid container spacing={2}>
  <Grid item xs={12} md={6}>Left half</Grid>
  <Grid item xs={12} md={6}>Right half</Grid>
</Grid>

{/* Responsive cards */}
<Grid container spacing={3}>
  <Grid item xs={12} sm={6} md={4} lg={3}>Card</Grid>
  {/* repeat for more cards */}
</Grid>
```
---

## Typography
```tsx
import { Typography } from '@mui/material';

<Typography variant="h1">Heading 1</Typography>
<Typography variant="h2">Heading 2</Typography>
<Typography variant="body1">Body text</Typography>
<Typography variant="caption">Small text</Typography>

{/* Custom styling */}
<Typography
  variant="h4"
  sx={{ color: 'primary.main', fontWeight: 600, mb: 2 }}
>
  Custom Heading
</Typography>
```
---

## Buttons & Icons
```tsx
import { Button, IconButton } from '@mui/material';
import { Add as AddIcon, Delete as DeleteIcon } from '@mui/icons-material';

<Button variant="contained">Contained</Button>
<Button variant="outlined" color="secondary">Outlined</Button>
<Button startIcon={<AddIcon />}>Add Item</Button>
<IconButton onClick={handleDelete}><DeleteIcon /></IconButton>
```
---

## Theme Integration
### Access Theme Values
```tsx
import { Box, useTheme } from '@mui/material';

export function ThemedBox() {
  const theme = useTheme();
  return (
    <Box
      sx={{
        p: 2,
        bgcolor: theme.palette.primary.main,
        color: theme.palette.primary.contrastText,
        borderRadius: theme.shape.borderRadius,
      }}
    >
      Themed content
    </Box>
  );
}
```
### Theme Tokens Directly in `sx`
```tsx
<Box sx={{ color: 'primary.main', bgcolor: 'background.paper', p: 2, borderRadius: 1 }} />
```
### Callback Form for Complex Logic
```tsx
<Box
  sx={(theme) => ({
    color: theme.palette.primary.main,
    '&:hover': { color: theme.palette.primary.dark },
  })}
/>
```
---

## Responsive Design
### Breakpoint‑Based Values
```tsx
<Box
  sx={{
    width: { xs: '100%', sm: '80%', md: '60%', lg: '40%', xl: '30%' },
    display: { xs: 'none', md: 'block' },
  }}
>
  Responsive box
</Box>
```
### Responsive Typography
```tsx
<Typography
  sx={{
    fontSize: { xs: '1rem', md: '1.5rem', lg: '2rem' },
    lineHeight: { xs: 1.5, md: 1.75 },
  }}
>
  Adaptive text
</Typography>
```
---

## Forms
```tsx
import { Box, TextField, Stack, Button } from '@mui/material';

export function SimpleForm({ handleSubmit, email, setEmail, errors }) {
  return (
    <Box component="form" onSubmit={handleSubmit}>
      <Stack spacing={2}>
        <TextField
          label="Email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          fullWidth
          required
          error={!!errors.email}
          helperText={errors.email}
        />
        <Button type="submit" variant="contained">Submit</Button>
      </Stack>
    </Box>
  );
}
```
---

## Common Component Patterns
### Card
```tsx
import { Card, CardContent, CardActions, Typography, Button } from '@mui/material';

<Card>
  <CardContent>
    <Typography variant="h5" component="div">Title</Typography>
    <Typography variant="body2" color="text.secondary">Description</Typography>
  </CardContent>
  <CardActions>
    <Button size="small">Learn More</Button>
  </CardActions>
</Card>
```
### Dialog (Modal)
```tsx
import { Dialog, DialogTitle, DialogContent, DialogActions, Button } from '@mui/material';

export function ConfirmDialog({ open, handleClose, handleConfirm }) {
  return (
    <Dialog open={open} onClose={handleClose}>
      <DialogTitle>Confirm Action</DialogTitle>
      <DialogContent>Are you sure you want to proceed?</DialogContent>
      <DialogActions>
        <Button onClick={handleClose}>Cancel</Button>
        <Button onClick={handleConfirm} variant="contained">Confirm</Button>
      </DialogActions>
    </Dialog>
  );
}
```
### Loading States
```tsx
import { Box, CircularProgress, Skeleton, Stack } from '@mui/material';

{/* Spinner */}
<Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
  <CircularProgress />
</Box>

{/* Skeleton placeholders */}
<Stack spacing={1}>
  <Skeleton variant="text" width="60%" />
  <Skeleton variant="rectangular" height={200} />
  <Skeleton variant="text" width="40%" />
</Stack>
```
---

## MUI‑Specific Hooks
```tsx
import { useMuiSnackbar } from '@/hooks/useMuiSnackbar';
import { Button } from '@mui/material';

export function SaveButton() {
  const { showSuccess, showError } = useMuiSnackbar();

  const handleSave = async () => {
    try {
      await saveData();
      showSuccess('Saved successfully');
    } catch {
      showError('Failed to save');
    }
  };

  return <Button onClick={handleSave}>Save</Button>;
}
```
---

## Best Practices
1. **Type `sx` Props** – import `SxProps` and `Theme` and type style objects. This provides autocomplete and prevents runtime errors.
2. **Use Theme Tokens** – reference colors, spacing, and radii via token names (`primary.main`, `spacing(2)`, `shape.borderRadius`). Avoid hard‑coded hex values.
3. **Consistent Spacing** – use the spacing scale (`p: 2`, `mb: 3`). Do not mix arbitrary pixel values.
4. **Prefer Callback `sx` for Dynamic Styles** – when a style depends on runtime values, use the function form of `sx`.
5. **Keep Style Objects Small** – split large style objects into separate files to improve readability.
6. **Leverage Breakpoints in `sx`** – define responsive values directly in the `sx` object instead of writing media queries.
7. **Reuse Components** – create small, focused components (e.g., `LoadingSpinner`, `ErrorAlert`) and compose them.
---

## Checklist
- [ ] Import MUI components from `@mui/material`.
- [ ] Type all `sx` objects with `SxProps<Theme>`.
- [ ] Use theme tokens (`primary.main`, `background.paper`, etc.) in `sx`.
- [ ] Apply breakpoint keys (`xs`, `sm`, `md`, `lg`, `xl`) for responsive values.
- [ ] Prefer `Box` or `Stack` for layout; use `Grid` for 12‑column structures.
- [ ] Use `useTheme` or callback `sx` for dynamic styling.
- [ ] Add `aria` attributes and proper `role` when building dialogs or interactive elements.
- [ ] Test components at multiple viewport sizes.
- [ ] Keep style files separate for components with >100 lines of styling.
