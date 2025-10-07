# Ultimate Terragrunt Setup for Serverless Architecture on AWS

This project demonstrates how to build and manage a **serverless architecture on AWS** using **Terragrunt**, **Terraform**, and **GitHub Actions**, following best DevOps practices.
It automates environment provisioning, manages separate states for each module, and includes CI/CD integration with GitHub workflows.

---

## 🧩 Project Overview

This repository shows how to:

- Use **Terragrunt** to manage Terraform modules and state per environment.
- Automate deployments using **GitHub Actions**.
- Structure a **DynamoDB + Lambda + API Gateway** serverless architecture.
- Manage **IAM groups, users, and roles** for least-privilege access.
- Host a small static web app on **GitHub Pages** to consume deployed APIs.

Terraform modules are customized for reusable, environment-aware setups.
For details on the modules, see my article:
👉 [Ultimate Terraform Module for DynamoDB, Lambda, and API Gateway Integration](https://medium.com/@vishnusharma11d00/ultimate-terraform-module-for-dynamodb-lambda-and-api-gateway-integration-a18cee830e30)

---

## ⚙️ Setup Instructions (Quick Summary)

### 1. AWS IAM Setup

Create three IAM groups:

- **Dev** → Deny access to Terraform-tagged resources.
- **ReadOnly** → View all resources (attach `ViewOnlyAccess` + custom policy).
- **DevOps** → Used by Terragrunt/Terraform automation (attach assume-role policy).

Then:

- Create a **role named `Terraform`** with **AdministratorAccess**.
- Create a **user** in the **DevOps** group and generate **Access Keys** for GitHub Actions.

---

### 2. Local Terragrunt Setup

1. Clone the repo.
2. Edit:

   - **`prod/terragrunt.hcl`**

   Update the `state_prefix` with something unique to your setup.

   - **`prod/env.hcl`**

   Update the `env` variable value with something unique for proper state separation and to avoid duplicate resource errors.

3. Go to `prod/` and run:

   ```bash
   terragrunt init
   ```

   Approve creation of the backend (S3 + DynamoDB).

4. Confirm `.terraform/`, `provider.tf`, and `state.tf` are generated (auto-excluded in `.gitignore`).

---

### 3. GitHub Actions Deployment

- Push changes to a feature branch (e.g., `ultimate-dev`).
- Create a PR and merge into `main`.
- The **`deploy.yml`** workflow runs automatically to apply infrastructure.

**GitHub Secrets Required:**

```
ACCOUNT_ID
AWS_REGION
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

These belong to the DevOps IAM user and are stored under the `production` environment in repo settings.

---

### 4. Verifying Resources

- Check AWS Console → Resources should be created as tagged by Terraform.
- Use **ReadOnly users** to inspect resources or invoke Lambda test events safely.

---

### 5. Hosting the Frontend (GitHub Pages)

- Go to **Settings → Pages**.
- Source: `docs` branch → `/docs` directory.
- Save → Wait for GitHub Pages to deploy.

Then, update the **API URLs** (from Terragrunt apply outputs):

- In `index.html`: replace `apiUrl` with the `.../strength-cat` endpoint.
- In `History.html`: replace `apiUrl` with the `.../history` endpoint.

Commit and push changes to redeploy automatically.

---

### 6. Destroy Workflow

- A manual **`destroy.yml`** workflow is provided to safely tear down infrastructure.
- It first runs `terragrunt apply` to refresh outputs, then executes `terragrunt destroy` in the right order.
- Use branch protection to ensure only authorized users can trigger it.

---

## 🧠 Full Guide

For a **complete step-by-step explanation**, detailed IAM setup, dependencies, troubleshooting, and screenshots — visit:

- 📘 **Medium Blog:** [Ultimate Terragrunt Setup for Serverless Architecture on AWS](https://medium.com/@vishnusharma11d00/ultimate-terragrunt-setup-for-serverless-architecture-on-aws-f2c8a335af60)
- 🗒️ **Notion Version (for smoother reading):** [View on Notion](https://ribbon-magazine-fa4.notion.site/Ultimate-Terragrunt-Setup-for-Serverless-Architecture-on-AWS-27fb357ef2658049b29dfe934028dc80?source=copy_link)

---

## 🙏 Acknowledgment

This project was inspired by [Anton Putra’s YouTube video](https://youtu.be/yduHaOj3XMg?si=f0wWYmmd1TFwRENS) — huge thanks to him for his clear and insightful explanation of real-world Terragrunt setups.

---

**Author:** Vishnu Sharma
**GitHub:** [VishnuSharma11D00](https://github.com/VishnuSharma11D00)
