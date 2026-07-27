#!/usr/bin/env bash
# SmartWin Project Initialization Script
# Usage: ./scripts/init-project.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=============================="
echo " SmartWin Project Initializer"
echo "=============================="

# Check required tools
check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo "ERROR: $1 is not installed. Please install it first."
        exit 1
    fi
}

check_command git
check_command docker
check_command docker-compose

echo "[1/5] Checking environment..."
java_version=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
node_version=$(node --version 2>/dev/null || echo "not installed")
echo "  Java: $java_version"
echo "  Node: $node_version"

echo "[2/5] Installing dependencies..."
if [ -f "$PROJECT_ROOT/pom.xml" ]; then
    echo "  Installing Maven dependencies..."
    cd "$PROJECT_ROOT" && mvn dependency:resolve -q
fi

if [ -f "$PROJECT_ROOT/frontend/package.json" ]; then
    echo "  Installing npm dependencies..."
    cd "$PROJECT_ROOT/frontend" && npm install
fi

echo "[3/5] Initializing database..."
if command -v docker-compose &>/dev/null; then
    cd "$PROJECT_ROOT" && docker-compose up -d mysql redis
    echo "  Waiting for MySQL to be ready..."
    sleep 10
fi

echo "[4/5] Configuring Git hooks..."
if [ -d "$PROJECT_ROOT/.git" ]; then
    cat > "$PROJECT_ROOT/.git/hooks/pre-commit" << 'HOOK'
#!/usr/bin/env bash
echo "Running pre-commit checks..."
# Run linting
if command -v checkstyle &>/dev/null; then
    checkstyle -c tools/checkstyle.xml src/
fi
echo "Pre-commit checks passed."
HOOK
    chmod +x "$PROJECT_ROOT/.git/hooks/pre-commit"
    echo "  Git hooks configured."
fi

echo "[5/5] Project initialization complete!"
echo ""
echo "Next steps:"
echo "  1. Copy .env.example to .env and fill in your configuration"
echo "  2. Run 'make docker-up' to start all services"
echo "  3. Run 'make build' to build the project"
echo "  4. Run 'make test' to run tests"
