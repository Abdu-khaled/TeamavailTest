#!/bin/bash

set -euo pipefail

APP_NAME="availability-tracker"
TAG="latest"

echo "Running lint checks..."
if ! npx eslint .; then
  echo "ESLint issues found!"
fi

if ! npx prettier --check .; then
  echo "Prettier formatting issues found!"
fi

echo "Running tests..."
if npm run | grep -q "test"; then 
  npm install
  npm test
else
  echo "No test script found!!"
fi 


echo " Building Docker image..."
docker build \
  --cache-from=$APP_NAME:$TAG \
  -t $APP_NAME:$TAG .


echo "Starting application with Docker Compose..."

docker compose down || true
docker compose up -d --build 

echo "CI pipeline completed successfully!"
