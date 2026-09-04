# Azure CLI Setup Guide

## Step 1: Install Azure CLI

### Windows
```powershell
# Download and install
# Visit: https://aka.ms/azurecli
# Or use Chocolatey:
choco install azure-cli
```

### macOS
```bash
brew install azure-cli
```

### Linux
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

---

## Step 2: Login to Azure

```bash
az login
```

**A browser will open automatically.**
- Sign in with: **erickim555@msn.com**
- Accept permissions
- Close browser when done

---

## Step 3: Get Your Subscription ID

```bash
az account list --output table
```

**Copy the Subscription ID from the output**

---

## Step 4: Set Default Subscription

```bash
az account set --subscription "YOUR-SUBSCRIPTION-ID"
```

---

## Step 5: Verify Setup

```bash
az account show
```

You should see your subscription info.

---

## NEXT: Provide Subscription ID

Once you have it, reply with:
```
Azure Subscription ID: [your-id-here]
```

Then we proceed with GitHub Actions automation.

🔺
