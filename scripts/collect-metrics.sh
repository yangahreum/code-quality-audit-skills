#!/usr/bin/env bash
# Collects complexity and LOC metrics for a project.
# Usage: collect-metrics.sh [project-path]
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

run_lizard_fallback() {
  if command -v lizard &>/dev/null; then
    lizard . --json 2>/dev/null || echo '{"error": "lizard failed"}'
  else
    echo '{"error": "lizard not installed — run: bash scripts/install-tools.sh"}' >&2
    echo '{"error": "lizard not installed"}'
  fi
}

case "$LANG" in
  python)
    if command -v radon &>/dev/null; then
      echo "=== radon cyclomatic complexity ===" >&2
      CC=$(radon cc -s -a . --json 2>/dev/null || echo '{}')
      echo "=== radon maintainability index ===" >&2
      MI=$(radon mi -s . --json 2>/dev/null || echo '{}')
      echo "{\"language\": \"python\", \"cyclomatic_complexity\": $CC, \"maintainability_index\": $MI}"
    else
      echo '{"error": "radon not installed — run: pip install radon"}' >&2
      run_lizard_fallback
    fi
    ;;
  js)
    if command -v npx &>/dev/null; then
      echo "=== ESLint complexity ===" >&2
      # Try eslint complexity rule; fall back to lizard
      RESULT=$(npx eslint . --rule '{"complexity": ["warn", 10]}' --format json 2>/dev/null || echo '[]')
      echo "{\"language\": \"javascript\", \"eslint_results\": $RESULT}"
    else
      run_lizard_fallback
    fi
    ;;
  java)
    run_lizard_fallback
    ;;
  go)
    if command -v gocyclo &>/dev/null; then
      echo "=== gocyclo ===" >&2
      RESULT=$(gocyclo . 2>/dev/null | awk 'BEGIN{print "["} NR>1{print ","} {printf "{\"cc\":%s,\"func\":\"%s\",\"file\":\"%s\"}", $1, $2, $3} END{print "]"}')
      echo "{\"language\": \"go\", \"gocyclo\": $RESULT}"
    else
      run_lizard_fallback
    fi
    ;;
  *)
    run_lizard_fallback
    ;;
esac
