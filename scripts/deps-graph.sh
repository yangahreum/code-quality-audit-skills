#!/usr/bin/env bash
# Analyzes module dependency graph and detects circular dependencies.
# Usage: deps-graph.sh [project-path]
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

case "$LANG" in
  js)
    if command -v npx &>/dev/null; then
      SRC_DIR="src"
      [[ -d "$SRC_DIR" ]] || SRC_DIR="."
      echo "=== madge circular deps ===" >&2
      CIRCULAR=$(npx madge --circular --json "$SRC_DIR" 2>/dev/null || echo '[]')
      echo "=== madge dependency graph ===" >&2
      GRAPH=$(npx madge --json "$SRC_DIR" 2>/dev/null || echo '{}')
      echo "{\"language\": \"javascript\", \"circular_dependencies\": $CIRCULAR, \"dependency_graph\": $GRAPH}"
    else
      echo '{"error": "npx not available — install Node.js"}'
    fi
    ;;
  java)
    # jdeps requires a compiled jar; attempt to find one
    JAR=$(find . -name "*.jar" -not -path "*/test*" 2>/dev/null | head -1)
    if [[ -n "$JAR" ]] && command -v jdeps &>/dev/null; then
      echo "=== jdeps summary ===" >&2
      RESULT=$(jdeps -summary -recursive "$JAR" 2>/dev/null | \
        awk 'BEGIN{print "["} NR>1{print ","} {printf "{\"from\":\"%s\",\"to\":\"%s\"}", $1, $3} END{print "]"}')
      echo "{\"language\": \"java\", \"dependency_summary\": $RESULT}"
    else
      echo '{"language": "java", "note": "No compiled JAR found or jdeps unavailable. Run after mvn package / gradle build."}'
    fi
    ;;
  python)
    if command -v pydeps &>/dev/null; then
      echo "=== pydeps ===" >&2
      RESULT=$(pydeps . --show-deps --no-dot 2>/dev/null || echo '{}')
      echo "{\"language\": \"python\", \"deps\": $RESULT}"
    else
      echo '{"error": "pydeps not installed — run: pip install pydeps"}'
    fi
    ;;
  go)
    if command -v go &>/dev/null; then
      echo "=== go list deps ===" >&2
      RESULT=$(go list -json ./... 2>/dev/null | \
        python3 -c "
import json, sys
pkgs = []
for line in sys.stdin:
    try:
        pkgs.append(json.loads(line))
    except:
        pass
print(json.dumps(pkgs))
" 2>/dev/null || echo '[]')
      echo "{\"language\": \"go\", \"packages\": $RESULT}"
    else
      echo '{"error": "go not installed"}'
    fi
    ;;
  *)
    echo '{"error": "Unknown language — cannot perform dependency analysis"}'
    ;;
esac
