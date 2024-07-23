locals {
  secrets = [
    {
      secret_id = "mongodb-atlas-secret-replication"
    },
    {
      secret_id = "mongodb-atlas-secret-admin"
    },
  ]
  secret = { for v in local.secrets : v.secret_id => v }
}

resource "mongodbatlas_advanced_cluster" "this" {
  project_id   = var.project_id
  name         = "rrt-mongodb-cluster"
  cluster_type = var.instance_size
  replication_specs {
    region_configs {
      electable_specs {
        instance_size = var.instance_size
        node_count    = var.node_count
      }
      provider_name = var.provider_name
      priority      = 7
      region_name   = var.region
    }
  }
}

# Create Secrets
resource "google_secret_manager_secret" "mongodb_atlas" {
  for_each = local.secret

  project   = "test"
  secret_id = each.value.secret_id
  replication {
    user_managed {
      replicas {
        location = "test"
      }
    }
  }
}

# Secret manager access for the fibercentric group to mongodb atlas secret
resource "google_secret_manager_secret_iam_member" "mongodb_atlas_adder" {
  for_each = local.secret

  project   = "test"
  secret_id = google_secret_manager_secret.mongodb_atlas[each.key].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "group:fibercentric.iamadmins@nos.pt"
}

resource "mongodbatlas_database_user" "this" {
  username           = "replication"
  password           = data.google_secret_manager_secret_version.mongodb_atlas.secret_data
  project_id         = "test"
  auth_database_name = "admin"
  roles {
    role_name     = "atlasAdmin"
    database_name = "admin"
  }
  labels {
    key   = "%s"
    value = "%s"
  }
  scopes {
    name = mongodbatlas_advanced_cluster.this.name
    type = "CLUSTER"
  }
}
data "google_secret_manager_secret_version" "mongodb_atlas" {
  secret = local.secrets[0].secret_id

  depends_on = [google_secret_manager_secret.mongodb_atlas]
}
