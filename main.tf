locals {
  project_id  = ""
  gh_username = "diogobytes"
}

provider "google" {
  project = local.project_id
  region  = "us-central1"
}

resource "google_iam_workload_identity_pool" "github_actions" {
  project                   = local.project_id
  workload_identity_pool_id = "gh-test"
  display_name              = "GitHub Actions pool"
  description               = "Workload Identity Pool managed by Terraform"
  disabled                  = false
}
resource "google_iam_workload_identity_pool_provider" "github_actions" {
  project                            = local.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id
  workload_identity_pool_provider_id = "gh-test-provider"
  display_name                       = "GitHub Actions provider"
  description                        = "Workload Identity Pool Provider managed by Terraform"
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

resource "google_service_account" "service_account" {
  account_id   = "gh-test"
  display_name = "GH Service Account"
}

resource "google_service_account_iam_member" "wif-sa" {
  service_account_id = google_service_account.service_account.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/*"
}


resource "google_project_iam_member" "this" {
  project = local.project_id
  role    = "roles/cloudsql.admin"
  member  = google_service_account.service_account.member
}
