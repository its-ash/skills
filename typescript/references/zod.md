# Zod Validation Guide

Use this guide to create type‑safe Zod schemas, parse and validate data, and integrate validation with React Hook Form, Next.js server actions, and environment variables.

## When to Use
- Define runtime validation for API inputs, form data, or query parameters.
- Validate and type‑infer environment variables.
- Connect Zod with React Hook Form via `@hookform/resolvers/zod`.
- Write complex rules such as cross‑field checks or async validation.
- Transform raw strings into numbers, booleans, or dates before validation.

## Core Workflow
1. **Import Zod**
   ```ts
   import { z } from "zod";
   ```
2. **Define a schema** using primitives, objects, arrays, unions, or discriminated unions.
3. **Infer the TypeScript type** with `z.infer<typeof Schema>`.
4. **Parse data** with `safeParse` (preferred) or `parse`.
5. **Handle the result** – on success use `result.data`; on failure extract errors with `result.error.format()` or `flatten()`.
6. **Integrate** the schema with the target framework (React Hook Form, Next.js, etc.).

## Schema Definition
### Primitives & Coercion
```ts
const nameSchema = z.string().min(3).max(255);
const ageSchema = z.coerce.number().min(18); // "21" → 21
const activeSchema = z.coerce.boolean();   // "true" → true
const dateSchema = z.coerce.date();        // "2023-01-01" → Date
```
### Objects & Type Inference
```ts
const UserSchema = z.object({
  id: z.string().uuid(),
  username: z.string().min(3).max(20),
  email: z.string().email(),
  role: z.enum(["ADMIN", "USER", "GUEST"]).default("USER"),
  age: z.number().min(18).optional(),
  website: z.string().url().nullable(),
  tags: z.array(z.string()).min(1),
});

export type User = z.infer<typeof UserSchema>;
```
### Advanced Types
- **Records** – dynamic keys with uniform value type.
  ```ts
  const envSchema = z.record(z.string(), z.string()); // Record<string, string>
  ```
- **Unions** – `z.union([z.string(), z.number()])` or `z.string().or(z.number())`.
- **Discriminated Unions** – safe switch statements.
  ```ts
  const ActionSchema = z.discriminatedUnion("type", [
    z.object({ type: z.literal("create"), id: z.string() }),
    z.object({ type: z.literal("update"), id: z.string(), data: z.any() }),
    z.object({ type: z.literal("delete"), id: z.string() }),
  ]);
  ```

## Parsing & Validation
### `parse` vs `safeParse`
```ts
const emailSchema = z.string().email();

// parse – throws on error
try {
  const email = emailSchema.parse("invalid");
} catch (e) {
  if (e instanceof z.ZodError) console.error(e.issues);
}

// safeParse – returns result object
const result = emailSchema.safeParse("user@example.com");
if (!result.success) {
  console.log(result.error.format()); // handle errors
} else {
  const validEmail = result.data; // type: string
}
```

## Custom Errors & Refinements
### Custom Error Messages
```ts
const passwordSchema = z.string()
  .min(8, { message: "At least 8 characters" })
  .regex(/[A-Z]/, { message: "Must contain an uppercase letter" })
  .regex(/[0-9]/, { message: "Must contain a number" });
```
### Global Error Map (i18n)
```ts
z.setErrorMap((issue, ctx) => {
  if (issue.code === z.ZodIssueCode.invalid_type && issue.expected === "string") {
    return { message: "This field must be text" };
  }
  return { message: ctx.defaultError };
});
```
### Refinements (Object‑level validation)
```ts
const RegisterSchema = z.object({
  password: z.string().min(8),
  confirmPassword: z.string(),
}).refine(data => data.password === data.confirmPassword, {
  message: "Passwords do not match",
  path: ["confirmPassword"], // attach error to field
});
```
### Transformations
```ts
const stringToNumber = z.string()
  .transform(v => parseInt(v, 10))
  .refine(v => !isNaN(v), { message: "Not a valid integer" });

type NumberResult = z.infer<typeof stringToNumber>; // number
```

## Integration Patterns
### React Hook Form
```tsx
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";

const loginSchema = z.object({
  email: z.string().email("Invalid email"),
  password: z.string().min(6, "Too short"),
});

type LoginValues = z.infer<typeof loginSchema>;

export function LoginForm() {
  const { register, handleSubmit, formState: { errors } } = useForm<LoginValues>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = (data: LoginValues) => {
    console.log(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register("email")} />
      {errors.email && <span>{errors.email.message}</span>}
      <input type="password" {...register("password")} />
      {errors.password && <span>{errors.password.message}</span>}
      <button type="submit">Login</button>
    </form>
  );
}
```
### Next.js Server Actions (or API Routes)
```ts
"use server";
import { z } from "zod";

const createPostSchema = z.object({
  title: z.string().min(3),
  content: z.string().optional(),
  published: z.coerce.boolean().default(false),
});

export async function createPost(prevState: any, formData: FormData) {
  const raw = Object.fromEntries(formData.entries());
  const result = createPostSchema.safeParse(raw);
  if (!result.success) {
    return { errors: result.error.flatten().fieldErrors };
  }
  const { title, content, published } = result.data;
  // ...save to DB
  return { success: true };
}
```
### Environment Variable Validation
```ts
import { z } from "zod";

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  PORT: z.coerce.number().default(3000),
  API_KEY: z.string().min(10),
});

export const env = envSchema.parse(process.env); // throws on missing/invalid vars
```

## Rules & Best Practices
- **Co‑locate schemas** with the component, API route, or server action that uses them.
- **Always infer types** with `z.infer` instead of writing duplicate interfaces.
- **Prefer `safeParse`**; it avoids try/catch and gives a typed result.
- **Use `z.coerce`** for data coming from `FormData`, `URLSearchParams`, or query strings.
- **Extract errors** with `.flatten()` or `.format()` for easy JSON serialization.
- **Provide a `path`** in `.refine` / `.superRefine` when validating objects so the error attaches to the correct field.
- **Do not rely on `.partial()`** for update schemas when field constraints differ; create a dedicated update schema.
- **Avoid deep recursion** without `z.lazy`; use `z.lazy(() => Schema)` for self‑referential structures.

## Common Pitfalls
| Symptom | Cause | Fix |
|---|---|---|
| `Type instantiation is excessively deep` | Recursive schema without `z.lazy` | Wrap recursive reference with `z.lazy(() => Schema)` |
| Empty string passes when field is optional | `.optional()` only allows `undefined` | Use `.or(z.literal(""))` or transform empty string to `undefined` before validation |
| Boolean coercion treats "false" as true | `z.coerce.boolean()` treats any non‑empty string as true | Preprocess with a custom transformer or use a manual check before coercion |

## Checklist
- [ ] Define schema with appropriate primitives and coercion.
- [ ] Add custom error messages where user feedback is needed.
- [ ] Use `.refine` / `.superRefine` for cross‑field or async rules.
- [ ] Call `safeParse` and handle `result.success`.
- [ ] Convert Zod errors to a serializable format for the UI.
- [ ] Export `z.infer` type and use it throughout the codebase.
- [ ] For Next.js actions, convert `FormData` with `Object.fromEntries` before parsing.
- [ ] Validate environment variables at startup with a dedicated schema.
- [ ] Write unit tests for each schema to guarantee expected validation behavior.

## Related skills

Load these when the task spans more than this skill.

- [`typescript`](../SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`nextjs`](../../frontend-development/references/nextjs.md) — Guidelines for building Next.js 14+ applications with the App Router. Includes component type decisions, data…
- [`node`](../../node/SKILL.md) — Node.js project conventions and setup rules. Load when creating, configuring, or working on any Node.js projec…
- [`frontend-development`](../../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
