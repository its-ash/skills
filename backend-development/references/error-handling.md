@REF:error-handling
§META{use:error_hierarchies∨retry/circuit_breaker∨API_errors∨user_msgs∨silent_swallow/cascade_debug}
§R{
  1:fail_fast_loud_at_boundary¬bury;
  2:typed_errors>raw_strings;
  3:user_msg≠dev_msg(friendly_UI_text∧full_ctx_logged_server_side¬stack_traces_to_client);
  4:¬silent_catch(∀catch⇒handle∨rethrow∨log);
  5:errors∈API_contract(doc_∀error_code);
  6:async⇒surface_to_caller¬unguarded_fire_and_forget
}
§TS{
  base:`AppError(message:string, readonly code:string, readonly statusCode:number=500, readonly details?:unknown) extends Error`→`this.name=this.constructor.name; Object.setPrototypeOf(this, new.target.prototype)`(req_for_ES5_`instanceof`);
  sub:{NotFoundError(res,id)⇒'NOT_FOUND':404; ValidationError(msg,details:{field:string;message:string}[])⇒'VALIDATION_ERROR':422; UnauthorizedError(reason='Authentication required')⇒'UNAUTHORIZED':401; RateLimitError(readonly retryAfterMs:number)⇒'RATE_LIMITED':429};
  result:`type Result<T,E=AppError>={ok:true;value:T}|{ok:false;error:E}`+`ok(v)/err(e)`(expected_failures:parse,ext_IO)
}
```typescript
function handleApiError(error: unknown): NextResponse {
  if (error instanceof AppError)
    return NextResponse.json({ error: { code: error.code, message: error.message, ...(error.details ? { details: error.details } : {}) } }, { status: error.statusCode })
  if (error instanceof z.ZodError)
    return NextResponse.json({ error: { code: 'VALIDATION_ERROR', message: 'Request validation failed', details: error.issues.map(i => ({ field: i.path.join('.'), message: i.message })) } }, { status: 422 })
  console.error('Unexpected error:', error)
  return NextResponse.json({ error: { code: 'INTERNAL_ERROR', message: 'An unexpected error occurred' } }, { status: 500 })
}

export class ErrorBoundary extends Component<{ fallback: ReactNode; onError?: (e: Error, info: ErrorInfo) => void; children: ReactNode }, { hasError: boolean; error: Error | null }> {
  state = { hasError: false, error: null }
  static getDerivedStateFromError(error: Error) { return { hasError: true, error } }
  componentDidCatch(error: Error, info: ErrorInfo) { this.props.onError?.(error, info); console.error('Unhandled React error:', error, info) }
  render() { return this.state.hasError ? this.props.fallback : this.props.children }
}
```
§PY{
  base:`AppError(Exception)(message:str, code:str, status_code:int=500)`;
  sub:{NotFoundError(res,id)⇒"NOT_FOUND":404; ValidationError(msg,details:list[dict]|None=None)⇒"VALIDATION_ERROR":422}
}
```python
@app.exception_handler(AppError)
async def app_error_handler(request: Request, exc: AppError) -> JSONResponse:
    return JSONResponse(status_code=exc.status_code, content={"error": {"code": exc.code, "message": str(exc)}})

@app.exception_handler(Exception)
async def generic_error_handler(request: Request, exc: Exception) -> JSONResponse:
    logger.exception("Unexpected error", exc_info=exc)
    return JSONResponse(status_code=500, content={"error": {"code": "INTERNAL_ERROR", "message": "An unexpected error occurred"}})
```
§GO{
  sentinels:`ErrNotFound`,`ErrUnauthorized`,`ErrConflict`(`errors.New`);
  wrap:`fmt.Errorf("ctx %s: %w", id, err)`(preserve_chain);
  handler:`errors.Is`:{ErrNotFound→404:"not_found":err.Error(); ErrUnauthorized→403:"forbidden":"Access denied"; default→slog.Error+500:"internal_error":"An unexpected error occurred"}
}
§RETRY{
  defaults:maxAttempts=3,baseDelayMs=500,maxDelayMs=10_000,retryIf=()=>true;
  backoff:`Math.min(baseDelayMs * 2 ** (attempt - 1) + Math.random() * baseDelayMs, maxDelayMs)`;
  guard:`retryIf: e => !(e instanceof AppError && e.statusCode < 500)`(¬retry_4xx)
}
§UI{
  map:NOT_FOUND|"The requested item could not be found.";UNAUTHORIZED|"Please sign in to continue.";FORBIDDEN|"You don't have permission to do that.";VALIDATION_ERROR|"Please check your input and try again.";RATE_LIMITED|"Too many requests. Please wait a moment and try again.";INTERNAL_ERROR|"Something went wrong on our end. Please try again later.";
  fn:`getUserMessage(code) = USER_ERROR_MESSAGES[code] ?? USER_ERROR_MESSAGES.INTERNAL_ERROR`
}
§CHK{
  envelope:`{error:{code,message}}`;
  ¬silent_catch∧full_server_log∧¬internal_details_in_UI∧AppError_base_with_code∧async_errors_surfaced∧retry_skips_4xx∧React_ErrorBoundary
}
