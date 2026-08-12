#!/bin/bash

# Setup local SonarQube with Docker Compose
# This script starts a local SonarQube instance for development and testing

set -e

echo "Starting local SonarQube server..."
docker-compose up -d

echo ""
echo "Waiting for SonarQube to be ready..."

# Wait for SonarQube to be healthy
for i in {1..60}; do
  if curl -s http://localhost:9000/api/system/health > /dev/null 2>&1; then
    echo "SonarQube is ready!"
    break
  fi
  if [ $i -eq 60 ]; then
    echo "SonarQube failed to start within 60 seconds"
    exit 1
  fi
  echo "Waiting... ($i/60)"
  sleep 1
done

echo ""
echo "========================================"
echo "SonarQube Server Started Successfully!"
echo "========================================"
echo ""
echo "Access SonarQube at: http://localhost:9000"
echo "Default credentials:"
echo "  Username: admin"
echo "  Password: admin"
echo ""
echo "Next steps:"
echo "1. Login with admin/admin"
echo "2. Generate a token: Administration > Security > Users > Tokens"
echo "3. Set the SONAR_LOGIN secret/variable in your CI/CD"
echo "4. Run: scripts/run-sonarqube-scan.sh"
echo ""
echo "To stop SonarQube:"
echo "  docker-compose down"
echo ""
