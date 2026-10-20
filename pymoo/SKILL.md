---
name: pymoo
description: "pymoo solves single- and multi-objective optimization problems, computes Pareto fronts, handles constraints, customizes evolutionary algorithms, benchmarks ZDT/DTLZ/WFG, visualizes results, and supports decision making. Use when optimizing with pymoo, NSGA-II, NSGA-III, MOEA/D, genetic algorithms, evolutionary computation, Pareto-optimal solutions, constraint handling, benchmark problems, or selecting preferred trade-off solutions."
---

# Pymoo: Multi-Objective Optimization in Python

Pymoo is a Python framework for single- and multi-objective optimization. It provides algorithms, benchmark problems, genetic operators, constraint handling, visualization, and multi-criteria decision making tools. Use it to find Pareto-optimal trade-offs and analyze optimization results.

## When to use

- Solve single-objective optimization problems.
- Find Pareto fronts for 2-3 objectives.
- Optimize 4 or more objectives.
- Handle constrained, binary, discrete, continuous, or mixed-variable problems.
- Benchmark algorithms on standard problems such as ZDT, DTLZ, and WFG.
- Customize genetic operators.
- Visualize optimization results.
- Select preferred solutions from a Pareto front.

## Core concepts

### Unified interface

```python
from pymoo.optimize import minimize

result = minimize(
    problem,
    algorithm,
    termination,
    seed=1,
    verbose=True
)
```

Result fields:
- `result.X`: decision variables of optimal solution(s)
- `result.F`: objective values of optimal solution(s)
- `result.G`: constraint violations, if constrained
- `result.algorithm`: algorithm object with history

Problem types:
- Single-objective: one objective
- Multi-objective: 2-3 conflicting objectives
- Many-objective: 4 or more objectives
- Constrained: objectives plus inequality or equality constraints
- Dynamic: time-varying objectives or constraints

## Workflow 1: Single-objective optimization

Use a single-objective algorithm such as GA, DE, PSO, or CMA-ES.

```python
from pymoo.algorithms.soo.nonconvex.ga import GA
from pymoo.problems import get_problem
from pymoo.optimize import minimize

problem = get_problem("rastrigin", n_var=10)
algorithm = GA(pop_size=100, eliminate_duplicates=True)
result = minimize(problem, algorithm, ("n_gen", 200), seed=1, verbose=True)

print(result.X)
print(result.F[0])
```

## Workflow 2: Multi-objective optimization (2-3 objectives)

Use NSGA-II for standard bi- or tri-objective problems.

```python
from pymoo.algorithms.moo.nsga2 import NSGA2
from pymoo.problems import get_problem
from pymoo.optimize import minimize
from pymoo.visualization.scatter import Scatter

problem = get_problem("zdt1")
algorithm = NSGA2(pop_size=100)
result = minimize(problem, algorithm, ("n_gen", 200), seed=1)

plot = Scatter()
plot.add(result.F, label="Obtained Front")
plot.add(problem.pareto_front(), label="True Front", alpha=0.3)
plot.show()
```

## Workflow 3: Many-objective optimization (4+ objectives)

Use NSGA-III with reference directions.

```python
from pymoo.algorithms.moo.nsga3 import NSGA3
from pymoo.problems import get_problem
from pymoo.optimize import minimize
from pymoo.util.ref_dirs import get_reference_directions
from pymoo.visualization.pcp import PCP

problem = get_problem("dtlz2", n_obj=5)
ref_dirs = get_reference_directions("das-dennis", n_dim=5, n_partitions=12)
algorithm = NSGA3(ref_dirs=ref_dirs)
result = minimize(problem, algorithm, ("n_gen", 300), seed=1)

plot = PCP(labels=[f"f{i+1}" for i in range(5)])
plot.add(result.F, alpha=0.3)
plot.show()
```

## Workflow 4: Custom problem definition

Extend `ElementwiseProblem`. Define dimensions and bounds in `__init__`. Implement `_evaluate`.

Unconstrained example:

```python
from pymoo.core.problem import ElementwiseProblem
import numpy as np

class MyProblem(ElementwiseProblem):
    def __init__(self):
        super().__init__(
            n_var=2,
            n_obj=2,
            xl=np.array([0, 0]),
            xu=np.array([5, 5])
        )

    def _evaluate(self, x, out, *args, **kwargs):
        f1 = x[0]**2 + x[1]**2
        f2 = (x[0] - 1)**2 + (x[1] - 1)**2
        out["F"] = [f1, f2]
```

Constrained example:

```python
class ConstrainedProblem(ElementwiseProblem):
    def __init__(self):
        super().__init__(
            n_var=2,
            n_obj=2,
            n_ieq_constr=2,
            n_eq_constr=1,
            xl=np.array([0, 0]),
            xu=np.array([5, 5])
        )

    def _evaluate(self, x, out, *args, **kwargs):
        out["F"] = [f1, f2]
        out["G"] = [g1, g2]  # inequality constraints, feasible when <= 0
        out["H"] = [h1]       # equality constraints, feasible when = 0
```

Constraint rules:
- Inequality constraints use `g(x) <= 0`.
- Equality constraints use `h(x) = 0`.
- Convert `g(x) >= b` to `-(g(x) - b) <= 0`.

## Workflow 5: Constraint handling

Feasibility-first handling works automatically with constrained problems:

```python
from pymoo.algorithms.moo.nsga2 import NSGA2

algorithm = NSGA2(pop_size=100)
result = minimize(problem, algorithm, termination)
feasible = result.CV[:, 0] == 0
print(np.sum(feasible))
```

Other approaches:

```python
from pymoo.constraints.as_penalty import ConstraintsAsPenalty
from pymoo.constraints.as_obj import ConstraintsAsObjective

problem_penalized = ConstraintsAsPenalty(problem, penalty=1e6)
problem_with_cv = ConstraintsAsObjective(problem)
```

For heavily constrained problems, use specialized algorithms such as SRES or ISRES.

## Workflow 6: Decision making from a Pareto front

Normalize objectives, define weights, and apply a decision method.

```python
from pymoo.mcdm.pseudo_weights import PseudoWeights
import numpy as np

F_norm = (result.F - result.F.min(axis=0)) / (
    result.F.max(axis=0) - result.F.min(axis=0)
)
weights = np.array([0.3, 0.7])
dm = PseudoWeights(weights)
selected_idx = dm.do(F_norm)

best_solution = result.X[selected_idx]
best_objectives = result.F[selected_idx]
```

Other MCDM methods include Compromise Programming, Knee Point, and Hypervolume Contribution.

## Workflow 7: Visualization

Choose by number of objectives:

```python
from pymoo.visualization.scatter import Scatter

plot = Scatter(title="Bi-objective Results")
plot.add(result.F, color="blue", alpha=0.7)
plot.show()
```

For 3 objectives, `Scatter` renders in 3D. For 4 or more objectives, use parallel coordinates:

```python
from pymoo.visualization.pcp import PCP

plot = PCP(
    labels=[f"f{i+1}" for i in range(n_obj)],
    normalize_each_axis=True
)
plot.add(result.F, alpha=0.3)
plot.show()
```

For solution comparison, use a petal diagram:

```python
from pymoo.visualization.petal import Petal

plot = Petal(
    bounds=[result.F.min(axis=0), result.F.max(axis=0)],
    labels=["Cost", "Weight", "Efficiency"]
)
plot.add(solution_a, label="Design A")
plot.add(solution_b, label="Design B")
plot.show()
```

## Algorithm selection

Single-objective:
- GA: general-purpose, flexible operators
- DE: continuous optimization, good global search
- PSO: smooth landscapes, fast convergence
- CMA-ES: difficult or noisy problems, self-adapting

Multi-objective (2-3 objectives):
- NSGA-II: standard, fast, reliable
- R-NSGA-II: preference regions with reference points
- MOEA/D: decomposable problems, scalarization approach

Many-objective (4+ objectives):
- NSGA-III: 4-15 objectives, reference direction-based
- RVEA: adaptive search with reference vectors
- AGE-MOEA: complex landscapes, adaptive geometry

Constrained problems:
- Feasibility-first: any algorithm, large feasible region
- Specialized: SRES or ISRES, heavy constraints
- Penalty: GA with penalty, algorithm compatibility

## Benchmark problems

Access built-in problems with `get_problem`:

```python
from pymoo.problems import get_problem

problem = get_problem("rastrigin", n_var=10)
problem = get_problem("rosenbrock", n_var=10)
problem = get_problem("zdt1")
problem = get_problem("zdt2")
problem = get_problem("zdt3")
problem = get_problem("dtlz2", n_obj=5, n_var=12)
problem = get_problem("dtlz7", n_obj=4)
```

## Genetic operator customization

Configure operators by variable type.

Continuous variables:

```python
from pymoo.algorithms.soo.nonconvex.ga import GA
from pymoo.operators.crossover.sbx import SBX
from pymoo.operators.mutation.pm import PM

algorithm = GA(
    pop_size=100,
    crossover=SBX(prob=0.9, eta=15),
    mutation=PM(eta=20),
    eliminate_duplicates=True
)
```

Operator selection:
- Continuous: SBX crossover, PM mutation
- Binary: TwoPointCrossover or UniformCrossover, BitflipMutation
- Permutations: OrderCrossover, InversionMutation

## Performance and troubleshooting

Common issues:
- Not converging: increase population size or generations; check multimodality; verify constraints.
- Poor Pareto front distribution: adjust NSGA-III reference directions; increase population size; check duplicate elimination; verify scaling.
- Few feasible solutions: use constraint-as-objective; apply repair operators; try SRES or ISRES; verify `g <= 0` formulation.
- High computational cost: reduce population size or generations; use simpler operators; enable parallelization if supported.

Best practices:
- Normalize objectives when scales differ significantly.
- Set a random seed for reproducibility.
- Save history to analyze convergence: `save_history=True`.
- Visualize results to understand solution quality.
- Compare with the true Pareto front when available.
- Use appropriate termination criteria, such as `("n_gen", N)` or `get_termination("f_tol", tol=0.001)`.
- Tune operator parameters for problem characteristics.

## Installation

```bash
uv pip install pymoo
```

Dependencies include NumPy, SciPy, matplotlib, and optional autograd for gradient-based methods. Documentation: https://pymoo.org/. This skill targets pymoo 0.6.x.

## Related skills

Load these when the task spans more than this skill.

- [`data-science`](../data-science/SKILL.md) — Data science guide for end-to-end tasks: exploratory analysis, statistical testing, feature engineering, model…
- [`scikit-learn`](../scikit-learn/SKILL.md) — Build, evaluate, and tune classical machine learning models with scikit-learn: classification, regression, clu…
- [`python`](../python/SKILL.md) — Guidance for modern Python 3.12+ development. Includes framework selection, async vs sync decisions, project l…
- [`ml-engineering`](../ml-engineering/SKILL.md) — Guidance, best practices, and checklists for building production-grade machine-learning systems. Use for model…
- [`research-engineer`](../research-engineer/SKILL.md) — Research Engineer skill for rigorous, correctness-first engineering. Use when implementing algorithms, optimiz…
