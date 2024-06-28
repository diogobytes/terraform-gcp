locals {
  project_id = "arctic-ocean-427610-u4"
}

provider "google" {
  project = local.project_id
  region  = "us-central1"
}

resource "google_iam_workload_identity_pool" "github_actions" {
  project                   = local.project_id
  workload_identity_pool_id = "github-actions"
  display_name              = "GitHub Actions pool"
  description               = "Workload Identity Pool managed by Terraform"
  disabled                  = false
}
resource "google_iam_workload_identity_pool_provider" "github_actions" {
  project                            = local.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions"
  display_name                       = "GitHub Actions provider"
  description                        = "Workload Identity Pool Provider managed by Terraform"
  attribute_condition                = "attribute.repository_owner==\"diogobytes\""
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.aud"              = "assertion.aud"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }
  oidc {
    allowed_audiences = []
    issuer_uri        = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "wif-sa" {
  service_account_id = "projects/arctic-ocean-427610-u4/serviceAccounts/gh-actions-wif@arctic-ocean-427610-u4.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/*"
}
