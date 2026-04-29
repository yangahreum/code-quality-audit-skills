# Scoring Rubric

## Score → Grade → Status Mapping

| Score | Grade | Status    | Meaning                                      |
|-------|-------|-----------|----------------------------------------------|
| 95–100 | A+   | Excellent | Exceptional — industry reference level        |
| 90–94  | A    | Excellent | Industry best practice level                  |
| 85–89  | A−   | Excellent | Strong, minor improvements possible           |
| 80–84  | B+   | Good      | Solid, suitable for production                |
| 75–79  | B    | Good      | Suitable for production, room to improve      |
| 70–74  | B−   | Good      | Acceptable, some technical debt accumulating  |
| 65–69  | C+   | Fair      | Works, but noticeable debt; plan improvements |
| 60–64  | C    | Fair      | Works but accumulating debt; refactor planned |
| 55–59  | C−   | Fair      | Borderline; significant improvements needed   |
| 50–54  | D+   | Poor      | Problematic; short-term refactoring required  |
| 40–49  | D    | Poor      | Short-term refactoring needed                 |
| 25–39  | F    | Critical  | Immediate improvement required                |
| 0–24   | F−   | Critical  | Severe — do not ship without major overhaul   |

## Overall Grade Calculation

`overall_score = Σ(dimension_score × weight)`

Weights:
- Code Logic Quality: 20%
- Architecture Quality: 15%
- Stability & Robustness: 15%
- Security: 15%
- Performance: 10%
- Operability: 10%
- Maintainability Index (composite): 10%
- Modularity & Cohesion: 5%

## Confidence Levels

| Confidence | Meaning |
|------------|---------|
| High | Full tool output available + direct code review |
| Medium | Partial tool data or inferred from code structure |
| Low | No tool data; score derived from code reading only or sampling |

## How to Handle N/A Dimensions

If a dimension cannot be scored at all (e.g., no test files exist for Stability, no network calls for Performance), mark the dimension as `null` in JSON and exclude it from the weighted average. Redistribute that weight proportionally across scored dimensions.
