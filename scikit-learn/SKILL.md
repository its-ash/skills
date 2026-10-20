---
name: scikit-learn
description: "Build, evaluate, and tune classical machine learning models with scikit-learn across classification, regression, clustering, dimensionality reduction, preprocessing, pipelines, cross-validation, and hyperparameter search. Use when working with sklearn, scikit learn, estimators, transformers, fit, predict, score, train_test_split, GridSearchCV, RandomizedSearchCV, cross_val_score, StandardScaler, PCA, KMeans, RandomForest, SVM, logistic regression, .ipynb notebooks, CSV datasets, model evaluation, feature engineering, or ML workflows in Python."
---

# Scikit-learn

Scikit-learn provides classical machine learning tools for Python. Use it for tabular and text workflows that need interpretable models, preprocessing, pipelines, evaluation, and tuning.

## When to use

- Build classification or regression models.
- Cluster data or reduce dimensions.
- Preprocess numeric, categorical, missing, or text features.
- Evaluate models with cross-validation.
- Tune hyperparameters with grid or randomized search.
- Build reproducible training and prediction pipelines.

## Quick start

Classification:

```python
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, stratify=y, random_state=42
)
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train_scaled, y_train)
print(classification_report(y_test, model.predict(X_test_scaled)))
```

Mixed-data pipeline:

```python
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import SimpleImputer
from sklearn.ensemble import GradientBoostingClassifier

numeric_features = ["age", "income"]
categorical_features = ["gender", "occupation"]

numeric_transformer = Pipeline([
    ("imputer", SimpleImputer(strategy="median")),
    ("scaler", StandardScaler()),
])
categorical_transformer = Pipeline([
    ("imputer", SimpleImputer(strategy="most_frequent")),
    ("onehot", OneHotEncoder(handle_unknown="ignore")),
])

preprocessor = ColumnTransformer([
    ("num", numeric_transformer, numeric_features),
    ("cat", categorical_transformer, categorical_features),
])

model = Pipeline([
    ("preprocessor", preprocessor),
    ("classifier", GradientBoostingClassifier(random_state=42)),
])
model.fit(X_train, y_train)
y_pred = model.predict(X_test)
```

## Core workflow

1. Load features `X` and target `y`.
2. Split with `train_test_split`; use `stratify=y` for classification.
3. Put preprocessing and model in one `Pipeline`.
4. Tune with `GridSearchCV` or `RandomizedSearchCV`.
5. Evaluate on held-out test data with task-appropriate metrics.
6. Set `random_state` where supported.

## Supervised learning

Classification predicts categories; regression predicts continuous values.

Algorithms:

- Linear: `LogisticRegression`, `LinearRegression`, `Ridge`, `Lasso`, `ElasticNet`
- Trees and ensembles: `DecisionTreeClassifier/Regressor`, `RandomForestClassifier/Regressor`, `GradientBoostingClassifier/Regressor`, `AdaBoostClassifier/Regressor`, `VotingClassifier`, `StackingClassifier`
- SVM: `SVC`, `SVR`, `LinearSVC`, `LinearSVR`
- Neighbors: `KNeighborsClassifier`, `KNeighborsRegressor`
- Naive Bayes: `GaussianNB`, `MultinomialNB`, `BernoulliNB`
- Neural networks: `MLPClassifier`, `MLPRegressor`

Selection guidance:

- Start with `RandomForest` or `GradientBoosting` for tabular baselines.
- Use linear models for interpretability and high-dimensional sparse data.
- Use SVM for small to medium datasets with clear margins.
- Use KNN for simple local patterns; scale features first.

## Unsupervised learning

Clustering:

- `KMeans`, `MiniBatchKMeans`
- `DBSCAN`, `HDBSCAN`, `OPTICS`
- `AgglomerativeClustering`
- `GaussianMixture`
- `MeanShift`, `SpectralClustering`, `BIRCH`

Dimensionality reduction:

- Linear: `PCA`, `TruncatedSVD`, `NMF`
- Manifold: `TSNE`, `Isomap`, `LocallyLinearEmbedding`
- Other: `FastICA`, `LatentDirichletAllocation`

Use clustering for segmentation, anomaly detection, and grouping. Use dimensionality reduction for visualization, compression, and feature extraction. Scale data before distance-based methods.

## Preprocessing

Scaling:

- `StandardScaler`: zero mean and unit variance.
- `MinMaxScaler`: bounded range.
- `RobustScaler`: robust to outliers.
- `Normalizer`: normalize each sample.

Encoding:

- `OneHotEncoder`: nominal categories.
- `OrdinalEncoder`: ordered categories.
- `LabelEncoder`: target labels only.

Imputation:

- `SimpleImputer`: mean, median, or most frequent.
- `KNNImputer`: nearest-neighbor imputation.
- `IterativeImputer`: multivariate imputation.

Feature engineering:

- `PolynomialFeatures`: interactions and powers.
- `KBinsDiscretizer`: binning.
- Selection: `RFE`, `SelectKBest`, `SelectFromModel`.

Scaling rules:

- Scale for SVM, KNN, neural networks, PCA, regularized linear models, and K-Means.
- Tree models and Naive Bayes do not require scaling.

Fit rules:

- Fit preprocessors on training data only.
- Use `fit_transform` on train and `transform` on test.
- Put preprocessing in the pipeline to avoid leakage.

## Pipelines and composition

- `Pipeline`: chain transformers and final estimator.
- `ColumnTransformer`: different preprocessing per column group.
- `FeatureUnion`: combine transformers in parallel.
- `TransformedTargetRegressor`: transform the target variable.

Benefits: prevents leakage, simplifies code, supports joint tuning, and keeps train/predict consistent.

Use pipelines for every production workflow, especially with mixed feature types or cross-validation.

## Evaluation and tuning

Cross-validation:

- `KFold`
- `StratifiedKFold` for classification
- `TimeSeriesSplit` for temporal data
- `GroupKFold` for grouped samples

Tuning:

- `GridSearchCV`: exhaustive search.
- `RandomizedSearchCV`: random sampling.
- `HalvingGridSearchCV`: successive halving.

Metrics:

- Classification: accuracy, precision, recall, F1, ROC AUC, confusion matrix, balanced accuracy.
- Regression: MSE, RMSE, MAE, R², MAPE.
- Clustering: silhouette score, Calinski-Harabasz, Davies-Bouldin.

Choose metrics by data balance and cost. Use cross-validation for model comparison, not only train/test scores.

## Best practices

- Always use pipelines for preprocessing plus modeling.
- Fit on training data only.
- Stratify classification splits.
- Set `random_state` for reproducibility.
- Scale features when the algorithm requires it.
- Use regularization or simpler models to reduce overfitting.
- Compare models with cross-validation.
- Use appropriate metrics for imbalanced data.

## Troubleshooting

ConvergenceWarning:

- Increase `max_iter`.
- Scale features.

Poor test performance:

- Check overfitting.
- Add regularization.
- Use cross-validation.
- Try a simpler model.

Memory errors on large datasets:

- Use `SGDClassifier` or `SGDRegressor`.
- Use `MiniBatchKMeans` for clustering.

## Checklist

- [ ] Split data before fitting preprocessors.
- [ ] Put preprocessing in a pipeline.
- [ ] Stratify classification splits.
- [ ] Scale features for distance/gradient models.
- [ ] Tune with cross-validation.
- [ ] Evaluate with task-appropriate metrics.
- [ ] Set random seeds.
- [ ] Inspect feature importance or coefficients when useful.

## Related skills

Load these when the task spans more than this skill.

- [`data-science`](../data-science/SKILL.md) — Data science guide for end-to-end tasks: exploratory analysis, statistical testing, feature engineering, model…
- [`ml-engineering`](../ml-engineering/SKILL.md) — Guidance, best practices, and checklists for building production-grade machine-learning systems. Use for model…
- [`python`](../python/SKILL.md) — Guidance for modern Python 3.12+ development. Includes framework selection, async vs sync decisions, project l…
- [`data-engineering`](../data-engineering/SKILL.md) — Guides the design, implementation, and operation of scalable batch and streaming data pipelines, modern data w…
- [`pymoo`](../pymoo/SKILL.md) — Use pymoo to solve single- and multi-objective optimization problems, find Pareto fronts, handle constraints,…
- [`networkx`](../networkx/SKILL.md) — Create, analyze, and visualize graphs in Python with NetworkX: graph types, algorithms, generators, file I/O,…
