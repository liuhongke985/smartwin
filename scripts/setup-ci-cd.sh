#!/usr/bin/env bash
# SmartWin CI/CD Setup Script
# Usage: ./scripts/setup-ci-cd.sh
set -euo pipefail

echo "=============================="
echo " SmartWin CI/CD Setup"
echo "=============================="

GITHUB_REPO="${GITHUB_REPO:-liuhongke985/smartwin}"

echo "[1/4] Verifying GitHub Actions workflows..."
workflows=(".github/workflows/ci.yml" ".github/workflows/code-quality.yml" 
           ".github/workflows/security-scan.yml" ".github/workflows/release.yml")
for w in "${workflows[@]}"; do
    if [ -f "$w" ]; then
        echo "  OK: $w"
    else
        echo "  MISSING: $w"
    fi
done

echo "[2/4] Checking required GitHub Secrets..."
required_secrets=(
    "SONAR_TOKEN"
    "SONAR_HOST_URL"
    "DOCKER_USERNAME"
    "DOCKER_PASSWORD"
)
echo "  The following secrets must be configured in GitHub repository settings:"
for secret in "${required_secrets[@]}"; do
    echo "    - $secret"
done

echo "[3/4] Verifying tool configurations..."
tool_configs=("tools/sonarqube-config.properties" "tools/checkstyle.xml")
for cfg in "${tool_configs[@]}"; do
    if [ -f "$cfg" ]; then
        echo "  OK: $cfg"
    else
        echo "  MISSING: $cfg"
    fi
done

echo "[4/4] CI/CD setup verification complete."
echo ""
echo "Next steps:"
echo "  1. Configure GitHub Secrets listed above"
echo "  2. Enable GitHub Actions in repository settings"
echo "  3. Set up branch protection rules for main and develop"
echo "  4. Configure SonarQube server and project"
