# CronJob for Data Monitoring Alerts

This project sets up a Kubernetes CronJob to monitor data and trigger alerts using Grafana and Prometheus. It ensures that any issues with data monitoring are promptly flagged.

## Prerequisites

1. Minikube installed and running.
2. Helm for managing Kubernetes applications.
3. Docker for building and pushing images.

### Setup Instructions

#### Step 1: Start Minikube
Ensure Minikube is up and running:

```
minikube start
```

#### Step 2: Install Grafana and Prometheus
1. Update Helm dependencies:
```
helm dependency update
```
2. Install the monitoring stack (Grafana and Prometheus):
```
helm install my-monitoring .
```
3. Retrieve the local Grafana URL:
```
minikube service my-monitoring-grafana --url
```

#### Step 3: Set Up the CronJob
1. Upgrade or install the CronJob for monitoring:
```
helm upgrade --install grafana-cronjob .
```

#### Step 4: Build and Push Docker Image
1. Build the Docker image:
```
docker build -t tortelloste/curl-jq:latest .
```
2. Push the image to Docker Hub:
```
docker push tortelloste/curl-jq:latest
```
3. Run the Docker container for testing:
```
docker run -it tortelloste/curl-jq:latest /bin/sh
```

#### Step 5: Enable Metrics Server (optional)
Enable the metrics server on Minikube for resource monitoring:
```
minikube addons enable metrics-server
```

### Additional Utilities
- List available Docker images:
```
docker images
```
- Configure Docker to use Minikube's environment:
```
eval $(minikube docker-env)
```