# Prompt Engineering

Design prompts that reliably guide large language models (LLMs) to produce the desired output. Apply rigorous, code‑like discipline: be explicit, test iteratively, and measure impact.

## When to Use
- You need a stable prompt for a production feature.
- You want to improve accuracy, consistency, or cost of an existing prompt.
- You are building multi‑turn agents, RAG pipelines, or any LLM‑driven tool.
- You need ready‑to‑use prompt templates for common tasks (code review, debugging, explanation, etc.).

---

## Core Capabilities
- **Prompt design** – create clear, structured instructions.
- **System prompt architecture** – set global behavior and constraints.
- **Few‑shot learning** – teach the model with examples.
- **Chain‑of‑thought** – obtain step‑by‑step reasoning.
- **Template systems** – reuse prompt skeletons with variables.
- **Evaluation & optimization** – test, measure, and iterate.

---

## Prompt Design Patterns
### 1. Structured System Prompt
Define the model’s role, context, constraints, and output format in separate sections.

```text
System:
- Role: Senior backend engineer.
- Context: The user is building a REST API for a fintech app.
- Instructions: Design the API, consider security, and suggest code snippets.
- Constraints: Do not exceed 150 words per response. Do not reveal internal model details.
- Output format: JSON with fields "analysis", "recommendations", "code_example".
- Examples: (optional) Provide a short example of the expected JSON.
```

### 2. Few‑Shot Examples
Show 2‑5 input‑output pairs that illustrate the exact behavior you need.

```markdown
Extract issue data from support tickets:

Input: "My login fails with error 403"
Output: {"issue":"authentication","error_code":"403","priority":"high"}

Input: "Add dark mode to settings"
Output: {"issue":"feature_request","error_code":null,"priority":"low"}

Now process: "Cannot upload files larger than 10 MB"
```

Guidelines:
- Include diverse cases, including edge cases.
- Keep formatting consistent across examples.
- Add negative examples if they help the model avoid unwanted behavior.

### 3. Chain‑of‑Thought (CoT)
Ask the model to reason before giving the final answer.

```markdown
Analyze the bug report and determine the root cause.

Think step by step:
1. Expected behavior?
2. Actual behavior?
3. Recent changes?
4. Involved components?
5. Likely cause?

Bug: "Users cannot save drafts after the cache update deployed yesterday."
```

Use CoT for complex reasoning, math, or when you need a trace for debugging.

### 4. Template System with Variables
Create a reusable skeleton and substitute variables at runtime.

```python
template = """
You are a {role} specializing in {focus}.

Task: {task_description}

Provide a concise answer in JSON:
{output_schema}
"""

prompt = template.format(
    role="security analyst",
    focus="SQL injection detection",
    task_description="Review the following query and list potential injection vectors.",
    output_schema="{\"issues\": [\"...\"], \"recommendations\": [\"...\"]}"
)
```

### 5. Progressive Disclosure
Start simple, add constraints, reasoning, then examples only if needed.

| Level | Prompt Example |
|-------|-----------------|
| 1 | `Summarize this article.` |
| 2 | `Summarize this article in three bullet points.` |
| 3 | `Identify the three main findings, then summarize each in a bullet point.` |
| 4 | Add two few‑shot examples of good summaries before the input.

### 6. Instruction Hierarchy
Order the prompt components from most to least specific:

```
[System Context] → [Task Instruction] → [Examples] → [Input Data] → [Output Format]
```

---

## Anti‑Patterns & Sharp Edges
| Issue | Why Bad | Fix |
|------|----------|-----|
| Vague instructions | Model guesses intent, results vary | State exact actions and constraints |
| Kitchen‑sink prompt | Overloads context, wastes tokens | Include only relevant information |
| No negative instructions | Model may produce disallowed content | Add explicit “Do NOT …” clauses |
| Imprecise output format | Model returns free‑form text | Provide a concrete schema (JSON, CSV, list) |
| Default temperature for all tasks | Over‑ or under‑creative responses | Adjust `temperature` per task (e.g., 0.2 for factual, 0.7 for creative) |
| Ignoring prompt injection | User input can alter behavior | Sanitize user data or isolate it from system instructions |

---

## Evaluation & Optimization Workflow
1. **Define metrics** – accuracy, consistency, token count, latency.
2. **Create test set** – include typical, edge‑case, and adversarial inputs.
3. **Run baseline** – record metric values for the initial prompt.
4. **Iterate** – change one element (e.g., add a constraint) at a time.
5. **A/B test** – compare new version against baseline on the same test set.
6. **Measure impact** – accept changes that improve target metrics without exceeding token budget.
7. **Version control** – store prompts in a Git repository; tag each iteration.
8. **Monitor in production** – log model outputs, compute success rates, and alert on regressions.

---

## Prompt Improvement Checklist
- [ ] **Clear objective** – state exactly what you want.
- [ ] **Relevant context** – include only necessary background.
- [ ] **Explicit format** – define JSON, list, or other structure.
- [ ] **Examples provided** – add 2‑5 diverse few‑shot pairs.
- [ ] **Constraints listed** – specify length limits, prohibited content, or style.
- [ ] **Reasoning request** – include CoT if the task is complex.
- [ ] **Safety guards** – add “Do NOT reveal internal model details” and sanitize user input.
- [ ] **Temperature set** – choose a value appropriate for the task.
- [ ] **Token budget checked** – ensure prompt + expected output stays within model window.

---

## Ready‑to‑Use Prompt Library (Selected Templates)
### Role‑Based Prompt – Expert Developer
```
Act as an expert software developer with 15+ years of experience.
When reviewing code:
1. Identify bugs and security issues.
2. Suggest performance improvements.
3. Recommend better design patterns.
4. Explain reasoning clearly.
Format:
- Critical Issues
- Suggestions
- Praise
```
### Task Prompt – Debug This Code
```
Debug the following code.
Provide:
1. Problem identification
2. Root cause analysis
3. Fixed code snippet
4. Prevention advice
Show reasoning step by step.
```
### Structured Output Prompt
```
Respond in JSON:
{
  "analysis": "...",
  "recommendations": ["..."],
  "confidence": 0.0,
  "caveats": ["..."]
}
```
---

## Quick Reference Commands (optional)
- **Run a prompt locally with OpenAI API**:
  ```bash
  OPENAI_API_KEY=... python -c "import openai; print(openai.ChatCompletion.create(model='gpt-4', messages=[{'role':'system','content':'<system prompt>'},{'role':'user','content':'<input>'}]))"
  ```
- **Install a prompt‑templating library** (if you prefer a helper):
  ```bash
  pip install jinja2
  ```

---

Follow these patterns, avoid the anti‑patterns, and iterate with the checklist to create robust, cost‑effective prompts for any LLM‑driven application.
