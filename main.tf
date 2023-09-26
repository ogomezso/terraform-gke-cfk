data "google_service_account" "default" {
  account_id = "ogomez-cp-tf-sa@solutionsarchitect-01.iam.gserviceaccount.com"
}

resource "google_container_cluster" "gke" {
  name                     = "ogomez-gke-cluster"
  project                  = "solutionsarchitect-01"
  location                 = "europe-west2"
  remove_default_node_pool = true
  initial_node_count       = 3
  network                  = "ogomez-vpc"
  subnetwork               = "ogomez-vpc-submet"
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
  addons_config {
    http_load_balancing {
      disabled = true
    }
    horizontal_pod_autoscaling {
      disabled = true
    }
    network_policy_config {
      disabled = false
    }
  }
  resource_labels = {
    "cflt_environment" = "prod"
    "cflt_managed_by"  = "user"
    "cflt_managed_id"  = "ogomezsoriano"
    "cflt_partition"   = "sales"
    "cflt_service"     = "emea"
    "owner" : "ogomezsoriano"
  }
}

resource "google_container_node_pool" "node" {
  project    = "solutionsarchitect-01"
  name       = "ogomez-node-pool"
  location   = "europe-west2"
  cluster    = google_container_cluster.gke.name
  node_count = 3

  node_config {
    preemptible  = true
    machine_type = "e2-standard-8"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = data.google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }
}
