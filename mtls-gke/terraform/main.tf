provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "required" {
  for_each = toset([
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "gkehub.googleapis.com",
    "mesh.googleapis.com",
    "anthos.googleapis.com"
  ])
  service            = each.key
  disable_on_destroy = false
}


### GKE stuff

resource "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.region

  enable_autopilot = true

  release_channel {
    channel = "REGULAR"
  }

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {}

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}
