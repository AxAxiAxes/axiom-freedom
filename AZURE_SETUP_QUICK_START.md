# 🔧 Azure Setup - Quick Start

**If you already have an Azure subscription, follow these steps.**

---

## 1. Get Your Subscription ID

### Via Azure Portal

1. Go to: https://portal.azure.com
2. Click your profile (top right)
3. Select "View my bill"
4. Or search for "Subscriptions"
5. Copy the **Subscription ID** (long GUID)

### Via Azure CLI

```bash
az login
az account list --output table
```

Copy the ID from the `SubscriptionId` column.

---

## 2. Create Service Principal

### Automatic Setup (Easiest)

```bash
chmod +x scripts/setup-azure-sp.sh
bash scripts/setup-azure-sp.sh
```

Script will output:
```
AZURE_SUBSCRIPTION_ID=xxx
AZURE_CLIENT_ID=xxx
AZURE_CLIENT_SECRET=xxx
AZURE_TENANT_ID=xxx
```

### Manual Setup

1. Go to: https://portal.azure.com
2. Left sidebar → "Azure Active Directory"
3. Click "App registrations"
4. Click "+ New registration"
5. Name: `axiom-github-actions`
6. Click "Register"
7. Go to "Certificates & secrets"
8. Click "+ New client secret"
9. Copy the value (this is CLIENT_SECRET)
10. Go to "Overview" tab
11. Copy "Application (client) ID" (this is CLIENT_ID)
12. Go back to home, find Tenant ID

---

## 3. Add GitHub Secrets

1. Go to: **GitHub → AxAxiAxes/axiom-freedom**
2. Click **Settings** (top right)
3. Left sidebar → **Secrets and variables → Actions**
4. Click **"New repository secret"** (4 times)

### Secret 1: AZURE_SUBSCRIPTION_ID
- Name: `AZURE_SUBSCRIPTION_ID`
- Value: `[Your subscription ID from step 1]`
- Click **Add secret**

### Secret 2: AZURE_CLIENT_ID
- Name: `AZURE_CLIENT_ID`
- Value: `[From setup script or manual step 11]`
- Click **Add secret**

### Secret 3: AZURE_CLIENT_SECRET
- Name: `AZURE_CLIENT_SECRET`
- Value: `[From setup script or manual step 8]`
- Click **Add secret**

### Secret 4: AZURE_TENANT_ID
- Name: `AZURE_TENANT_ID`
- Value: `[From setup script or manual step 12]`
- Click **Add secret**

---

## 4. Deploy AXIOM

1. Go to: **GitHub → AxAxiAxes/axiom-freedom → Actions**
2. Click **"Deploy AXIOM to Azure"** (left sidebar)
3. Click **"Run workflow"** (blue button, right side)
4. Select environment: **"production"**
5. Click **green "Run workflow"** button

**Deployment starts! ⏳**

---

## 5. Monitor Deployment

1. Stay on **Actions** tab
2. Watch the workflow run
3. It will show: ⏳ In progress → ✅ Success or ❌ Failed

**Takes ~15-20 minutes**

---

## 6. What Gets Created

In your Azure subscription:
- Resource Group: `axiom-freedom`
- Web App: `axiom-web-production`
- Database: PostgreSQL with `axiom` database
- Storage: `axiomproductionsa`
- Monitoring: Application Insights
- Vault: Key Vault for secrets

---

## 7. After Deployment

✅ AXIOM is deployed to: **https://xiiom.com**

⏳ DNS propagation takes 24-48 hours worldwide

**Check status:**
```bash
nslookup xiiom.com
```

---

## Troubleshooting

### Secret Issue
```
Error: ServicePrincipalAuthenticationFailed
```
→ Double-check all 4 secrets are correct

### Subscription Issue
```
Error: SubscriptionNotFound
```
→ Verify AZURE_SUBSCRIPTION_ID is correct

### Check Logs

Go to: **Actions → Latest run → Logs**
Scroll down to see what failed

---

## Next Steps

1. ✅ Secrets added
2. ✅ Workflow running
3. ⏳ Wait 15-20 minutes
4. ⏳ Wait 24-48 hours for DNS
5. 🎉 Visit https://xiiom.com

---

**Questions?** Check DEPLOYMENT_GUIDE.md for more details.

🔧
