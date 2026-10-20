# Statistical Analysis

**Purpose**: Perform rigorous hypothesis testing, regression, Bayesian analysis, power calculations, and model diagnostics in Python. Generate APA‑style reports and publication‑ready tables.

## When to Use
- Testing differences between groups (t‑test, ANOVA, chi‑square). 
- Exploring relationships (correlation, linear/logistic regression). 
- Conducting Bayesian alternatives. 
- Checking assumptions and diagnosing models. 
- Calculating effect sizes, confidence intervals, and required sample sizes. 
- Building econometric or time‑series models with **statsmodels** (OLS, GLM, ARIMA, VAR). 
- Preparing results for APA or journal submission.

---

## Workflow Overview
1. **Define research question & hypotheses**.
2. **Select appropriate test/model** (see Test‑Selection Guide).
3. **Perform a priori power analysis** to set sample size.
4. **Load data, clean, handle missing values, detect outliers**.
5. **Check assumptions** (normality, homogeneity, linearity, stationarity, etc.).
6. **Run the primary analysis** (frequentist or Bayesian).
7. **Compute effect sizes & confidence intervals**.
8. **Validate model** (diagnostics, cross‑validation, out‑of‑sample forecasts).
9. **Report results** in APA format with tables/figures.
10. **Share data & code** for reproducibility.

---

## 1. Test‑Selection Guide
| Scenario | Data type | Recommended test/model |
|---|---|---|
| Compare two independent groups, continuous & normal | Numeric, two groups | Independent t‑test (`pg.ttest`) |
| Same but non‑normal | Numeric, two groups | Mann‑Whitney U (`pg.mwu`) |
| Paired groups, continuous & normal | Numeric, paired | Paired t‑test (`pg.ttest(paired=True)`) |
| >2 independent groups, normal | Numeric, >2 groups | One‑way ANOVA (`pg.anova`) |
| >2 groups, non‑normal | Numeric, >2 groups | Kruskal‑Wallis (`pg.kruskal`) |
| Binary outcome | Categorical | Logistic regression (`statsmodels.discrete.Logit`) |
| Count outcome | Integer | Poisson GLM (`statsmodels.GLM(..., family=Poisson)`) |
| Time‑ordered series | Numeric | ARIMA/SARIMAX (`statsmodels.tsa.ARIMA`) |
| Prior information available | Any | Bayesian counterpart (e.g., Bayesian t‑test with **pymc**) |

**Tip**: Always verify assumptions before finalizing the test.

---

## 2. Power & Sample‑Size Calculations
```python
from statsmodels.stats.power import tt_ind_solve_power, FTestAnovaPower
# Two‑sample t‑test, target d=0.5, power=0.80
n = tt_ind_solve_power(effect_size=0.5, alpha=0.05, power=0.80, ratio=1.0)
print(f"Required n per group: {int(n)}")
# One‑way ANOVA, target f=0.25, 3 groups
anova = FTestAnovaPower()
n_anova = anova.solve_power(effect_size=0.25, k_groups=3, alpha=0.05, power=0.80)
print(f"Required n per group (ANOVA): {int(n_anova)}")
```
*Avoid post‑hoc power analysis; instead report detectable effect size given the observed sample size.*

---

## 3. Assumption Checking
### Normality & Homogeneity (t/ANOVA)
```python
import pingouin as pg
# Normality test + Q‑Q plot
norm = pg.normality(df['score'], method='shapiro')
pg.qqplot(df['score'])
# Homogeneity of variance (Levene)
levene = pg.homoscedasticity(df, dv='score', group='group')
```
**Remedies**:
- Mild normality violation with n>30 → proceed (robust). 
- Severe violation → use non‑parametric test or transform data. 
- Unequal variances → Welch's t‑test (`pg.ttest(..., correction='welch')`) or Welch ANOVA.

### Linearity & Multicollinearity (Regression)
```python
import statsmodels.api as sm
from statsmodels.stats.outliers_influence import variance_inflation_factor
X = sm.add_constant(X)
# VIF
vif = pd.DataFrame({"VIF": [variance_inflation_factor(X.values, i) for i in range(X.shape[1])]}, index=X.columns)
print(vif)
```
- VIF > 5 suggests multicollinearity; consider dropping or combining predictors.
- Non‑linear patterns → add polynomial terms (`I(x**2)`) or use GAM.

### Stationarity (Time Series)
```python
from statsmodels.tsa.stattools import adfuller
result = adfuller(y_series)
print('ADF p‑value:', result[1])
```
- p > 0.05 → difference the series before ARIMA fitting.

---

## 4. Running Analyses
### 4.1 Frequentist Tests (pingouin)
#### Independent t‑test
```python
import pingouin as pg
result = pg.ttest(group_a, group_b, correction='auto')
print(f"t({result['dof'].values[0]:.0f}) = {result['T'].values[0]:.2f}, p = {result['p-val'].values[0]:.3f}, d = {result['cohen-d'].values[0]:.2f}")
```
#### One‑way ANOVA with post‑hoc
```python
aov = pg.anova(dv='score', between='group', data=df, detailed=True)
print(aov)
if aov['p-unc'].values[0] < 0.05:
    post = pg.pairwise_tukey(dv='score', between='group', data=df)
    print(post)
```
#### Linear regression (statsmodels)
```python
import statsmodels.api as sm
X = sm.add_constant(df[['hours', 'gpa']])
model = sm.OLS(df['exam_score'], X).fit()
print(model.summary())
# VIF check as shown earlier
```
#### Logistic regression (statsmodels)
```python
import statsmodels.api as sm
X = sm.add_constant(df[['age', 'income']])
logit = sm.Logit(df['purchase'], X).fit()
print(logit.summary())
print('Odds ratios:', np.exp(logit.params))
```
#### ARIMA (statsmodels)
```python
from statsmodels.tsa.arima.model import ARIMA
model = ARIMA(y_series, order=(1,1,1))
res = model.fit()
print(res.summary())
forecast = res.get_forecast(steps=12)
print(forecast.summary_frame())
res.plot_diagnostics()
```

### 4.2 Bayesian Alternatives (pymc)
```python
import pymc as pm
import arviz as az
with pm.Model() as m:
    mu1 = pm.Normal('mu1', mu=0, sigma=10)
    mu2 = pm.Normal('mu2', mu=0, sigma=10)
    sigma = pm.HalfNormal('sigma', sigma=10)
    y1 = pm.Normal('y1', mu=mu1, sigma=sigma, observed=group_a)
    y2 = pm.Normal('y2', mu=mu2, sigma=sigma, observed=group_b)
    diff = pm.Deterministic('diff', mu1 - mu2)
    trace = pm.sample(2000, tune=1000, return_inferencedata=True)
print(az.summary(trace, var_names=['diff']))
az.plot_posterior(trace, var_names=['diff'], ref_val=0)
```
- Bayes Factor can be obtained with `bayesfactor` utilities or by comparing marginal likelihoods.

---

## 5. Effect‑Size Calculation
| Test | Effect size | How to obtain (pingouin) |
|---|---|---|
| t‑test | Cohen's d | `result['cohen-d']` |
| ANOVA | Partial η² | `aov['np2']` |
| Correlation | Pearson r | `pg.corr(x, y)['r']` |
| Logistic regression | Odds ratio | `np.exp(model.params)` |
| Poisson regression | Rate ratio | `np.exp(model.params)` |

**Confidence intervals** (example for Cohen's d):
```python
from pingouin import compute_effsize_from_t
d, ci = compute_effsize_from_t(t=result['T'].values[0], nx=len(group_a), ny=len(group_b), eftype='cohen')
print(f"d = {d:.2f}, 95% CI [{ci[0]:.2f}, {ci[1]:.2f}]")
```

---

## 6. Model Diagnostics (statsmodels)
- **Residual plots**: `model.plot_diagnostics()` for OLS.
- **Heteroskedasticity**: `het_breuschpagan(resid, X)`.
- **Autocorrelation**: `sm.stats.durbin_watson(resid)` or Ljung‑Box via `acorr_ljungbox`.
- **Influence**: `results.get_influence().summary_frame()` (Cook's distance, leverage).
- **Multicollinearity**: VIF as shown earlier.
- **Overdispersion (GLM)**: `results.pearson_chi2 / results.df_resid` – values > 1.5 suggest Negative Binomial.

---

## 7. Reporting (APA style)
### Required elements
1. Descriptive statistics (M, SD, n) for each group/variable.
2. Test statistic, degrees of freedom, exact p‑value.
3. Effect size with 95 % CI.
4. Assumption check outcomes.
5. Post‑hoc or follow‑up analyses if applicable.

### Template examples
**Independent t‑test**
```
Group A (n = 48, M = 75.2, SD = 8.5) scored higher than Group B (n = 52, M = 68.3, SD = 9.2), t(98) = 3.82, p < .001, d = 0.77, 95% CI [0.36, 1.18]. Assumptions of normality (Shapiro‑Wilk: W = 0.97, p = .18) and homogeneity of variance (Levene: F(1,98) = 1.23, p = .27) were met.
```
**One‑way ANOVA**
```
A one‑way ANOVA showed a significant effect of condition on scores, F(2,147) = 8.45, p < .001, η²ₚ = .10. Tukey HSD indicated Condition A (M = 78.2, SD = 7.3) > Condition B (M = 71.5, SD = 8.1, p = .002, d = 0.87) and Condition C (M = 70.1, SD = 7.9, p < .001, d = 1.07). Conditions B and C did not differ (p = .52, d = 0.18).
```
**Logistic regression**
```
Logistic regression predicting purchase from age and income was significant, χ²(2) = 14.3, p = .001, Nagelkerke R² = .22. Odds ratios: age = 1.04 (95% CI [1.01, 1.07]), income = 1.12 (95% CI [1.05, 1.20]). Hosmer‑Lemeshow χ²(8) = 6.2, p = .63 indicated good fit.
```
---

## 8. Common Pitfalls & How to Avoid
- **P‑hacking**: Pre‑register hypotheses; avoid re‑running tests until significance is achieved.
- **Ignoring assumptions**: Run the checks in Section 3; report violations and remedial actions.
- **Misinterpreting p‑values**: p < .05 does not imply practical importance; always report effect size.
- **Using wrong model for outcome type**: Binary → logistic; count → Poisson/Neg‑Binomial; continuous → OLS/GLS.
- **Overlooking overdispersion** in Poisson models; switch to Negative Binomial when dispersion > 1.5.
- **Neglecting multicollinearity**: VIF > 5 warrants variable reduction or ridge regression.
- **Forgetting constant term** in OLS/GLM: `sm.add_constant()`.
- **Non‑stationary time series**: Difference before ARIMA; verify with ADF test.
- **Multiple comparisons**: Apply Bonferroni, Holm, or FDR corrections when testing many hypotheses.
- **Post‑hoc power analysis**: Report detectable effect size instead.

---

## 9. Getting Started Checklist
- [ ] State research question & hypotheses.
- [ ] Choose test/model (use Test‑Selection Guide).
- [ ] Conduct a priori power analysis.
- [ ] Load data; clean missing values; detect outliers.
- [ ] Verify assumptions (normality, homogeneity, linearity, stationarity).
- [ ] Run primary analysis (frequentist or Bayesian).
- [ ] Compute effect sizes & 95 % CIs.
- [ ] Perform post‑hoc or multiple‑comparison corrections if needed.
- [ ] Produce diagnostic plots and address any violations.
- [ ] Write APA‑style report with tables/figures.
- [ ] Validate model on hold‑out data or via cross‑validation.
- [ ] Share reproducible code and data.

---

## 10. References & Resources
- **Pingouin**: https://pingouin.readthedocs.io
- **Statsmodels**: https://www.statsmodels.org
- **PyMC**: https://www.pymc.io
- **APA Style**: https://apastyle.apa.org
- Cohen, J. (1988). *Statistical Power Analysis for the Behavioral Sciences*.
- Gelman, A., & Hill, J. (2006). *Data Analysis Using Regression and Multilevel/Hierarchical Models*.
- Kruschke, J. K. (2014). *Doing Bayesian Data Analysis*.
