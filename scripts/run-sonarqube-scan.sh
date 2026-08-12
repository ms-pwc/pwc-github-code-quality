#!/bin/bash

# Run SonarQube scan against local or remote SonarQube instance

set -e

SONAR_HOST_URL="${SONAR_HOST_URL:-http://localhost:9000}"
SONAR_LOGIN="${SONAR_LOGIN}"

if [ -z "$SONAR_LOGIN" ]; then
  echo "Error: SONAR_LOGIN environment variable is not set"
  echo "Usage: SONAR_LOGIN=<token> ./scripts/run-sonarqube-scan.sh"
  exit 1
fi

echo "Running SonarQube scan..."
echo "SonarQube Host: $SONAR_HOST_URL"

dotnet restore Pwc.GitHubCodeQuality.slnx

dotnet sonarscanner begin \
  /k:"pwc-github-code-quality" \
  /n:"PWC GitHub Code Quality" \
  /d:sonar.host.url="$SONAR_HOST_URL" \
  /d:sonar.login="$SONAR_LOGIN"

dotnet build Pwc.GitHubCodeQuality.slnx --configuration Release --no-restore

dotnet sonarscanner end /d:sonar.login="$SONAR_LOGIN"

echo ""
echo "Scan completed! View results at: $SONAR_HOST_URL"
echo ""
