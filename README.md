# code-quality-audit

A Claude Code skill that audits codebase quality across 8 dimensions, estimates technical debt in hours, and outputs a structured JSON + Markdown report with grades A+~F.

## What it does

- Scores code across **8 dimensions**: Code Logic, Architecture, Stability, Security, Performance, Operability, Maintainability Index, Modularity & Cohesion
- Estimates **technical debt** using the SQALE model (in hours)
- Outputs **JSON** (machine-readable) + **Markdown report** (human-readable)
- Runs helper scripts to collect metrics via Lizard, radon, ESLint, madge, Trivy, Bandit, etc.
- Works with or without pre-run tool outputs — missing data is marked N/A with confidence indicators

## Installation

Copy this folder to your Claude Code skills directory:

```bash
cp -r code-quality-audit ~/.claude/skills/code-quality-audit
```

Claude Code will automatically detect it. No restart required.

## Usage

Just ask Claude in natural language — it triggers automatically:

```
이 프로젝트 코드 품질을 감사해줘
기술 부채가 얼마나 되는지 분석해줘
유지보수 지수랑 복잡도 점수 좀 봐줘
아키텍처 건강도 리포트 만들어줘
Audit the code quality of this project
Show me the cyclomatic complexity and maintainability score
How much technical debt does this codebase have?
```

### Analysis Scope Options

분석 범위를 좁혀서 실행할 수 있습니다:

| Option | Description | Example request |
|--------|-------------|-----------------|
| `--staged` | Git staged 파일만 분석 | "staged된 파일만 품질 분석해줘" |
| `--diff <branch>` | 특정 브랜치 대비 변경 파일만 분석 | "main 대비 변경된 코드 감사해줘" |
| `--path <dir>` | 특정 서브디렉토리만 분석 | "src/service 폴더만 분석해줘" |

옵션을 명시하지 않으면 프로젝트 전체를 분석합니다.

## Directory Structure

```
code-quality-audit/
├── SKILL.md                      # Main entrypoint — skill role, workflow, 8 dimensions
├── reference/
│   ├── scoring-rubric.md         # Score → letter grade mapping (A+ ~ F−)
│   ├── metric-thresholds.md      # CC, MI, LOC, coverage thresholds by language
│   ├── sqale-debt-model.md       # Technical debt unit cost table
│   └── output-schemas.json       # JSON output schema
├── scripts/
│   ├── collect-metrics.sh        # Runs Lizard / radon / ESLint per language
│   ├── deps-graph.sh             # Runs madge / jdeps / pydeps for dependency analysis
│   └── security-scan.sh          # Runs Trivy / Bandit / npm audit
└── templates/
    └── report-template.md        # Markdown report template
```

## Scoring Dimensions

| # | Dimension | Weight |
|---|-----------|-------:|
| A | Code Logic Quality (CC, MI, function size) | 20% |
| B | Architecture Quality (coupling, cohesion, circular deps) | 15% |
| C | Stability & Robustness (test coverage, error handling) | 15% |
| D | Security (CVE, OWASP Top 10, hardcoded secrets) | 15% |
| E | Performance (N+1, resource leaks, blocking calls) | 10% |
| F | Operability (observability, config management, health checks) | 10% |
| G | Maintainability Index (composite) | 10% |
| H | Modularity & Cohesion | 5% |

## Supported Languages & Tools

| Language | Complexity | Deps | Security |
|----------|-----------|------|----------|
| Python | radon | pydeps | Bandit + Trivy |
| JavaScript / TypeScript | ESLint | madge | npm audit + Trivy |
| Java / Kotlin | Lizard | jdeps | OWASP dep-check + Trivy |
| Go | gocyclo | go list | Trivy |
| Any | Lizard (fallback) | — | Trivy |

> Tools are optional. If not installed, the skill falls back to static code reading and marks scores as `(estimated, confidence: Low/Medium)`.

## Output Example

### JSON summary
```json
{
  "summary": {
    "overall_grade": "C+",
    "overall_score": 67,
    "tech_debt_hours": 49.5,
    "tech_debt_calculation": "3 funcs CC>40 × 4h = 12h\n2 circular deps × 8h = 16h\n...",
    "one_liner": "Functional but accumulating debt; prioritize test coverage and circular dependency removal.",
    "confidence": "Medium",
    "input_completeness": "Code provided; no tool outputs — scores estimated from static review"
  },
  ...
}
```

### Markdown report sections
1. Analysis Scope
2. Integrated Quality Scoreboard (8-dimension table)
3. Project Metrics Summary
4. Architecture Health Diagnosis
5. Security / Performance / Operability Diagnosis
6. Final Grade & Technical Debt
7. Top 3 Issues with Before/After code snippets

## Hallucination Guards

- Never fabricates file names or metrics not present in the input
- All estimated values are explicitly marked `(estimated, confidence: Low/Medium)`
- Analysis scope (files analyzed, sampling) is declared at the top of every report
