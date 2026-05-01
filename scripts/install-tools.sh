#!/usr/bin/env bash
# Installs the recommended minimum toolset for code-quality-audit skill.
# Required: lizard (complexity), trivy (security/secrets)
# Usage: bash scripts/install-tools.sh

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[SKIP]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; }

echo "=== code-quality-audit: installing recommended tools ==="
echo ""

# --- lizard (pip) ---
if command -v lizard &>/dev/null; then
  warn "lizard already installed ($(lizard --version 2>/dev/null | head -1))"
else
  echo "Installing lizard..."
  if command -v pip3 &>/dev/null; then
    pip3 install lizard --quiet && ok "lizard installed"
  elif command -v pip &>/dev/null; then
    pip install lizard --quiet && ok "lizard installed"
  else
    fail "pip not found — install Python first: https://python.org"
  fi
fi

# --- trivy (brew or script) ---
if command -v trivy &>/dev/null; then
  warn "trivy already installed ($(trivy --version 2>/dev/null | head -1))"
else
  echo "Installing trivy..."
  if command -v brew &>/dev/null; then
    brew install trivy --quiet && ok "trivy installed"
  else
    echo "brew not found — trying official install script..."
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin 2>/dev/null \
      && ok "trivy installed" \
      || fail "trivy install failed — install manually: https://aquasecurity.github.io/trivy/"
  fi
fi

echo ""
echo "=== Optional tools (install separately if needed) ==="
echo "  radon (Python complexity): pip install radon"
echo "  bandit (Python security):  pip install bandit"
echo "  madge (JS/TS deps):        npm install -g madge"
echo "  gocyclo (Go complexity):   go install github.com/fzipp/gocyclo/cmd/gocyclo@latest"
echo ""
echo "Done. Run the code-quality-audit skill on your project."
