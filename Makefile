# SmartWin Project Makefile
# Usage: make <target>

.PHONY: help install build test docker-up docker-down lint format clean

# Default target
help:
	@echo "SmartWin Project Commands"
	@echo "========================"
	@echo "  make install       Install all dependencies"
	@echo "  make build         Build all modules"
	@echo "  make test          Run all tests"
	@echo "  make docker-up     Start all Docker services"
	@echo "  make docker-down   Stop all Docker services"
	@echo "  make lint          Run code linters"
	@echo "  make format        Format code"
	@echo "  make clean         Clean build artifacts"
	@echo "  make init          Initialize project (first time setup)"

install:
	@echo "Installing Maven dependencies..."
	mvn dependency:resolve -q
	@echo "Installing npm dependencies..."
	@if [ -d frontend ]; then cd frontend && npm install; fi
	@echo "Dependencies installed."

build:
	@echo "Building project..."
	mvn clean package -DskipTests -q
	@if [ -d frontend ]; then cd frontend && npm run build; fi
	@echo "Build complete."

test:
	@echo "Running tests..."
	mvn test
	@if [ -d frontend ]; then cd frontend && npm test; fi
	@echo "Tests complete."

test-unit:
	mvn test -Dtest="**/*Test" -q

test-integration:
	mvn test -Dtest="**/*IT" -q

test-coverage:
	mvn test jacoco:report
	@echo "Coverage report: target/site/jacoco/index.html"

docker-up:
	docker-compose up -d
	@echo "Services started. Use 'make docker-logs' to see logs."

docker-down:
	docker-compose down
	@echo "Services stopped."

docker-up-monitoring:
	docker-compose --profile monitoring up -d

docker-logs:
	docker-compose logs -f

docker-clean:
	docker-compose down -v
	@echo "Services and volumes removed."

lint:
	@echo "Running Java linter..."
	@if command -v checkstyle >/dev/null; then \
		checkstyle -c tools/checkstyle.xml src/; \
	else \
		mvn checkstyle:check; \
	fi
	@echo "Running frontend linter..."
	@if [ -d frontend ]; then cd frontend && npm run lint; fi

format:
	@echo "Formatting Java code..."
	mvn spotless:apply -q
	@echo "Formatting frontend code..."
	@if [ -d frontend ]; then cd frontend && npm run format; fi
	@echo "Formatting complete."

clean:
	mvn clean -q
	@if [ -d frontend ]; then cd frontend && rm -rf dist node_modules/.cache; fi
	@echo "Clean complete."

init:
	./scripts/init-project.sh

dev-env:
	./scripts/setup-dev-env.sh

.DEFAULT_GOAL := help
