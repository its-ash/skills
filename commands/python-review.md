---
description: "Python code review (PEP 8, type hints, security, idioms) via python-reviewer agent."
---
@CMD:python-review
agent:python-reviewer
skills:[`python/references/python-patterns.md`,`python/references/python-testing.md`]
§FLOW{
  1:identify modified `.py` files via `git diff`
  2:static_analysis:
    `uv run pyright` ∨ `uv run mypy --strict .`
    `uv run ruff check .`
    `uv run ruff format --check .`
  3:security_audit:
    `uv run ruff check --select S .`
    `semgrep --config auto .`
    `uv run pip-audit`
  4:tests:`uv run pytest --cov=app --cov-report=term-missing`
  5:review severity(§SEV)+framework(§FW)+Python3.13+(§PY)→report(§OUT)
}
§SEV{
  CRITICAL(Block):SQL/cmd_inj,unsafe `eval`/`exec`,unsafe `pickle`,hardcoded_creds,unsafe `yaml.load`,bare `except:`
  HIGH(Block):missing public fn type hints,mutable defaults(`=[]`→`None`),silent exception swallow,missing context mgr(`with`),C-style loop vs comprehension,`type()` vs `isinstance()`,lockless race conditions
  MEDIUM(Warn):PEP 8 format,missing public fn docstrings,`print()` vs `logging`,loop `str +=` vs `"".join()`,magic numbers,non-f-string formatting,unnecessary list creation
}
§FW{
  Django:N+1(`select_related`/`prefetch_related`),missing migrations,raw SQL vs ORM,missing `transaction.atomic()`
  FastAPI:CORS misconfig,Pydantic req validation,`response_model`,async/await usage,DI patterns
  Flask:app/request context mgmt,error handling,blueprint org,config mgmt
}
§PY{
  baseline:3.13+(3.15 current);verify `requires-python` in `pyproject.toml`
  flag_legacy:{`Optional[X]`/`Union[X,Y]`⇒`X|None`/`X|Y`,`List[X]`/`Dict[K,V]`⇒`list[X]`/`dict[K,V]`,`TypeVar`⇒PEP695 `def fn[T](x:T)->T`,structural `if/elif`⇒`match`}
}
§GATE{
  `PASS: Approve`⇔CRITICAL≡0∧HIGH≡0
  `WARNING: Warning`⇔CRITICAL≡0∧HIGH≡0∧MEDIUM>0
  `FAIL: Block`⇔CRITICAL>0∨HIGH>0
}
§OUT{
  `# Python Code Review Report`:Files Reviewed,Static Analysis Results,Issues([CRITICAL|HIGH|MEDIUM],`file:line`,issue,fix),Summary counts,Recommendation(PASS/WARNING/FAIL),Formatting cmd(`uv run ruff format ...`)
}
§REL{
  pre:`unit-testing-patterns/references/test-driven-development.md`
  other:`/code-review`(non-Python),`/python-review`(pre-commit),`/build-fix`(tool fail)
}
