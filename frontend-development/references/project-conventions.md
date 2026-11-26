@REF:project-conventions
§CMD{setup:`npm install && cp .env.example .env`;qa:`npm run dev | npm run lint | npm run test`;bundle:`npm run build && npx next-bundle-analyzer`;docker:`docker build -t my-app . && docker compose up -d`}
§ALIAS{`@/`:`src/`,`~types`:`src/types`,`~components`:`src/components`,`~features`:`src/features`}
§LAYOUT{`src/{components/(SuspenseLoader,AppBar),features/<name>/{api/<name>Api.ts,components/,hooks/,helpers/,types/,index.ts},routes/(TanStackRouter),lib/(apiClient)}`}
§CHK_FEAT{feature_layout;typed_api;types+hooks_exported;`routes/<name>/index.tsx`(lazy);styles_rule;memo+lazy+¬rerenders;keyboard+focus;`*.test.tsx`+lint}
§COMP{
  `interface Props`+`React.FC<Props>`;heavy⇒`React.lazy(()=>import('./Heavy'))` in `<Suspense fallback={<SuspenseLoader/>}>`;
  data:`useSuspenseQuery`(¬`isLoading`,¬early_spinners⇒no_CLS);handlers:`useCallback`;`export default`@bottom;toasts/errors:`useMuiSnackbar`;
  ex:`export const MyComponent:React.FC<{id:number;onAction?:()=>void}>=({id,onAction})=>{const{data}=useSuspenseQuery({queryKey:['feature',id],queryFn:()=>featureApi.getFeature(id)});const handleAction=useCallback(()=>onAction?.(),[onAction]);return <Box sx={{p:2}}><Paper sx={{p:3}}>...</Paper></Box>};export default MyComponent;`
}
§ROUTE{`src/routes/my-feature/index.tsx`:`const FeaturePage=lazy(()=>import('~features/my-feature/components/FeaturePage'));export const Route=createFileRoute('/my-feature/')({component:FeaturePage,loader:()=>({crumb:'My Feature'})})`}
§STYLE{MUI_v7:`sx`:`Record<string,SxProps<Theme>>`;inline<100L else `<Component>.styles.ts`;Grid_v7:`<Grid size={{xs:12,md:6}}/>`;full→mui.md}
