# Petclinic Helm Chart

This Helm chart deploys the Spring Petclinic application with a PostgreSQL database onto a local Kubernetes cluster (Minikube/kind).

## Features
- Spring Boot app deployed as a `Deployment`
- PostgreSQL database as a `StatefulSet`
- Secrets for DB credentials
- ConfigMap for DB config
- Internal `ClusterIP` services for app and DB
- Optional Ingress setup ([see how to enable ➜](#enabling-ingress-access))

## Requirements

To run this project locally, make sure you have the following tools installed:

- [Docker](https://www.docker.com/) – for building the application image
- [kubectl](https://kubernetes.io/docs/tasks/tools/) – Kubernetes CLI
- [Helm](https://helm.sh/) – for managing Helm charts
- A local Kubernetes cluster (any of the following):
- [Minikube](https://minikube.sigs.k8s.io/docs/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) with Kubernetes enabled

Optional for Windows users:
- [WSL2](https://learn.microsoft.com/en-us/windows/wsl/) or [Git Bash](https://gitforwindows.org/) – to run the `deploy.sh` script

---

### ✅ **Quick checklist**:

- [ ] Docker is installed and running  
- [ ] Kubernetes cluster is up (Minikube, Docker Desktop, etc.)  
- [ ] `kubectl` is installed and configured  
- [ ] `helm` is installed  


## DB Credentials (Important!)
This chart uses a Kubernetes `Secret` to store the database credentials.

By default, credentials are defined in `values.yaml`. You can customize them directly in that file:

```yaml
database:
username: petclinic
password: petclinic
```

## Installation

There are two ways to install this chart locally:

### Option 1: Manual Steps

1. Make sure your local K8s cluster is running (e.g. Minikube or Docker Desktop).

2. (Optional) Verify you're using the correct Kubernetes context:
```bash
kubectl config current-context
kubectl config use-context docker-desktop  # or minikube
```

3. Build the Docker image locally:
```bash
docker build -t spring-petclinic:latest .
```

4. Deploy with Helm:
```bash
helm upgrade --install my-petclinic .
```

5. Optionally enable ingress in `values.yaml` and add a local DNS entry for `petclinic.local`. ([see how to enable ➜](#enabling-ingress-access))

### Option 2: One-Step Script
💡 Note: `deploy.sh` is a Unix shell script and requires a Unix-compatible environment (Linux, macOS, or WSL on Windows).

You can use the provided `deploy.sh` script to automate the full setup:

```bash
./deploy.sh [custom-port]
```

- If no port is specified, the script defaults to `8080`
- You can run `./deploy.sh 9090` to use port `9090` instead

This script builds the Docker image, installs the Helm chart, and port-forwards the app.

## Verify
- Check Pods:
```bash
kubectl get pods
```
- Port forward to access app (if not using `deploy.sh`):
```bash
kubectl port-forward svc/my-petclinic 8080:8080
open http://localhost:8080
```

## Enabling Ingress Access

1. **Update `values.yaml`** to enable ingress:

```yaml
ingress:
enabled: true
className: nginx
annotations:
nginx.ingress.kubernetes.io/rewrite-target: /
hosts:
- host: petclinic.local
    paths:
    - path: /
        pathType: Prefix
tls: []
```

2. **Enable ingress controller**:
- On Minikube:
    ```bash
    minikube addons enable ingress
    ```
- On Docker Desktop: Enable Kubernetes ingress in settings.

3. **Add a local DNS entry**:
- **Linux/macOS**: Edit `/etc/hosts`
    ```
    127.0.0.1 petclinic.local
    ```
- **Windows**: Edit `C:\Windows\System32\drivers\etc\hosts` as Administrator:
    ```
    127.0.0.1 petclinic.local
    ```

4. **Access your app**:
```
http://petclinic.local
```
