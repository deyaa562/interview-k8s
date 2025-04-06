#!/bin/bash
set -e

# Allow user to override the port (default 8080)
LOCAL_PORT="${1:-8080}"

APP_NAME="my-petclinic"
CHART_PATH="./petclinic-chart"
DOCKER_IMAGE="spring-petclinic:latest"

echo "Starting deployment..."

# Show Kubernetes context
echo "Current Kubernetes context:"
kubectl config current-context

# 1. Build Docker image
echo "Building Docker image..."
docker build -t $DOCKER_IMAGE .

# 2. Install or upgrade the Helm release
echo "Installing Helm chart..."
helm upgrade --install $APP_NAME $CHART_PATH

# 3. Wait for rollout to complete
echo "Waiting for app to be ready..."
kubectl rollout status deployment/$APP_NAME

# 4. Port forward
echo "Access the app at http://localhost:$LOCAL_PORT"
kubectl port-forward svc/$APP_NAME $LOCAL_PORT:8080
