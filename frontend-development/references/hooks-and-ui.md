@REF:hooks-and-ui
§STATE{
  server⇒TanStack_Query(`useSuspenseQuery`∈`<Suspense>`,cache_first);
  shared_client⇒Context+`useReducer`;
  isolated⇒custom_hook(`useToggle`,`useDebounce`)
}

§HOOKS{
  `useDebounce<T>(value:T,delay:number):T`:`useState(value)`+`useEffect`→`id=setTimeout(()=>setDebounced(value),delay);return()=>clearTimeout(id)` on `[value,delay]`;
  fallback_`useQuery<T>(key:string,fetcher:()=>Promise<T>,opts?:{onSuccess?:(d:T)=>void;onError?:(e:Error)=>void;enabled?:boolean})`→`{data:T|null,error:Error|null,loading:boolean,refetch}`(iff_¬lib_allowed;prefer_TanStack_Query):
  `fetcherRef=useRef(fetcher);optsRef=useRef(opts)` synced via `useEffect(()=>{fetcherRef.current=fetcher;optsRef.current=opts})`⇒`refetch=useCallback(async()=>{setLoading(true);setError(null);try{const r=await fetcherRef.current();setData(r);optsRef.current?.onSuccess?.(r)}catch(e){setError(e as Error);optsRef.current?.onError?.(e as Error)}finally{setLoading(false)}},[])`(¬refs⇒new_`refetch`_each_render⇒infinite_loop_on_inline_fn/opts);
  `enabled=opts?.enabled!==false`;`useEffect(()=>{if(enabled)refetch()},[key,enabled,refetch])`
}

§ERR{
  wrap_app;placement+recovery⇒[react-patterns.md](react-patterns.md#7-error-handling);
  `ErrorBoundary extends React.Component<{children:React.ReactNode},{hasError:boolean;error:Error|null}>`:
  `state={hasError:false,error:null}`;`static getDerivedStateFromError(e:Error)=>({hasError:true,error:e})`;`componentDidCatch(e:Error,info:React.ErrorInfo)=>console.error(e,info)`;
  fallback(`.error-fallback`):show_`this.state.error?.message`+reset`onClick={()=>this.setState({hasError:false,error:null})}`
}

§ANIM{
  Framer_Motion:`<AnimatePresence>{items.map(i=><motion.div key={i} initial={{opacity:0,y:20}} animate={{opacity:1,y:0}} exit={{opacity:0,y:-20}} transition={{duration:0.3}}>{i}</motion.div>)}</AnimatePresence>`;
  modal:overlay(`opacity`)∧panel(`opacity`,`scale:0.9→1`,`y:20→0`)∈single_`<AnimatePresence>`
}

§FORM{
  validate_on_submit;errors∈`Record<field,string>`(next_to_field);
  trim_before_empty_check;enforce_max_len;`try/catch`_submit∧show_err;
  complex⇒React_Hook_Form∨TanStack_Form+Zod([zod](../../typescript/references/zod.md))
}

§A11Y{
  keys:Arrow,Enter,Escape_on_interactive_widgets;
  dialog_focus:save_prev→focus_modal→restore_on_close;
  ARIA:`role="dialog"`,`aria-modal="true"`,`role="combobox"`
}
