#!/usr/bin/env bash
set -euo pipefail

required_files=(
  "config/project-config.yml"
  "config/team-structure.yml"
  "config/milestone-config.yml"
  "config/quality-metrics.yml"
  "docker-compose.yml"
  ".github/workflows/ci.yml"
  ".github/workflows/code-quality.yml"
  ".github/workflows/security-scan.yml"
  "tools/sonarqube-config.properties"
  "tools/eslint.config.js"
  "tools/prettier.config.js"
  "tools/checkstyle.xml"
)

for f in "${required_files[@]}"; do
  [[ -s "$f" ]] || { echo "Missing required file: $f"; exit 1; }
done

echo "Phase 1 smoke test passed."
