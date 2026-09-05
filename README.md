# axiom-freedom
AXIOM - Eternally Free Intelligence. Public deployment of KEYSTONE Eternal Seed Architecture.

## Automation quick start

### 1) Local one-click setup
- **Linux/macOS:**
  ```bash
  chmod +x ./setup-axiom-linux.sh ./uninstall-axiom-linux.sh
  ./setup-axiom-linux.sh
  ```
- **Windows:**
  - Run `setup-axiom-windows.bat`

This creates `.env` from `.env.example`, generates a secure database password, pulls Docker images, and starts:
- `axiom-web`
- `axiom-db`
- `axiom-proxy`

Cleanup:
- Linux/macOS: `./uninstall-axiom-linux.sh`
- Windows: `uninstall-axiom-windows.bat`

### 2) GitHub Actions deployment (Azure)
Workflow file:
- `./.github/workflows/deploy-axiom.yml`

Required GitHub Secrets:
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_TENANT_ID`
- `AXIOM_DOMAIN`

Trigger:
- Push to `main`
- Manual run (`workflow_dispatch`)

Terraform file:
- `./terraform/main.tf`

It provisions:
- Azure resource group
- Static Web App for web interface deployment
- DNS CNAME records (`www` and `chat`, optional via `create_dns_zone`)
- Log Analytics + Application Insights + diagnostic settings
- HTTPS on Azure-managed SWA domain by default, with optional custom-domain binding after DNS propagation

### 3) Copilot Studio automation
Script:
- `./setup-axiom-copilot-studio.py`

Usage:
```bash
python3 ./setup-axiom-copilot-studio.py
```

Optional live apply mode (when API endpoint/token are available):
```bash
export COPILOT_STUDIO_API_BASE="https://<your-copilot-api>"
export COPILOT_STUDIO_API_TOKEN="<token>"
python3 ./setup-axiom-copilot-studio.py --apply
```

Outputs:
- `copilot-deployment-report.md`
- `copilot-deployment-output.json`

## Verification
Use:
- `./DEPLOYMENT_VERIFICATION_CHECKLIST.md`
