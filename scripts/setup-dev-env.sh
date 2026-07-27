#!/usr/bin/env bash
# SmartWin Development Environment Setup Script
# Usage: ./scripts/setup-dev-env.sh
set -euo pipefail

echo "===================================="
echo " SmartWin Dev Environment Setup"
echo "===================================="

REQUIRED_JAVA_VERSION=17
REQUIRED_NODE_VERSION=18
REQUIRED_MAVEN_VERSION="3.8"

check_java() {
    echo "[1/4] Checking Java..."
    if ! command -v java &>/dev/null; then
        echo "  ERROR: Java not found. Please install Java $REQUIRED_JAVA_VERSION+"
        echo "  Download: https://adoptium.net/"
        exit 1
    fi
    java_version=$(java -version 2>&1 | grep version | awk -F '"' '{print $2}' | awk -F '.' '{print $1}')
    if [ "$java_version" -lt "$REQUIRED_JAVA_VERSION" ]; then
        echo "  ERROR: Java $REQUIRED_JAVA_VERSION+ required, found $java_version"
        exit 1
    fi
    echo "  OK: Java $java_version"
}

check_node() {
    echo "[2/4] Checking Node.js..."
    if ! command -v node &>/dev/null; then
        echo "  WARNING: Node.js not found. Frontend development requires Node $REQUIRED_NODE_VERSION+"
        echo "  Download: https://nodejs.org/"
        return
    fi
    node_version=$(node --version | tr -d 'v' | awk -F '.' '{print $1}')
    if [ "$node_version" -lt "$REQUIRED_NODE_VERSION" ]; then
        echo "  WARNING: Node $REQUIRED_NODE_VERSION+ recommended, found $node_version"
    else
        echo "  OK: Node v$node_version"
    fi
}

check_maven() {
    echo "[3/4] Checking Maven..."
    if ! command -v mvn &>/dev/null; then
        echo "  WARNING: Maven not found. Using Maven wrapper if available."
        return
    fi
    mvn_version=$(mvn --version | head -n 1 | awk '{print $3}')
    echo "  OK: Maven $mvn_version"
}

configure_ide() {
    echo "[4/4] Configuring IDE settings..."
    mkdir -p .idea
    cat > .idea/codeStyles.xml << 'XML'
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="ProjectCodeStyleConfiguration">
    <code_scheme name="Project" version="173">
      <option name="RIGHT_MARGIN" value="120" />
    </code_scheme>
  </component>
</project>
XML
    echo "  IntelliJ IDEA settings configured."
    echo "  VS Code: Install recommended extensions from .vscode/extensions.json"
}

check_java
check_node
check_maven
configure_ide

echo ""
echo "Development environment setup complete!"
echo "Run './scripts/init-project.sh' to initialize the project."
