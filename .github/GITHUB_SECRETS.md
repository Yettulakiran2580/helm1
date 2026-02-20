# GitHub Secrets Configuration for AKS + Helm + ArgoCD CI/CD

## Required GitHub Secrets

This CI/CD pipeline requires the following GitHub Secrets to be configured in your repository settings.

### 1. Azure Container Registry (ACR) Credentials

#### `ACR_LOGIN_SERVER`
- **Description**: The login server URL of your Azure Container Registry
- **Example**: `myacr.azurecr.io`
- **How to find**: 
  ```bash
  az acr list --resource-group <YOUR_RESOURCE_GROUP> --query "[].loginServer" -o tsv
  ```

#### `ACR_USERNAME`
- **Description**: Username for Azure Container Registry authentication
- **How to create**:
  ```bash
  # Enable admin user on ACR
  az acr update -n <ACR_NAME> --admin-enabled true
  
  # Get the username (it's usually the ACR name)
  az acr credential show -n <ACR_NAME> --query "username" -o tsv
  ```

#### `ACR_PASSWORD`
- **Description**: Password for Azure Container Registry authentication
- **How to get**:
  ```bash
  az acr credential show -n <ACR_NAME> --query "passwords[0].value" -o tsv
  ```

### 2. How to Add Secrets to GitHub

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret:
   - Name: `ACR_LOGIN_SERVER` | Value: Your ACR login server
   - Name: `ACR_USERNAME` | Value: Your ACR username
   - Name: `ACR_PASSWORD` | Value: Your ACR password

### 3. Workflow Permissions Required

Ensure your repository has the required permissions:
1. Go to **Settings** → **Actions** → **General**
2. Under "Workflow permissions", select:
   - ✅ **Read and write permissions**
   - ✅ **Allow GitHub Actions to create and approve pull requests**

This is needed for the workflow to commit changes back to the repository.

### 4. Azure Prerequisites

Ensure you have:
- ✅ Azure Container Registry (ACR) created
- ✅ Azure Kubernetes Service (AKS) cluster
- ✅ ArgoCD installed on your AKS cluster
- ✅ ACR admin user enabled

### 5. Example: Create ACR and Get Credentials

```bash
# Create Resource Group
az group create --name my-rg --location eastus

# Create ACR
az acr create --resource-group my-rg --name myacr --sku Basic

# Enable admin user
az acr update -n myacr --admin-enabled true

# Get credentials
az acr credential show -n myacr
```

### 6. ArgoCD Configuration

Once secrets are configured, ensure ArgoCD is set up to:
1. Monitor your repository for changes
2. Automatically sync when `values.yaml` is updated
3. Detect the updated image tag and deploy to AKS

Example ArgoCD Application manifest:
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

---

## Workflow Overview

The CI/CD pipeline performs these steps:

1. **Checkout**: Pulls your repository code
2. **CodeQL SAST Scan**: Security analysis on Python code
3. **Build Docker Image**: Creates container image with the commit SHA as tag
4. **Push to ACR**: Authenticates and pushes image to Azure Container Registry
5. **Update values.yaml**: Automatically updates Helm chart with new image tag
6. **Commit Changes**: Pushes updated values.yaml back to main branch
7. **ArgoCD Auto-Sync**: ArgoCD detects changes and deploys to AKS cluster

## Troubleshooting

### Secret Not Found
- Verify secret names are exactly as specified above (case-sensitive)
- Check that secrets are in the correct repository (not organization level)

### ACR Login Failed
- Verify ACR admin user is enabled
- Confirm username and password are correct
- Check ACR exists and is accessible from GitHub

### Commit Push Failed
- Ensure workflow permissions include "Read and write permissions"
- Verify GitHub token has proper scopes

---

For more information, see:
- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
