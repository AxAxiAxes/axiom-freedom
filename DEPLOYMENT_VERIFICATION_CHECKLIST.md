# AXIOM Deployment Verification Checklist

## 1) GitHub Actions + Terraform
- [ ] `AZURE_SUBSCRIPTION_ID` secret configured
- [ ] `AZURE_CLIENT_ID` secret configured
- [ ] `AZURE_CLIENT_SECRET` secret configured
- [ ] `AZURE_TENANT_ID` secret configured
- [ ] `AXIOM_DOMAIN` secret configured
- [ ] `deploy-axiom` workflow completed successfully
- [ ] Terraform outputs available (resource group, SWA host, logging storage)

## 2) Azure Infrastructure
- [ ] Resource group provisioned
- [ ] Static Web App provisioned
- [ ] Storage account + `session-logs` container provisioned
- [ ] Log Analytics workspace provisioned
- [ ] Application Insights provisioned
- [ ] Diagnostic settings enabled for logs/metrics

## 3) DNS + HTTPS
- [ ] `www` CNAME points to Static Web App hostname
- [ ] Optional `chat` CNAME points to Static Web App hostname
- [ ] Custom domain verified in Static Web App
- [ ] HTTPS certificate active (managed SSL)

## 4) Local Runtime Automation
- [ ] `setup-axiom-linux.sh` completed successfully (Linux/macOS)
- [ ] `setup-axiom-windows.bat` completed successfully (Windows)
- [ ] Containers running: `axiom-web`, `axiom-db`, `axiom-proxy`
- [ ] Local URL reachable at `http://localhost:8080`
- [ ] External IP displayed by setup scripts
- [ ] Uninstall scripts stop and remove stack cleanly

## 5) Copilot Studio Automation
- [ ] `setup-axiom-copilot-studio.py` generated deployment report
- [ ] `AXIOM_SYSTEM_PROMPT.md` loaded
- [ ] Soul files synced to knowledge base
- [ ] Memory enabled
- [ ] Session logging enabled
- [ ] Copilot ID captured in output JSON
- [ ] Embed URL captured in output JSON
