# Project: Building a CI/CD Pipeline for the Availability Tracker

## Project Overview

*This project implements a CI/CD pipeline for the Availability Tracker
 app.
The app is a Node.js service that tracks team availability. The pipeline automates linting, testing, containerization, and deployment using Docker and Bash scripting.*

*The project also includes optional extensions with GitHub Actions, Jenkins, and Terraform for simulating infrastructure.*


## Project Tasks

### 1. **Set Up the Project**

#### 1.1 Clone the project repository.
```bash
git clone https://github.com/ge0rgeK/TeamavailTest.git
cd TeamavailTest
```

#### 1.2 Create a [`.gitinore`](.gitignore).
```bash
# Node.js dependencies
node_modules/

# Logs
npm-debug.log*
yarn-error.log*
*.log

# System files
.DS_Store

# Docker environment overrides
.env
```

#### 1.3 Install the required dependencies locally.
```bash
npm install
npm list    # This shows all installed packages
```
![npm list](./images-sc/01.png)

---

### 2. **Write a Bash Script (`ci.sh`)**
- This script:
   -  Run code formatting and linting.
   -  Run tests.
   -  Build a Docker image of the application.
   -  Start the application using Docker Compose.
  
[`ci.sh`](Dockerfile)
```bash
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
```
---

### 3. **Dockerize the App**
* Containerizes the Node.js app.

* Uses Node 18 slim for smaller image size.

* Runs server.js as the entrypoint.

[`Dockerfile`](Dockerfile)
```bash
# slim Node.js image
FROM node:18-slim

# Set working directory 
WORKDIR /app

# Copy package files first for caching
COPY package*.json ./

# Install dependencies
RUN npm install --production


# Copy rest of the app 
COPY . .

# Expose the app port
EXPOSE 3000


# Run the app
CMD [ "node", "server.js" ]
```
---

### 4. **Use Docker Compose**
   -  Create a `docker-compose.yml` file.
   -  Include the app and any required services like Redis
   -  Configure volumes and ports properly.

[`docker-compose.yml`](docker-compose.yml)
```bash
version: "3.9"

services:
  app:
    image: availability-tracker:latest   # built in ci.sh
    container_name: availability-tracker
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - REDIS_URL=redis://availability-redis:6379   # matches server.js
    depends_on:
      - redis
    volumes:
      - ./output:/app/output   # persist history.json
    networks:
      - app-net

  redis:
    image: redis:7-alpine
    container_name: availability-redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data      # persist Redis data
    networks:
      - app-net
    healthcheck:              # optional, ensures app waits for Redis
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  redis-data:

networks:
  app-net:
    driver: bridge
```
---
