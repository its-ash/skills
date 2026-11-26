@REF:javascript
§USE:explain_JS|debug_behavior|teach_fundamentals|check_best_practices

§TYPES{
  primitives(immutable,by_val):`String`,`Number`,`BigInt(9007199254740991n)`,`Boolean`,`undefined`,`null`,`Symbol("id")`;
  quirk:`typeof null === "object"`;
  coercion:`"5"+3==="53"`, `"5"-3===2`, `Boolean(0)===false`, `Boolean([])===true`;
  falsy:{`false`,`0`,`-0`,`0n`,`""`,`null`,`undefined`,`NaN`};
  eq:`"5"==5`→true, `"5"===5`→false, `null==undefined`→true, `null===undefined`→false, `Object.is(NaN,NaN)`→true, `Object.is(-0,0)`→false;
  rule:prefer_`===`_over_`==`
}

§SCOPE{
  `var`:fn_scope,hoisted(`undefined`),redeclarable,ignores_block;
  `let`:block_scope,hoisted_w/_TDZ(`ReferenceError`),¬redeclarable;
  `const`:block_scope,¬reassignable,obj_props_mutable(`const o={x:1}; o.x=2`);
  closure:inner_fn_retains_outer_vars(uses:privacy,factories,partial_app,memoize)
}

§EXEC{
  stack:LIFO;unbounded_recursion⇒`RangeError: Maximum call stack size exceeded`;
  hoist:fn_decl_hoists∧fn_expr(`var f=function(){}`)_¬hoists(`TypeError`);
  `this`:global(`window`|`global`) | method(`obj.fn()`) | arrow(lexical_outer_`this`) | explicit(`fn.call(ctx,a)`|`fn.apply(ctx,[a])`|`fn.bind(ctx)`)
}

§ASYNC{
  event_loop:1:sync→2:microtasks(`Promise`,`queueMicrotask`)→3:macrotasks(`setTimeout`,I/O)(`1,4,3,2`);
  callback:err_first`(err,res)=>{}`;avoid_deep_nest→Promises/`async`/`await`;
  promise:`new Promise((res,rej)=>...)`+`.then().catch().finally()`;
  combinators:`Promise.all`|`Promise.race`|`Promise.allSettled`|`Promise.any`;
  async_await:`try{const r=await fetch(u); if(!r.ok)throw new Error("..."); return await r.json()}catch(e){throw e}`;
  parallel:`await Promise.all([fetch(u1),fetch(u2)])`
}

§FP{
  HOF:fn_takes/returns_fn(`nums.map(n=>n*2)`,`a=>b=>a*b`);
  pure:deterministic∧¬side_effects;
  iter:`arr.map(fn)`|`arr.filter(pred)`|`arr.reduce(acc,init)`;
  ```js
  const curry = fn => function curried(...a) { return a.length >= fn.length ? fn(...a) : (...m) => curried(...a, ...m); };
  const compose = (...fns) => x => fns.reduceRight((v, f) => f(v), x);
  const pipe = (...fns) => x => fns.reduce((v, f) => f(v), x);
  ```
}

§OBJ{
  proto:`Object.create(proto)`(ES6_`class`≡proto_sugar);
  utils:`Object.keys(o)`|`Object.values(o)`|`Object.entries(o)`|`{...o}`(shallow)|`Object.freeze(o)`(immutable)|`Object.seal(o)`(¬add/del)
}

§ES6{
  destructure:`const [a,b,...rest]=arr`; `const {name,age,city="?"}=obj`; `const {name:userName}=obj`;
  spread_rest:`[...a1,3]`, `{...o1,y:2}`, `function sum(...nums){return nums.reduce((s,n)=>s+n,0)}`;
  esm:`export const/function`, `export default class`, `import Def,{a,b} from "./m.js"`, `import * as m from "./m.js"`, `await import("./lazy.js")`;
  safe_access:`user?.addr?.city`, `user?.getName?.()`(→`undefined`), `null ?? "default"`(→`"default"`), `0 ?? "default"`(→`0`,nullish_only)
}

§CHK{
  `===`>loose_eq;
  `let`/`const`>`var`;
  decl_fn_before_use;
  arrow≡lexical_`this`;
  microtask<macrotask;
  prefer_pure_fn;
  destructure+spread;
  `?.`∧`??`;
  `Object.freeze`(immutable)∨`Object.seal`(fixed_keys);
  `async`/`await`+`Promise`combinators
}

§REL{
  [typescript](../SKILL.md):TS_setup_migration_monorepo;
  [node](../../node/SKILL.md):Node_conventions_setup;
  [nextjs](../../frontend-development/references/nextjs.md):Next14+_AppRouter;
  [frontend-development](../../frontend-development/SKILL.md):React_Next_MUI_TanStack;
  [browser-extensions](../../browser-extensions/SKILL.md):MV3_Chrome_Edge_Firefox
}
