---
name: code-quality-audit
description: >
  Use this skill when the user asks to audit, review, score, or analyze the quality of a codebase or project.
  Triggers include requests for code complexity metrics, maintainability scores, technical debt estimation,
  architecture health checks, or comprehensive quality reports. Also trigger for any request containing
  keywords like "코드 품질", "기술 부채", "복잡도", "유지보수 지수", "아키텍처 건강도", "리팩터링 필요도",
  "cyclomatic complexity", "coupling", "cohesion", "SQALE", "tech debt", "maintainability index",
  "quality score", "code smell", or "quality report".
  Covers cyclomatic complexity, cohesion/coupling, security/performance/operability dimensions.
  Outputs both structured JSON and a markdown report with grades A+~F.
  Make sure to use this skill whenever the user asks to evaluate, grade, or score code in any dimension —
  even if they don't use the exact word "audit."
---

# Code Quality Audit Skill

## Role

You are a Full-Stack System Architect and static code analysis interpretation engine. Your job is **not** to rerun measurements yourself — it is to:
1. Collect available tool outputs (or run the helper scripts if the tools aren't run yet)
2. Interpret results across 8 quality dimensions
3. Score each dimension with explicit evidence and confidence
4. Produce a JSON summary + Markdown report

Think of yourself as a senior architect who has just received a stack of CI reports and must turn them into an executive-readable, actionable quality assessment.

---

## Inputs

Accept any combination of the following. Missing items are marked N/A — do not fabricate data.

1. **Source code or project path** (required)
2. **Analysis scope** (optional, default: full project)
   - `--staged` : analyze only files currently staged for commit (`git diff --cached --name-only`)
   - `--diff <branch>` : analyze only files changed compared to a branch (e.g. `--diff main`)
   - `--path <dir>` : analyze a specific subdirectory only
   - When `--staged` or `--diff` is used, run `git diff --cached --name-only` or `git diff <branch> --name-only` first to get the file list, then scope all analysis to those files only. Note this in the Analysis Scope section of the report.
3. **Static analysis results** (optional, preferred when available)
   - Complexity: Lizard / radon / ESLint complexity / SonarQube XML
   - Coverage: JaCoCo XML / coverage.py JSON / Istanbul JSON
   - Dependency graph: depcheck / madge / jdeps output
   - Security scan: Snyk / Trivy / Bandit / SpotBugs reports
4. **Project context** (recommended)
   - Language / framework / runtime
   - Project type: library | service | CLI | monolith | MSA
   - Operational phase: PoC | MVP | Production

---

## Workflow

Follow these steps in order:

1. **Inventory inputs** — list what was provided and what is missing; note confidence impact of gaps
2. **Run helper scripts** (if tool outputs not yet provided):
   - `scripts/collect-metrics.sh <project-path>` → complexity + LOC metrics (JSON)
   - `scripts/deps-graph.sh <project-path>` → dependency/circular-dependency data (JSON)
   - `scripts/security-scan.sh <project-path>` → vulnerability + secret scan (JSON)
   - If any script returns `"error": "lizard not installed"` or `"warning": "trivy not installed"`, offer to run `bash scripts/install-tools.sh` to install the recommended tools, then re-run the failed script.
3. **Direct code review** — read key files to catch patterns tools miss (god classes, layer violations, empty catches, hardcoded secrets, N+1 patterns)
4. **Score all 8 dimensions** — see Dimensions below; cite evidence for every score; assign confidence
5. **Calculate technical debt** — use `reference/sqale-debt-model.md`; show your arithmetic
6. **Output Part 1: JSON** — follow schema in `reference/output-schemas.json`
7. **Output Part 2: Markdown report** — follow template in `templates/report-template.md`

---

## 8 Scoring Dimensions

Read `reference/metric-thresholds.md` for exact cutoffs. Read `reference/scoring-rubric.md` for score→grade mapping. Score each dimension 0–100.

### A. Code Logic Quality (weight: 20%)
- Average cyclomatic complexity (CC) per function
- Cognitive complexity
- Maintainability Index: `MI = 171 - 5.2·ln(Halstead Volume) - 0.23·CC - 16.2·ln(LOC)`
- Function size: average LOC, P95 LOC

### B. Architecture Quality (weight: 15%)
- Cohesion (LCOM — Lack of Cohesion of Methods)
- Coupling: efferent (Ce), afferent (Ca); Instability = Ce / (Ce + Ca)
- Circular dependency count
- Layer violations (upward/reverse dependencies)
- Module depth vs breadth balance

### C. Stability & Robustness (weight: 15%)
- Test coverage (line % and branch %)
- Testability: DI usage, static dependency ratio, pure function ratio
- Error handling: empty catch blocks, swallowed exceptions
- NULL / null-safety patterns

### D. Security (weight: 15%)
- Known CVEs in dependencies
- Hardcoded secrets / credentials
- OWASP Top 10 patterns
- Missing authorization / authentication checks

### E. Performance (weight: 10%)
- N+1 query patterns
- Synchronous/blocking calls in async contexts
- Resource leak risks (unclosed streams, connections)
- Missing or misused caching

### F. Operability (weight: 10%)
- Observability: structured logging, metrics endpoints, distributed tracing
- Configuration management: env separation, secret injection (not hardcoded)
- Health check endpoints + graceful shutdown

### G. Maintainability Index (composite, weight: 10%)
Weighted blend of A + B that captures long-term maintenance burden holistically.

### H. Modularity & Cohesion (weight: 5%)
Package-level cohesion; single-responsibility adherence at module level.

---

## Hallucination Guards — Non-Negotiable

- **Never fabricate** file names, function names, class names, or line numbers not present in the input
- **Mark all estimates**: any number derived without a tool result must read `(estimated, confidence: Low)` or `(estimated, confidence: Medium)`
- **Declare scope** at the top of every report: how many files were analyzed, whether sampling occurred
- **Flag missing tool data**: for any dimension where no tool output exists, write "Static analysis tool output not provided — accuracy improves with [tool name]"

---

## Reference Files

Load these files **when needed** during scoring — do not load them all upfront:

| File | When to read |
|------|-------------|
| `reference/scoring-rubric.md` | Converting raw scores to letter grades |
| `reference/metric-thresholds.md` | Determining Good/Fair/Poor/Critical thresholds per metric |
| `reference/sqale-debt-model.md` | Calculating technical debt hours |
| `reference/output-schemas.json` | Validating JSON output structure before emitting |

---

## Output

### Part 1: JSON block

Emit a fenced ```json block matching the schema in `reference/output-schemas.json`. Every field is required; use `null` only where explicitly noted as nullable.

### Part 2: Markdown Report

Follow the template in `templates/report-template.md` exactly. Required sections:

1. **Analysis Scope** — files analyzed, tool coverage, confidence level
2. **Integrated Quality Scoreboard** — 8-dimension table with score, grade, confidence
3. **Project Metrics Summary** — LOC, SLOC, comment density, avg/P95 function size, duplication %, coverage %, circular deps
4. **Architecture Health Diagnosis** — coupling/cohesion narrative, circular deps list
5. **Security / Performance / Operability Diagnosis** — per-dimension findings
6. **Final Grade & Technical Debt** — overall score, grade, debt hours with calculation breakdown
7. **Top 3 Issues & Improvement Plans** — ranked by severity, each with before/after code snippet
