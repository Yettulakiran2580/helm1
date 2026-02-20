# CI/CD Setup Guide for AKS + Helm + ArgoCD

## 📋 Overview

Your repository is now configured for automated CI/CD deployment using:
- **GitHub Actions**: Orchestrates the entire pipeline
- **CodeQL**: Security scanning (SAST)
- **Docker**: Container image building
- **Azure Container Registry (ACR)**: Image registry
- **Helm**: Kubernetes deployment configuration
- **ArgoCD**: GitOps-based deployment automation

---

## 🚀 Quick Start

### Step 1: Configure Azure Container Registry (ACR)

If you don't have an ACR, create one:

```bash
# Set variables
ACR_NAME="myacr"
RESOURCE_GROUP="my-resource-group"
LOCATION="eastus"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create ACR
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true

# Get login server
az acr show --name $ACR_NAME --query loginServer --output tsv
```

### Step 2: Add GitHub Secrets

Add the following secrets to your GitHub repository (**Settings → Secrets and variables → Actions**):

1. **ACR_LOGIN_SERVER**
   ```
   yourname.azurecr.io
   ```

2. **ACR_USERNAME**
   ```bash
   az acr credential show --name myacr --query "username" -o tsv
   ```

3. **ACR_PASSWORD**
   ```bash
   az acr credential show --name myacr --query "passwords[0].value" -o tsv
   ```

### Step 3: Enable Workflow Permissions

1. Go to **Settings → Actions → General**
2. Under "Workflow permissions":
   - ✅ Select **Read and write permissions**
   - ✅ Check **Allow GitHub Actions to create and approve pull requests**

### Step 4: Install ArgoCD on AKS

```bash
# Create argocd namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Get ArgoCD password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### Step 5: Create ArgoCD Application

Create an ArgoCD Application to monitor your repository:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: python-project
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/YOUR_USERNAME/helm1
    targetRevision: main
    path: python-project-chart
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Apply it:
```bash
kubectl apply -f argocd-application.yaml
```

---

## 📁 Generated Files

### 1. `.github/workflows/aks-helm-argocd-ci-cd.yaml`
   - **Purpose**: Main CI/CD workflow
   - **Triggers**: On push to main branch or pull request
   - **Jobs**:
     - `security-scan`: CodeQL SAST analysis
     - `build-and-push`: Build Docker image
     - `push-and-update`: Push to ACR and update Helm values

### 2. `Dockerfile`
   - Multi-stage build for optimized image size
   - Uses Python 3.11 slim base image
   - Installs dependencies from requirements.txt
   - Exposes port 5000 (Flask default)
   - Includes health check

### 3. `.github/GITHUB_SECRETS.md`
   - Detailed instructions for configuring secrets
   - Azure CLI commands to retrieve credentials
   - Troubleshooting guide

### 4. `.github/workflows/` directory
   - Created for GitHub Actions workflow files

### 5. `.gitignore`
   - Excludes Python runtime files, IDE configs, and build artifacts

---

## 🔄 Workflow Pipeline Execution

### When triggered (on push to main):

1. **Checkout** → Retrieves your repository code
2. **CodeQL SAST Scan** → Analyzes Python code for security vulnerabilities
3. **Build Docker Image** → Creates container image with tag `<commit_sha>`
4. **Push to ACR** → Authenticates with Azure and uploads image
5. **Update Helm values.yaml** → Modifies image tag in the Helm chart
6. **Commit Changes** → Pushes updated values.yaml back to main
7. **ArgoCD Sync** → Automatically detects changes and deploys to AKS

---

## 🔐 Security Features

✅ **CodeQL SAST**: Automated security scanning on every push
✅ **ACR Authentication**: Secure Docker registry with credentials
✅ **GitHub Secrets**: Encrypted credential storage
✅ **Commit Signing**: Git commits can be verified
✅ **ArgoCD RBAC**: Kubernetes role-based access control

---

## 🧪 Testing the Pipeline

### Option 1: Push to Main Branch
```bash
git add .
git commit -m "feat: add CI/CD pipeline"
git push origin main
```

Monitor the workflow in **Actions** tab.

### Option 2: Create a Pull Request
```bash
git checkout -b feature/test-pipeline
echo "# Test" >> README.md
git add README.md
git commit -m "test: verify pipeline"
git push origin feature/test-pipeline
```

Go to GitHub and create a PR. CodeQL will run automatically.

---

## 📊 Monitoring

### GitHub Actions Dashboard
- Go to **Actions** tab to see workflow runs
- View logs, artifacts, and security scan results
- Download artifacts (Docker images)

### ArgoCD Dashboard
```bash
# Port forward ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access at https://localhost:8080
```

### Azure Portal
- Monitor ACR for pushed images
- View container registry statistics

---

## 🛠️ Customization

### Modify Image Registry
Edit `.github/workflows/aks-helm-argocd-ci-cd.yaml`:
```yaml
env:
  IMAGE_NAME: python-project  # Change this
  IMAGE_TAG: ${{ github.sha }}
```

### Change Target Branch
Modify trigger in workflow:
```yaml
on:
  push:
    branches:
      - main      # Change to your branch
```

### Add Additional SAST Scans
Extend CodeQL or add other tools:
```yaml
- name: Run additional security scan
  run: |
    # Your custom scan command
```

---

## 🐛 Troubleshooting

### "ACR Login Failed"
- Verify secret values in GitHub
- Check ACR admin is enabled: `az acr update -n myacr --admin-enabled true`
- Confirm login server URL matches secrets

### "Commit Push Failed"
- Go to **Settings → Actions → General**
- Enable "Read and write permissions"
- Check default branch is `main`

### "CodeQL Scan Timeout"
- Increase timeout in workflow
- Reduce code complexity or add code exclusions

### "Image Not Appearing in ACR"
- Check ACR login server in secrets
- Verify Docker login credentials work locally
- Review workflow logs for details

---

## 📚 References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [CodeQL Documentation](https://codeql.github.com/docs/)
- [Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/)
- [Helm Documentation](https://helm.sh/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---

## ✅ Checklist

- [ ] ACR created and admin enabled
- [ ] GitHub secrets configured (ACR_LOGIN_SERVER, ACR_USERNAME, ACR_PASSWORD)
- [ ] Workflow permissions enabled
- [ ] AKS cluster running
- [ ] ArgoCD installed on AKS
- [ ] ArgoCD Application pointing to your repository
- [ ] Test push to main branch
- [ ] Verify image appears in ACR
- [ ] Verify Helm values.yaml updated
- [ ] Verify ArgoCD syncs and deployment appears

---

**Your CI/CD pipeline is ready! 🎉**
