## terraform-cicd — Copilot instructions

Purpose: help AI agents become productive quickly in this repo by calling out the high-level architecture, important files, common workflows, and repo-specific pitfalls discovered from code.

- Big picture
  - This is a small Terraform repository that builds a multi-tenant GCP environment. The root `main.tf` creates a shared VPC (`google_compute_network.main`) and instantiates per-tenant modules from `./tenants/${each.key}` using `for_each`.
  - Tenants live under `tenants/` (e.g. `tenants/tenant1/`). `tenant1` contains a working `main.tf` which is the canonical example module. `tenant2/main.tf` is currently empty.
  - State is intended to be stored in GCS (README: `gs://tmam-practical-state-bucket`). Confirm backend configuration (not found in the codebase); don't assume a backend is configured unless you find a `backend` block or `backend.tf`.

- Key files to inspect and modify
  - `main.tf` (root) — defines provider, shared VPC, and the module block that iterates tenants. Note: module block uses `for_each` and the block name is `tenants` (plural).
  - `terraform.tfvars` — sample tenant map. Add new tenants here using the same map structure.
  - `variables.tf` — currently truncated in the repo. The repo is missing a `variable "tenants"` declaration; agents should search for and add missing variables when making changes.
  - `tenants/tenant1/main.tf` — canonical tenant module. It creates a subnetwork, firewall, and a VM and references a `startup.sh` via `file("${path.module}/../startup.sh")` (the runtime script should live under `tenants/startup.sh`).
  - `tenants/tenant2/main.tf` — empty placeholder; use `tenant1` as the template when adding tenants.
  - `outputs.tf` — currently references `module.tenant1` and `module.tenant2` which is incompatible with the `for_each` module named `tenants` in `main.tf` (see Gotchas).

- Common workflows / commands (explicit)
  - Authenticate to GCP before running Terraform: set `GOOGLE_APPLICATION_CREDENTIALS` to a service account JSON or run `gcloud auth application-default login` locally.
  - Initialize and plan using the variables file:

    terraform init
    terraform plan -var-file=terraform.tfvars

  - Apply with the same vars file:

    terraform apply -var-file=terraform.tfvars

  - If you intend to use the GCS state bucket mentioned in `README.md`, confirm or create a Terraform backend configuration (example `backend "gcs" { bucket = "tmam-practical-state-bucket" prefix = "terraform/state" }`).

- Project-specific patterns and conventions
  - Per-tenant modules live under `tenants/<name>/` and are instantiated by iterating a root-level map variable (the `tenants` map in `terraform.tfvars`). When adding a tenant: add an entry to `tenants = { ... }` in `terraform.tfvars` and add a matching folder under `tenants/` that follows the `tenant1` layout.
  - The tenant module expects inputs: `network`, `tenant_name`, `cidr_block`, `region`, `zone`, and `ssh_pub_key` (see `main.tf` module block). Use these names when changing or adding module inputs.
  - The tenant VM sets metadata `ssh-keys = "gcpuser:${var.ssh_pub_key}"` so `ssh_pub_key` must be a single public key string.

- Important gotchas and verifiable fixes (agents should highlight these in PRs)
  - outputs vs for_each mismatch: root `main.tf` creates modules with name `tenants` and `for_each`, which produces `module.tenants["tenant1"]`. But `outputs.tf` references `module.tenant1` and `module.tenant2` (flat module names). Fix by either:
    - Changing the module block to use distinct module blocks per tenant (not recommended), or
    - Updating `outputs.tf` to iterate the `module.tenants` map, e.g.: `value = { for k, m in module.tenants : k => m.instance_external_ip }` or reference `module.tenants["tenant1"].instance_external_ip`.
  - Missing `variable "tenants"` declaration: `variables.tf` is truncated. Add a typed variable block such as:

    variable "tenants" {
      type = map(object({ cidr_block = string, region = string, zone = string, machine_type = optional(string), ssh_pub_key = optional(string) }))
    }

  - `startup.sh` referenced from `tenants/tenant1/main.tf` is expected at `tenants/startup.sh` (path: `${path.module}/../startup.sh`). The file is not present; add it or update the module reference.
  - `terraform.tfvars` contains `ssh_pub_key = var.ssh_pub_key` which is invalid in a tfvars file (tfvars should set concrete values). Make sure tfvars has a literal key string or remove that line and pass the key via environment or CLI.

- How to make safe automated edits
  - Prefer non-destructive, small PRs: e.g., add a `variables.tf` fix and update `outputs.tf` to a generated map first. Run `terraform init` and `terraform validate` after edits in CI or locally.
  - When creating new tenants, copy `tenants/tenant1/` as the template, ensure startup script exists at `tenants/startup.sh`, and add a matching key to `terraform.tfvars`.

If any of these repository details look wrong or you want a follow-up that applies safe fixes (variables + outputs + missing startup.sh), say which fix you'd like and I will open a PR-style patch.
