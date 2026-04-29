# Metric Thresholds

## Cyclomatic Complexity (CC) per Function

| CC Value | Grade     | Status    |
|----------|-----------|-----------|
| ≤ 4      | A         | Excellent |
| 5–10     | B         | Good      |
| 11–20    | C         | Fair      |
| 21–40    | D         | Poor      |
| > 40     | F         | Critical  |

For **average CC across all functions**, apply the same thresholds. A project with average CC > 15 is likely in Poor or worse territory.

## Maintainability Index (MI)

Formula: `MI = 171 - 5.2·ln(HV) - 0.23·CC - 16.2·ln(LOC)`
Where HV = Halstead Volume, CC = cyclomatic complexity, LOC = lines of code per function.

| MI Value | Status    |
|----------|-----------|
| ≥ 85     | Excellent |
| 65–84    | Good      |
| 40–64    | Fair      |
| 20–39    | Poor      |
| < 20     | Critical  |

## Function / Method Size (LOC per function)

| Language               | Good (≤) | Warning (≤) | Critical (>) |
|------------------------|----------|-------------|-------------|
| Java                   | 30       | 50          | 100         |
| TypeScript / JavaScript| 25       | 50          | 100         |
| Python                 | 20       | 40          | 80          |
| Go                     | 30       | 60          | 100         |
| Kotlin                 | 25       | 50          | 100         |
| C / C++                | 40       | 75          | 150         |
| Rust                   | 30       | 60          | 120         |

## Test Coverage

| Coverage % | Status    |
|------------|-----------|
| ≥ 80%      | Excellent |
| 60–79%     | Good      |
| 40–59%     | Fair      |
| 20–39%     | Poor      |
| < 20%      | Critical  |

Target baseline for production: **80% line coverage, 70% branch coverage**.

## Coupling (Instability = Ce / (Ce + Ca))

| Instability | Interpretation |
|-------------|----------------|
| 0.0–0.2     | Very stable (hard to change — ensure it's stable by design) |
| 0.2–0.5     | Balanced |
| 0.5–0.8     | Somewhat unstable |
| 0.8–1.0     | Highly unstable (changes frequently, few dependents — OK for leaf modules) |

Red flag: a **core domain module** with instability > 0.7.

## Circular Dependencies

| Count | Status    |
|-------|-----------|
| 0     | Excellent |
| 1–2   | Fair      |
| 3–5   | Poor      |
| > 5   | Critical  |

## Code Duplication

| Duplication % | Status    |
|---------------|-----------|
| < 3%          | Excellent |
| 3–10%         | Good      |
| 10–20%        | Fair      |
| 20–30%        | Poor      |
| > 30%         | Critical  |

## Comment Density

| Comment % | Interpretation |
|-----------|----------------|
| < 5%      | Under-documented |
| 5–20%     | Appropriate |
| > 30%     | May indicate over-documentation or commented-out dead code |
