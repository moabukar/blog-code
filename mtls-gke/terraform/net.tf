resource "google_compute_network" "vpc" {
  name                    = "gke-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.10.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc.id
  purpose       = "PRIVATE"
  role          = "ACTIVE"
}

resource "google_compute_subnetwork" "pods" {
  name          = "gke-pods"
  ip_cidr_range = "10.20.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc.id
  purpose       = "VPC_PEERING"
  role          = "ACTIVE"
}

resource "google_compute_subnetwork" "services" {
  name          = "gke-services"
  ip_cidr_range = "10.30.0.0/20"
  region        = var.region
  network       = google_compute_network.vpc.id
  purpose       = "VPC_PEERING"
  role          = "ACTIVE"
}