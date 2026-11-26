@REF:project-setup
§CMD:env{uv venv .venv && source .venv/bin/activate && uv pip install -r requirements.txt && uv lock}
§PAT:layout{script:main.py,utils.py,requirements.txt; med_api:app/{main.py,models/,schemas/,routes/,services/},tests/,pyproject.toml; lg_app:src/myapp/{core/,api/,services/,models/},tests/,pyproject.toml; roles:{models:ORM,schemas:Pydantic,routes:endpoints,services:logic}}
§CFG:pyproject.toml{[project]{name="myapp",version="0.1.0",requires-python=">=3.12"},[tool.ruff]{line-length=88,lint.select=["E","F","W","C90"]},[tool.mypy]{strict=true}}
§CFG:.pre-commit-config.yaml{repos:[{repo:https://github.com/astral-sh/ruff-pre-commit,rev:v0.4.0,hooks:[{id:ruff,args:[--fix]}]},{repo:https://github.com/pre-commit/mirrors-mypy,rev:v1.10.0,hooks:[{id:mypy}]}]}
§D:toolbox{pkg|venv|lock⇒uv;lint|fmt⇒ruff;types⇒mypy(strict)⊕pyright;http⇒httpx;async_pg|orm⇒asyncpg∧SQLAlchemy2.0_async;test⇒pytest,pytest-asyncio,hypothesis,pytest-cov,pytest-benchmark;profile⇒cProfile,py-spy,memory_profiler}
§CHK:ship{Py≥3.12∧uv lock;record(fw,async/sync);pyproject∋(ruff,mypy);hints∀public_fn;Pydantic(req,settings);DI(db,auth,cfg);AppError+handlers;tests(unit,async_int,crit)∧core_cov>90%;CI(ruff,mypy,pytest)∀push;multi-stage_Docker(runtime_only);¬secrets∧err¬leak_internals}
