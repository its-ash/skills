---
name: javascript
description: "Reference for JavaScript primitives, type coercion, equality, scope types, var let const hoisting, closures, call stack, this binding, event loop phases, promise async await, prototype inheritance, and ES6+ features like arrow functions destructuring modules. Use when debugging typeof NaN null undefined coercion, fixing closure loop capture, resolving this loss in callbacks, tracing microtask macrotask order, converting callbacks to promises, refactoring prototypes to classes, writing arrow destructuring syntax, setting babel targets, or explaining scope chain shadowing."
---

# JavaScript Reference

A short guide that lists the most important JavaScript concepts. Use it to explain code, debug unexpected behavior, or teach fundamentals.

## When to Use
- Explaining a language feature
- Debugging confusing JavaScript behavior
- Teaching beginners or reviewers
- Checking best‑practice rules

---

## 1. Fundamentals
### 1.1 Primitive Types
```javascript
// String
const str = "hello";
// Number (int or float)
const num = 42;
const pi = 3.14;
// BigInt for large integers
const big = 9007199254740991n;
// Boolean
const ok = true;
// Undefined
let undef; // undefined
// Null
const empty = null;
// Symbol – unique identifier
const sym = Symbol("id");
```
- Primitives are immutable and passed by value.
- `typeof null === "object"` is a historic bug.

### 1.2 Type Coercion
```javascript
"5" + 3   // "53"  (number → string)
"5" - 3   // 2     (string → number)
Boolean(0) // false
Boolean([]) // true
"5" == 5  // true  (coerces)
"5" === 5 // false (strict)
```
**Falsy values**: `false`, `0`, `-0`, `0n`, `""`, `null`, `undefined`, `NaN`.

### 1.3 Equality
```javascript
null == undefined   // true (loose)
null === undefined  // false (strict)
Object.is(NaN, NaN) // true
Object.is(-0, 0)    // false
```
**Rule**: Use `===` unless you need loose comparison.

---

## 2. Scope & Closures
### 2.1 Scope Types
```javascript
var global = "g"; // global
function outer() {
  var fn = "f"; // function scope
  if (true) {
    let block = "b"; // block scope
    const also = "c"; // block scope
    var hoist = "h"; // var ignores block
  }
}
```
### 2.2 var / let / const
- `var` – function scoped, hoisted, can redeclare.
- `let` – block scoped, hoisted with temporal dead zone, cannot redeclare.
- `const` – block scoped, cannot reassign, but objects are mutable.
```javascript
let a = 1; // ok
// let a = 2; // error
const obj = {x:1};
obj.x = 2; // ok
```
### 2.3 Closures
```javascript
function counter() {
  let count = 0;
  return {
    inc() { return ++count; },
    dec() { return --count; },
    value() { return count; }
  };
}
const c = counter();
c.inc(); // 1
c.inc(); // 2
c.value(); // 2
```
Use closures for data privacy, factories, partial application, and memoization.

---

## 3. Functions & Execution
### 3.1 Call Stack
```javascript
function a(){ console.log("a start"); b(); console.log("a end"); }
function b(){ console.log("b"); }
a();
// Output: a start, b, a end
```
A recursive call without a base case throws `RangeError: Maximum call stack size exceeded`.

### 3.2 Hoisting
```javascript
console.log(v); // undefined (var hoisted)
var v = 5;
console.log(l); // ReferenceError (let TDZ)
let l = 5;
// Function declaration hoists
sayHi();
function sayHi(){ console.log("Hi"); }
// Function expression does not hoist
// greet(); // TypeError
var greet = function(){ console.log("Hey"); };
```
### 3.3 this Binding
```javascript
// Global context
console.log(this); // window (browser) or global (Node)
// Method call
const obj = {name:"A", greet(){ console.log(this.name); }};
obj.greet(); // A
// Arrow function – lexical this
const arrow = () => console.log(this);
arrow(); // inherits outer this
// Explicit binding
function show(){ console.log(this.id); }
show.call({id:1}); // 1
show.apply({id:2}); // 2
const bound = show.bind({id:3});
bound(); // 3
```

---

## 4. Event Loop & Asynchronous Code
### 4.1 Execution Order
```javascript
console.log("1");
setTimeout(()=> console.log("2"), 0);
Promise.resolve().then(()=> console.log("3"));
console.log("4");
// Output: 1, 4, 3, 2
```
1. Run synchronous code.
2. Process microtasks (Promises, `queueMicrotask`).
3. Process macrotasks (setTimeout, I/O).

### 4.2 Callbacks
```javascript
function fetchData(cb){
  setTimeout(()=> cb(null, {data:"ok"}), 1000);
}
fetchData((err, result)=>{
  if (err) { console.error(err); return; }
  console.log(result);
});
```
Avoid deep nesting; prefer Promises or async/await.

### 4.3 Promises
```javascript
const p = new Promise((resolve, reject)=>{
  setTimeout(()=> resolve("Done"), 1000);
});
p.then(r=> console.log(r))
 .catch(e=> console.error(e))
 .finally(()=> console.log("finished"));
// Combinators
Promise.all([p1, p2]);
Promise.race([p1, p2]);
Promise.allSettled([p1, p2]);
Promise.any([p1, p2]);
```
### 4.4 async / await
```javascript
async function getUser(id){
  try {
    const res = await fetch(`/api/users/${id}`);
    if (!res.ok) throw new Error("Bad response");
    return await res.json();
  } catch (e){
    console.error(e);
    throw e; // propagate
  }
}
// Parallel requests
async function loadAll(){
  const [users, posts] = await Promise.all([
    fetch('/api/users'),
    fetch('/api/posts')
  ]);
  return {users, posts};
}
```

---

## 5. Functional Programming
### 5.1 Higher‑Order Functions
```javascript
const nums = [1,2,3];
const doubled = nums.map(n=> n*2); // [2,4,6]
function multiply(a){
  return b => a*b;
}
const double = multiply(2);
double(5); // 10
```
### 5.2 Pure Functions
```javascript
function add(a,b){ return a+b; } // pure
let total = 0;
function addToTotal(v){ total += v; return total; } // impure
```
### 5.3 map / filter / reduce
```javascript
const users = [{name:"A",age:25},{name:"B",age:30}];
const names = users.map(u=> u.name);
const adults = users.filter(u=> u.age>=30);
const sumAge = users.reduce((s,u)=> s+u.age, 0);
```
### 5.4 Currying & Composition
```javascript
const curry = fn => {
  return function curried(...args){
    return args.length >= fn.length ? fn(...args)
      : (...more)=> curried(...args, ...more);
  };
};
const add3 = curry((a,b,c)=> a+b+c);
add3(1)(2)(3); // 6

const compose = (...fns)=> x=> fns.reduceRight((v,f)=> f(v), x);
const pipe = (...fns)=> x=> fns.reduce((v,f)=> f(v), x);
const inc = n=> n+1;
const dbl = n=> n*2;
const incThenDbl = compose(dbl, inc);
incThenDbl(5); // 12
```

---

## 6. Objects & Prototypes
### 6.1 Prototypal Inheritance
```javascript
const animal = { speak(){ console.log("sound"); } };
const dog = Object.create(animal);
dog.bark = ()=> console.log("woof");
 dog.speak(); // inherited
 dog.bark();  // own
```
ES6 class syntax is syntactic sugar over the same prototype chain.
### 6.2 Object Utilities
```javascript
const o = {a:1,b:2};
Object.keys(o);   // ["a","b"]
Object.values(o); // [1,2]
Object.entries(o);// [["a",1],["b",2]]
const shallow = {...o}; // copy
const frozen = Object.freeze({x:1}); // immutable
const sealed = Object.seal({y:2}); // no add/delete
```

---

## 7. Modern JavaScript (ES6+)
### 7.1 Destructuring
```javascript
// Array
const [first, second, ...rest] = [1,2,3,4];
// Object
const {name, age, city="?"} = {name:"A",age:30};
// Rename
const {name: userName} = {name:"B"};
```
### 7.2 Spread & Rest
```javascript
const a1 = [1,2];
const a2 = [...a1,3]; // [1,2,3]
const o1 = {x:1};
const o2 = {...o1, y:2}; // {x:1,y:2}
function sum(...nums){ return nums.reduce((s,n)=>s+n,0); }
```
### 7.3 Modules
```javascript
// Export
export const PI = 3.14;
export function sq(x){ return x*x; }
export default class Calc{}
// Import
import Calc, {PI, sq} from "./math.js";
import * as math from "./math.js";
// Dynamic import
const mod = await import("./lazy.js");
```
### 7.4 Optional Chaining & Nullish Coalescing
```javascript
const user = {addr:{city:"NY"}};
const city = user?.addr?.city; // "NY"
const zip = user?.addr?.zip;   // undefined, no error
const name = user?.getName?.(); // undefined if missing

const val = null ?? "default"; // "default"
const zero = 0 ?? "default";    // 0 (nullish only)
```

---

## Checklist
- Use `===` for equality checks.
- Prefer `let`/`const` over `var`.
- Declare functions before use if you rely on hoisting.
- Remember that arrow functions capture lexical `this`.
- Microtasks (Promises) run before macrotasks (setTimeout).
- Write pure functions when possible.
- Use destructuring and spread for concise data handling.
- Apply optional chaining to avoid `TypeError` on missing properties.
- Freeze objects that must not change; seal when you only need to prevent addition/removal.
- Choose `async/await` for readable asynchronous flow; fall back to Promises for combinators.

## Related skills

Load these when the task spans more than this skill.

- [`typescript`](../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`node`](../node/SKILL.md) — Node.js project conventions and setup rules. Load when creating, configuring, or working on any Node.js projec…
- [`react-state-management`](../react-state-management/SKILL.md) — A concise guide for choosing and implementing React state management solutions—Redux Toolkit, Zustand, Jotai,…
- [`nextjs`](../nextjs/SKILL.md) — Guidelines for building Next.js 14+ applications with the App Router. Includes component type decisions, data…
- [`frontend-development`](../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`electron`](../electron/SKILL.md) — Master Electron desktop app development with secure IPC, contextIsolation, preload scripts, multi-process arch…
- [`browser-extensions`](../browser-extensions/SKILL.md) — Provides step‑by‑step guidance for building, testing, and publishing Chrome, Edge, and Firefox WebExtensions u…
