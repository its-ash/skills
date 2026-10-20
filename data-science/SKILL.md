---
name: data-science
description: "Data science guide for end-to-end tasks: exploratory analysis, statistical testing, feature engineering, model building, evaluation, deployment, monitoring with Python, R, SQL, MLOps tools. Use when user asks for EDA, hypothesis testing, regression, Bayesian analysis, power analysis, feature engineering, model training, cross-validation, MLflow logging, FastAPI serving, data pipelines, CSV, Parquet, Excel, JSON scientific data, pingouin, scipy, statsmodels, pymc, pandas, numpy, scikit-learn."
---

# Data Science

Expert guide for the full data‑science workflow. Use it to design experiments, explore data, build statistical or machine‑learning models, and deploy them reliably.

## When to use
- You need a structured process for a data‑driven project.
- You must design, run, or analyze A/B tests or other experiments.
- You are building predictive, classification, clustering, or time‑series models.
- You need to production‑ize a model with monitoring and version control.
- You must communicate results to technical and non‑technical stakeholders.

---

## Workflow
1. **Define objective**
   - State the business question.
   - Identify success metrics (KPIs) and constraints.
2. **Acquire data**
   - Write reproducible SQL or API queries.
   - Store raw data in a data lake/warehouse.
3. **Profile & clean**
   - Check missing values, outliers, data types.
   - Apply consistent cleaning rules.
4. **Exploratory Data Analysis (EDA)**
   - Generate summary statistics.
   - Visualize distributions, correlations, and trends.
5. **Feature engineering**
   - Encode categoricals, scale numerics.
   - Create interaction terms, time‑based features, aggregates.
   - Store engineered features in a feature store.
6. **Model selection & training**
   - Choose algorithms appropriate for data size and problem type.
   - Use `sklearn.pipeline.Pipeline` to chain preprocessing and model.
   - Tune hyper‑parameters with cross‑validation (e.g., Optuna).
7. **Evaluation**
   - Select metrics aligned with business goals (e.g., ROC‑AUC, MAE, lift).
   - Perform statistical significance testing where needed.
   - Conduct error analysis and check for data leakage.
8. **Validation & robustness**
   - Run hold‑out or time‑based splits.
   - Perform sensitivity analysis and stress testing.
9. **Deployment**
   - Serialize model with MLflow or DVC.
   - Serve via FastAPI/Flask inside a Docker container.
   - Register model version and metadata.
10. **Monitoring & maintenance**
    - Track prediction latency, data drift, and performance metrics.
    - Set alerts for drift or degradation.
    - Schedule periodic retraining pipelines.

---

## Rules & Best Practices
- **Clarify goals** before touching data.
- **Use version control** for code, data schemas, and model artifacts.
- **Split data** using stratified or time‑aware methods to avoid leakage.
- **Document assumptions** and statistical tests.
- **Set random seeds** for reproducibility.
- **Log experiments** (parameters, metrics, artifacts) with MLflow or similar.
- **Validate models** on out‑of‑sample data before deployment.
- **Monitor continuously**; treat models as living services.
- **Communicate findings** with visualizations tailored to the audience.
- **Consider ethics**: check for bias, fairness, and privacy compliance.

---

## Common Patterns
### ETL / Data Pipeline
```python
from airflow import DAG
from airflow.operators.python import PythonOperator

def extract(**kwargs):
    # SQL extraction logic
    pass

def transform(**kwargs):
    # Cleaning, feature creation
    pass

def load(**kwargs):
    # Write to feature store / warehouse
    pass

with DAG('etl_pipeline', schedule_interval='@daily') as dag:
    PythonOperator(task_id='extract', python_callable=extract)
    PythonOperator(task_id='transform', python_callable=transform)
    PythonOperator(task_id='load', python_callable=load)
```

### Model Training Pipeline
```python
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import GradientBoostingClassifier

numeric_features = ['age', 'income']
cat_features = ['city', 'device']
preprocess = ColumnTransformer([
    ('num', StandardScaler(), numeric_features),
    ('cat', OneHotEncoder(handle_unknown='ignore'), cat_features)
])

model = GradientBoostingClassifier()
pipe = Pipeline([('preprocess', preprocess), ('model', model)])
pipe.fit(X_train, y_train)
```

### Model Logging with MLflow
```python
import mlflow
import mlflow.sklearn

with mlflow.start_run():
    mlflow.log_params(pipe.get_params())
    mlflow.sklearn.log_model(pipe, 'model')
    mlflow.log_metric('roc_auc', auc_score)
```

### FastAPI Serving Endpoint
```python
from fastapi import FastAPI
import joblib
import pandas as pd

app = FastAPI()
model = joblib.load('model.pkl')

@app.post('/predict')
def predict(data: dict):
    df = pd.DataFrame([data])
    pred = model.predict_proba(df)[:, 1]
    return {'risk_score': float(pred)}
```

---

## Pitfalls to Avoid
- **Data leakage**: using future information in training.
- **Over‑fitting**: neglecting validation or using too many features.
- **Ignoring class imbalance**: leads to misleading accuracy.
- **Misinterpreting p‑values**: treat statistical significance as business significance.
- **Hard‑coding paths or secrets**: break reproducibility and security.
- **Skipping monitoring**: model performance can decay silently.
- **Undocumented preprocessing**: hampers reproducibility and auditability.

---

## Checklist
- [ ] Business objective and KPI defined.
- [ ] Data source queries version‑controlled.
- [ ] Data quality checks (missing, outliers, type consistency).
- [ ] EDA visualizations completed and insights recorded.
- [ ] Feature engineering steps documented and stored.
- [ ] Model choice justified; baseline established.
- [ ] Hyper‑parameter tuning method selected.
- [ ] Evaluation metrics aligned with business goals.
- [ ] Experiment logged (parameters, metrics, artifacts).
- [ ] Model serialized and versioned.
- [ ] Deployment container built and tested.
- [ ] Monitoring dashboards and alerts configured.
- [ ] Documentation for stakeholders prepared.

---

## References (widely used)
- **Python packages**: pandas, numpy, scikit‑learn, scipy, statsmodels, matplotlib, seaborn, plotly, mlflow, optuna.
- **R packages**: dplyr, ggplot2, caret, tidymodels, shiny.
- **SQL**: window functions, CTEs, analytical functions.
- **Big data**: PySpark, Dask.
- **Orchestration**: Apache Airflow, Prefect.
- **Model serving**: FastAPI, Flask, Docker, Kubernetes.
- **Monitoring**: Prometheus, Grafana, Weights & Biases.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/exploratory-data-analysis.md](references/exploratory-data-analysis.md) | Performs automated exploratory data analysis (EDA) on scientific data files of any format. Detects the file type, extracts format‑specific metadata, runs appropriate quality and statistical checks, and creates a detailed markdown report with findings and next‑step recommendations. |
| [references/statistical-analysis.md](references/statistical-analysis.md) | Statistical‑analysis skill provides end‑to‑end guidance for hypothesis testing, regression, Bayesian methods, power analysis, assumption checking, and model building with Python libraries (pingouin, scipy, statsmodels, pymc). Use it for academic research, data‑driven reporting, or econometric modeling. |

## Related skills

Load these when the task spans more than this skill.

- [`data-engineering`](../data-engineering/SKILL.md) — Guides the design, implementation, and operation of scalable batch and streaming data pipelines, modern data w…
- [`scikit-learn`](../scikit-learn/SKILL.md) — Build, evaluate, and tune classical machine learning models with scikit-learn: classification, regression, clu…
- [`ml-engineering`](../ml-engineering/SKILL.md) — Guidance, best practices, and checklists for building production-grade machine-learning systems. Use for model…
- [`geopandas`](../geopandas/SKILL.md) — Use GeoPandas to read, transform, analyze, and map vector geospatial data in formats such as Shapefile, GeoJSO…
- [`networkx`](../networkx/SKILL.md) — Create, analyze, and visualize graphs in Python with NetworkX: graph types, algorithms, generators, file I/O,…
- [`pymoo`](../pymoo/SKILL.md) — Use pymoo to solve single- and multi-objective optimization problems, find Pareto fronts, handle constraints,…
- [`hypothesis-generation`](../hypothesis-generation/SKILL.md) — Generate testable scientific hypotheses through structured ideation and evidence synthesis. Combines conversat…
