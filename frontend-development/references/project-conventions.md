@REF:project-conventions
§CMD{setup:`npm install && cp .env.example .env`;qa:`npm run dev | npm run lint | npm run test`;bundle:`ANALYZE=true npm run build`(Next)∨`rollup-plugin-visualizer`(Vite);docker:`docker build -t my-app . && docker compose up -d`}
§ALIAS{`@/`:`src/`,`~types`:`src/types`,`~components`:`src/components`,`~features`:`src/features`}
§LAYOUT{`src/{components/(SuspenseLoader,AppBar),features/<name>/{api/<name>Api.ts,components/,hooks/,helpers/,types/,index.ts},routes/(TanStackRouter),lib/(apiClient)}`}
§CHK_FEAT{feature_layout;typed_api;types+hooks_exported;`routes/<name>/index.tsx`(lazy);styles_rule;ReactCompiler_1.0+lazy+¬rerenders;keyboard+focus;`*.test.tsx`+lint}
§COMP{
  `interface Props`+typed_fn_params(prefer_over_`React.FC`→clean_React19_ref_prop);heavy⇒`React.lazy(()=>import('./Heavy'))` in `<Suspense fallback={<SuspenseLoader/>}>`;
  data:`useSuspenseQuery`(¬`isLoading`,¬early_spinners⇒no_CLS);handlers:plain_fn_with_ReactCompiler(`useCallback`_ONLY_if_compiler_off);`export default`@bottom;toasts/errors:`useMuiSnackbar`;
  ex:`interface MyComponentProps{id:number;onAction?:()=>void}export function MyComponent({id,onAction}:MyComponentProps){const{data}=useSuspenseQuery({queryKey:['feature',id],queryFn:()=>featureApi.getFeature(id)});const handleAction=()=>onAction?.();return <Box sx={{p:2}}><Paper sx={{p:3}}>...</Paper></Box>}export default MyComponent;`
}
§ROUTE{`src/routes/my-feature/index.tsx`:`const FeaturePage=lazy(()=>import('~features/my-feature/components/FeaturePage'));export const Route=createFileRoute('/my-feature/')({component:FeaturePage,loader:()=>({crumb:'My Feature'})})`}
§STYLE{MUI_v9(v7+):`sx`:`Record<string,SxProps<Theme>>`(¬direct_system_props_on_`Box`/`Grid`);inline<100L else `<Component>.styles.ts`;Grid:`<Grid size={{xs:12,md:6}}/>`(vertical⇒`<Stack>`);full→mui.md}
