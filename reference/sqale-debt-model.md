# SQALE Technical Debt Model

SQALE (Software Quality Assessment based on Lifecycle Expectations) estimates the remediation cost of quality issues in developer-hours.

## Unit Cost Table

| Issue Type | Unit | Estimated Hours |
|------------|------|----------------|
| Function with CC > 40 | per function | 4 h |
| Function with CC 21–40 | per function | 2 h |
| Function with CC 11–20 | per function | 0.5 h |
| God class / file (> 500 LOC) | per class | 16 h |
| Circular dependency | per cycle | 8 h |
| Duplicate code block (> 50 LOC) | per block | 2 h |
| Missing unit tests (per 1% below 80% line coverage target) | per % gap | 0.5 h |
| Empty / swallowed catch block | per occurrence | 1 h |
| Security — Critical CVE or OWASP violation | per finding | 8 h |
| Security — High severity | per finding | 4 h |
| Security — Medium severity | per finding | 1 h |
| Hardcoded secret | per occurrence | 2 h |
| Missing auth/authorization check | per endpoint | 4 h |
| Layer violation (reverse dependency) | per violation | 3 h |
| Missing structured logging | per service entry-point | 1 h |
| Missing health-check endpoint | per service | 2 h |
| N+1 query pattern | per occurrence | 3 h |
| Resource leak (unclosed stream/connection) | per occurrence | 2 h |

## Calculation

```
total_debt_hours = Σ (count_of_issue_type × unit_cost)
```

Always show the arithmetic in `tech_debt_calculation`. Example:

```
3 functions CC>40 × 4h = 12h
2 circular deps × 8h = 16h
Coverage gap: 80% target - 45% actual = 35% × 0.5h = 17.5h
4 empty catch blocks × 1h = 4h
─────────────────────────────
Total: 49.5h
```

## Debt Rating Bands

| Total Debt Hours | Rating |
|-----------------|--------|
| < 8 h           | A — Minimal debt |
| 8–40 h          | B — Manageable debt |
| 40–160 h        | C — Significant debt |
| 160–640 h       | D — Heavy debt |
| > 640 h         | E — Overwhelming debt |
