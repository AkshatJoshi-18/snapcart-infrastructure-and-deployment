# Contributing to SnapCart Infrastructure

Welcome to the SnapCart Infrastructure repository!

We follow a Trunk-Based Development model to ensure high availability and rapid iteration. This document outlines the standards for contributing code, managing environments, and promoting changes to production.

## 🛠 Prerequisites

Ensure you have the following tools installed and configured:

- Terraform (v1.5+)
- Ansible (v2.10+)
- AWS CLI (Run `aws configure` before starting)
- Git (Configured with your name and email)

## 🌍 Environment Management

We manage our infrastructure using a Folder-Based Approach. Each environment has its own isolated directory containing its specific configurations and state.

- **stage/** Folder: Contains configurations (.tf and .tfvars) for the staging environment. All infrastructure changes must be implemented and validated here first.
- **prod/** Folder: Contains configurations for the production environment. This folder mirrors the structure of stage but points to production resources.

> **Golden Rule:** Never modify the `prod/` folder directly without first verifying the exact same change in the `stage/` folder.

## 🚀 The Workflow (Step-by-Step)

We do not use long-lived branches like `develop` or `release`. We use short-lived feature branches.

### Phase 1: Development & Staging (The "Test" PR)

- **Branch:** Create a feature branch (e.g., `feat/add-redis`).
- **Change:** Apply your infrastructure changes only within the `stage/` directory.
  - Example: Update `stage/main.tf` or `stage/terraform.tfvars`.
- **PR & Merge:** Open a PR targeting `main`.
  - CI Trigger: Merging this will trigger the pipeline to deploy ONLY to the Staging AWS Account.
- **Verify:** Manually check that the Staging environment is working as expected.

### Phase 2: Promotion to Production (The "Release" PR)

Only proceed here if Phase 1 was successfully deployed and verified.

- **Sync:** Pull the latest `main` (which now contains your verified Staging code).
- **Branch:** Create a "promote" branch (e.g., `release/redis-prod`).
- **Promote:** Propagate the changes from the `stage/` folder to the `prod/` folder.
    ```
    Ensure variables (like instance sizes or node counts) 
    are adjusted for Production requirements in `prod/terraform.tfvars`.
  ```
- **PR & Merge:** Open a Release PR.
  - Review: This PR should only show changes inside the `prod/` folder.
  - Merge: Merging this triggers the Production Deployment.

## 📝 Commit Message Guidelines

We separate Feature work from Release work to keep the history clean.

### Phase 1 Commits (Feature Work - Staging)

```
feat(stage): add redis cluster resource
chore(stage): update instance type to t3.medium
```

### Phase 2 Commits (Promotion Work - Production)

```
chore(prod): promote redis config to production
fix(prod): increase auto-scaling limits
```

### Phase 3: Merge

- **Push your branch:**
  ```bash
  git push origin feat/your-feature-name
  ```

- **Open a Pull Request (PR):** Target the `main` branch.

- **Merge:** Once approved, merge to `main`. The CI/CD pipeline will automatically apply changes based on which folder was modified (`stage/` or `prod/`).

---

We use Conventional Commits to automate versioning. Your commit messages must follow this structure:

```
type(scope): description
```

### Allowed Types

| Type | Description | Example |
|------|-------------|---------|
| feat | New feature | `feat(vpc): add new subnet` |
| fix | Bug fix | `fix(sg): allow port 443` |
| chore | Maintenance/Config | `chore(prod): promote to prod` |
| ci | Pipeline changes | `ci(github): add linting job` |
| docs | Documentation | `docs: update readme` |
| refactor | Code cleanup | `refactor: simplify variable names` |
## ✅ Pull Request Checklist

Before opening a PR, ensure:

- [ ] You have run `terraform fmt -recursive` to standardize formatting.
- [ ] You have run `ansible-lint` (if touching Ansible files).
- [ ] Your commit messages follow the convention above.
- [ ] You have included the output of `terraform plan` in the PR description.
- [ ] No secrets (keys/passwords) are hardcoded in the files.

---

## ⚠️ Key Rules

- **Main is Sacred:** Never push directly to `main` without a PR (unless you are the sole admin handling a hotfix).

- **Infrastructure as Code:** Never change settings manually in the AWS Console. Always use Terraform.

- **Idempotency:** Ensure your Ansible playbooks can run multiple times without breaking things.

- **Parity:** Keep the `stage/` and `prod/` folder structures as identical as possible to minimize drift.