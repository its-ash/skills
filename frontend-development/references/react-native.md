@REF:react-native
§SCOPE{
  Expo(ExpoRouter,EAS,`expo-*`)∧NewArch(default_recent,mandatory_SDK55+);
  NO_DOM:¬`<div>`,¬URL_bar,¬web_URL-as-state/browser_SWR;
  libs_illustrative:(NativeWind,Zustand/Jotai,TanStackQuery,Zod)⇒equivalents_ok;
  when:RN/Expo_screens|ExpoRouter(`app/`)|state_split|TanStackQuery+Zod|long_lists|NativeWind/StyleSheet|native_APIs/SecureStore|RN_review
}
§LAYOUT{`app/{_layout.tsx,(tabs)/{_layout.tsx,index.tsx},user/[id].tsx}`,`components/`,`features/user/UserProfile.tsx`;thin_routes(read+validate_params→delegate)}
§NAV{
  deep_links/dynamic_params=untrusted⇒Zod_parse pre-use:
  `const Params=z.object({id:z.string().uuid()});` `const p=Params.safeParse(useLocalSearchParams()); if(!p.success){router.replace('/not-found');return null;}`
}
§STATE{
  ¬dup_server_data in client_store;local `useState` until shared;
  map:{server:TanStackQuery|SWR,client_UI:Zustand|Jotai|Context,route:ExpoRouter_params,form:ReactHookForm+schema,secrets/tokens:`expo-secure-store`(Keychain/Keystore),non_secret:`AsyncStorage`|MMKV}
}
§FETCH{
  server_cache+Zod(`z.infer<typeof User>`),¬fetch-in-`useEffect`;explicit loading|error(`accessibilityRole="alert"`)|empty;mutations→`qc.invalidateQueries({queryKey})`;
```tsx
const User=z.object({id:z.string(),email:z.string().email()});type User=z.infer<typeof User>;
export const useUser=(id:string)=>useQuery({queryKey:['user',id],queryFn:async():Promise<User>=>User.parse(await api.getUser(id))});
export function useUpdateEmail(id:string){const qc=useQueryClient();return useMutation({mutationFn:(e:string)=>api.updateEmail(id,e),onSuccess:()=>qc.invalidateQueries({queryKey:['user',id]})});}
```
}
§LIST{`FlatList`(`keyExtractor`,memoized `renderItem` via `memo`+`useCallback`,`initialNumToRender={10}`,`windowSize={5}`,`onRefresh`/`refreshing`);large/hetero⇒`FlashList`(Shopify);NEVER `.map()` large_array in `<ScrollView>`}
§STYLE{pick_ONE:`StyleSheet.create()`@module_scope ∨ NativeWind(`className`);¬inline_style_objects in JSX hot_paths}
§NATIVE{
  ExpoSDK/subs⇒`use*` hooks(¬JSX)+cleanup(`active=false`)+status_union(`'loading'|'denied'|'granted'`):
```tsx
type LocState={status:'loading'}|{status:'denied'}|{status:'granted';coords:Location.LocationObjectCoords};
export function useCurrentLocation(){
  const[s,setS]=useState<LocState>({status:'loading'});
  useEffect(()=>{let active=true;(async()=>{
    const{status}=await Location.requestForegroundPermissionsAsync();
    if(status!=='granted'){if(active)setS({status:'denied'});return;}
    const pos=await Location.getCurrentPositionAsync({});if(active)setS({status:'granted',coords:pos.coords});
  })();return()=>{active=false;};},[]);
  return s;
}
```
  tokens:`await SecureStore.setItemAsync('auth_token',token)` / `getItemAsync('auth_token')`
}
§FORM{ReactHookForm `Controller`+`zodResolver(Schema)`:`<TextInput value={value} onChangeText={onChange} onBlur={onBlur} autoCapitalize="none" keyboardType="email-address" accessibilityLabel="Email address"/>`+`errors.email && <Text accessibilityRole="alert">{errors.email.message}</Text>`+`handleSubmit(onSubmit)`}
§ANTI{`<ScrollView>{items.map(...)}</ScrollView>`⇒`FlatList`|`FlashList`;server_data→client_store⇒`useQuery`;tokens in `AsyncStorage`⇒`expo-secure-store`;unvalidated `useLocalSearchParams()`⇒Zod_parse;inline_style_hot_path⇒`StyleSheet.create`|NativeWind;secret(`sk_live_...`) in bundle⇒server-side+public_keys_only}
§R{thin_routes;Zod_validate ∀external_input(API,route_params,push_payloads);TanStackQuery_owns_server_state;loading/error/empty_states(¬bare_spinner);virtualize+memo_renderItem+stable_keyExtractor;`react-native-reanimated`(UI_thread,¬heavy_JS);`expo-secure-store`_tokens(¬client_authz);safe_areas+DynamicType+a11y_roles/labels;verify_NewArch_compat ∀native_dep pre-release}
§REL{react-patterns.md:shared_React(web_DOM_excluded);../../design/references/mobile-design.md:mobile_UI_touch;../../typescript/SKILL.md:TypeScript;../../unit-testing-patterns/SKILL.md:Jest+RNTL+Maestro/Detox_E2E;../../secure-coding/SKILL.md:bundle_secret_security}
