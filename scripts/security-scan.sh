#!/usr/bin/env bash
# Runs security vulnerability and secret scans.
# Usage: security-scan.sh [project-path]
# Output: JSON to stdout

set -euo pipefail

PROJECT="${1:-.}"
cd "$PROJECT"

detect_lang() {
  if [[ -f package.json ]];       then echo "js"; return; fi
  if [[ -f pom.xml || -f build.gradle || -f build.gradle.kts ]]; then echo "java"; return; fi
  if [[ -f requirements.txt || -f pyproject.toml || -f setup.py ]]; then echo "python"; return; fi
  if [[ -f go.mod ]]; then echo "go"; return; fi
  echo "unknown"
}

LANG=$(detect_lang)
echo "Detected language: $LANG" >&2

RESULTS="{}"

# --- Universal: Trivy ---
if command -v trivy &>/dev/null; then
  echo "=== trivy scan ===" >&2
  TRIVY=$(trivy fs --scanners vuln,secret --format json --quiet . 2>/dev/null || echo '{"error": "trivy scan failed"}')
  RESULTS=$(echo "$RESULTS" | python3 -c "
import json, sys
r = json.load(sys.stdin)
r['trivy'] = json.loads('''$TRIVY''')
print(json.dumps(r))
" 2>/dev/null || echo "$RESULTS")
else
  echo '{"warning": "trivy not installed — install from https://aquasecurity.github.io/trivy/"}' >&2
  RESULTS=$(echo "$RESULTS" | python3 -c "
import json, sys
r = json.load(sys.stdin)
r['trivy'] = {'error': 'not installed'}
print(json.dumps(r))
" 2>/dev/null || echo "$RESULTS")
fi

# --- Language-specific ---
case "$LANG" in
  python)
    if command -v bandit &>/dev/null; then
      echo "=== bandit scan ===" >&2
      BANDIT=$(bandit -r . -f json -q 2>/dev/null || echo '{"error": "bandit scan failed"}')
      echo "$RESULTS" | python3 -c "
import json, sys
r = json.load(sys.stdin)
r['bandit'] = $BANDIT
print(json.dumps(r))
" 2>/dev/null || echo "$RESULTS"
    else
      echo '{"warning": "bandit not installed — run: pip install bandit"}' >&2
      echo "$RESULTS"
    fi
    ;;
  js)
    if [[ -f package.json ]] && command -v npm &>/dev/null; then
      echo "=== npm audit ===" >&2
      NPM_AUDIT=$(npm audit --json 2>/dev/null || echo '{"error": "npm audit failed"}')
      echo "$RESULTS" | python3 -c "
import json, sys
r = json.load(sys.stdin)
r['npm_audit'] = $NPM_AUDIT
print(json.dumps(r))
" 2>/dev/null || echo "$RESULTS"
    else
      echo "$RESULTS"
    fi
    ;;
  java)
    if command -v mvn &>/dev/null && [[ -f pom.xml ]]; then
      echo "=== OWASP dependency-check ===" >&2
      mvn dependency-check:check -q 2>/dev/null || echo "mvn dependency-check not configured" >&2
    fi
    echo "$RESULTS"
    ;;
  *)
    echo "$RESULTS"
    ;;
esac
