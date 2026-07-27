# Secrets Management Guide

## Rules
- Do not commit plaintext secrets to the repository.
- Store CI/CD secrets in GitHub repository settings.
- Use environment variables for local development.

## Required Secret Scopes
- `SONAR_TOKEN` for optional SonarQube analysis
- cloud/service credentials per environment (dev/staging/prod)
