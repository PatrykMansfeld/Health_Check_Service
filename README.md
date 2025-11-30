
# Health Check Service

This project provides a robust, production-style health check microservice built with Python and Flask. The service is designed to be cloud-native, containerized with Docker, and orchestrated using Kubernetes. You can deploy it using either Terraform (Infrastructure as Code) or raw Kubernetes manifests, making it suitable for both learning and real-world scenarios.

The application exposes two endpoints:
- `/health`: Returns a simple health status for readiness/liveness probes.
- `/info`: Returns service metadata and environment information, demonstrating how to inject configuration from Kubernetes ConfigMaps.

The repository includes all necessary files for building, deploying, and testing the service, as well as a CI workflow for automated validation.

---

## 1) Prerequisites & Environment Setup

### Required Tools
- **Docker Desktop** (with Kubernetes enabled): Provides a local container runtime and a single-node Kubernetes cluster for easy development and testing.
- **kubectl**: The Kubernetes CLI for managing cluster resources.
- **Terraform (>= 1.5.0)**: Used for declarative, reproducible infrastructure provisioning.
- **Python 3.x** (optional): For running the app locally outside containers.

### Kubernetes Solution Used
This project uses **Docker Desktop with Kubernetes enabled**. This approach is chosen because:
- It is extremely easy to set up and works on Windows, Mac, and Linux.
- It allows you to build and use local Docker images directly in your cluster, without pushing to a remote registry.
- It provides a realistic Kubernetes environment for development, testing, and learning, closely mirroring production setups.

### Environment Setup Steps
1. **Enable Kubernetes in Docker Desktop** (Settings > Kubernetes > Enable).
2. **Verify your Kubernetes context**:
	```powershell
	kubectl config get-contexts
	kubectl config use-context docker-desktop
	kubectl get nodes
	```
3. **Build the Docker image locally** (so the cluster can access it):
	```powershell
	docker build -t health-check-service:latest .
	```
4. **(Optional) Install Terraform** if you want to use IaC for deployment.

---

## 2) Deployment Instructions

You can deploy the service in two ways, depending on your workflow and preference:

### Option A: Deploy with Terraform
Terraform automates the creation of all Kubernetes resources, ensuring repeatability and easy teardown.

**Steps:**
```powershell
Push-Location terraform
terraform init
terraform apply -auto-approve
Pop-Location
```

**Resources created:**
- **ConfigMap**: Injects the `APP_ENV=production` environment variable into the container.
- **Deployment**: Runs 2 replicas of the Flask app for high availability.
- **NodePort Service**: Exposes the app on port `30080` of your host, mapping to container port `8080`.

**To destroy everything:**
```powershell
Push-Location terraform
terraform destroy -auto-approve
Pop-Location
```

### Option B: Deploy with Kubernetes Manifests
This approach is ideal for quick iteration and direct control over resource definitions.

**Steps:**
```powershell
kubectl apply -f k8s/
```

**To remove all resources:**
```powershell
kubectl delete -f k8s/
```

Both methods will result in a running service accessible at `http://localhost:30080/health` and `/info`.

---

## 3) Testing Commands

Once deployed, you can verify the service and inspect its behavior using the following commands:

### Check Kubernetes Resources
```powershell
kubectl get pods -l app=health-check-service
kubectl get svc health-check-service
```
You should see two running pods and a NodePort service exposing port 30080.

### Test Endpoints from Host
Use PowerShell to query the endpoints:
```powershell
Invoke-WebRequest -Uri http://localhost:30080/health -UseBasicParsing | Select-Object -Expand Content
Invoke-WebRequest -Uri http://localhost:30080/info -UseBasicParsing | Select-Object -Expand Content
```
**Expected output:**
- `/health` → `{ "status": "healthy" }`
- `/info` → `{ "service": "hello-service", "environment": "production" }`

### Inspect Application Logs
```powershell
kubectl logs -l app=health-check-service --tail=100
```
This helps you debug and monitor the service in real time.

### (Optional) Port-forward for direct access
If you prefer not to use NodePort, you can forward the service port:
```powershell
kubectl port-forward svc/health-check-service 8080:8080
# Then browse http://localhost:8080/health and /info
```

### Troubleshooting
- If endpoints do not respond, check pod status and logs for errors.
- Ensure your Docker image is built and available locally before applying manifests.

---

## 4) Brief Explanation & Trade-offs

### Approach
This project demonstrates a modern, cloud-native workflow for microservices:
- The Flask app is designed for health checking and service introspection, following best practices for containerized workloads.
- Configuration is injected via Kubernetes ConfigMaps, showing how to externalize environment-specific settings.
- Both Terraform and raw manifests are provided, allowing you to choose between declarative IaC or direct resource management.

### Trade-offs
- **Terraform**: Great for reproducibility, version control, and easy teardown. Adds complexity and requires provider setup/state management.
- **Raw Manifests**: Simple, fast, and flexible for development. Less suitable for large-scale or production environments due to lack of drift detection and automation.
- **Docker Desktop Kubernetes**: Perfect for local dev and learning, but not identical to cloud clusters (networking, scaling, security).

### Result
You get a fully working health check service, ready for local development, CI/CD, and easy migration to cloud platforms. The project is modular, extensible, and demonstrates real-world deployment patterns.

---

## (Optional) Local Run Without Kubernetes

You can run the Flask app locally for rapid development and debugging:
```powershell
python -m venv .venv; .\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
$env:APP_ENV = "development"
python app.py
```
Then visit:
- http://localhost:8080/health
- http://localhost:8080/info

This mode is ideal for quick code changes, unit testing, or exploring the API before containerization.

---

## 1) Prerequisites & Environment Setup

- Docker Desktop (with Kubernetes enabled)
- kubectl
- Terraform >= 1.5.0
- Python 3.x (optional, for local run)

- Kubernetes solution used: Docker Desktop with Kubernetes enabled.
- Why this choice: It provides a fast, local, single‑node cluster integrated with Docker, ideal for demos and quick iteration.

Verify your Kubernetes context:

```powershell
kubectl config get-contexts
kubectl config use-context docker-desktop
kubectl get nodes
```

Build the image locally (used by manifests and Terraform on Docker Desktop):

```powershell
# From repo root
docker build -t health-check-service:latest .
```

---

## 2) Deployment Instructions

You can deploy using either Terraform or Kubernetes manifests.

### A. Terraform

```powershell
# From repo root
Push-Location terraform
terraform init
terraform apply -auto-approve
Pop-Location
```

What it creates:

- ConfigMap with `APP_ENV=production`
- Deployment with 2 replicas
- NodePort Service on port `30080` (target `8080`)

Destroy:

```powershell
Push-Location terraform
terraform destroy -auto-approve
Pop-Location
```

### B. Kubernetes Manifests

```powershell
# From repo root
kubectl apply -f k8s/
```

Delete:

```powershell
kubectl delete -f k8s/
```

---

## 3) Testing Commands

Check resources:

```powershell
kubectl get pods -l app=health-check-service
kubectl get svc health-check-service
```

Hit endpoints (PowerShell):

```powershell
Invoke-WebRequest -Uri http://localhost:30080/health -UseBasicParsing | Select-Object -Expand Content
Invoke-WebRequest -Uri http://localhost:30080/info -UseBasicParsing | Select-Object -Expand Content
```

Expected responses:

- `/health` → `{ "status": "OK" }`
- `/info` → `{ "service": "Hello Service", "environment": "production" }`

View logs:

```powershell
kubectl logs -l app=health-check-service --tail=100
```

Optional port-forward (alternative to NodePort):

```powershell
kubectl port-forward svc/health-check-service 8080:8080
# Then browse http://localhost:8080/health and /info
```

---

## 4) Brief Explanation & Trade-offs

- Approach: A small Flask app (`app.py`) exposes `/health` and `/info`. The container listens on `8080`. `APP_ENV` is injected via a Kubernetes ConfigMap; Terraform and raw manifests both provision the same resources.
- Trade-offs: Terraform adds state and provider setup but ensures reproducibility and drift detection; raw manifests are simpler and faster for iteration. Docker Desktop’s Kubernetes is convenient for local testing but differs from production clusters and networking models.
- Result: A clean, reproducible deployment with simple verification commands and clear local‑dev escape hatches (port-forward or direct local run).

---

## (Optional) Local Run Without Kubernetes

```powershell
python -m venv .venv; .\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
$env:APP_ENV = "development"
python app.py
# Visit: http://localhost:8080/health and http://localhost:8080/info
```

