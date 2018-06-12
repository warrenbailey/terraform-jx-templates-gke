terraform {
  required_version = ">= 0.11.0"
}

provider "google" {
  credentials = "${file("${var.credentials}")}"
  project     = "${var.gcp_project}"
}

resource "google_container_node_pool" "jx-node-pool" {
  name       = "default-pool"
  zone       = "${var.gcp_zone}"
  cluster    = "${google_container_cluster.jx-cluster.name}"
  node_count = "${var.min_node_count}"

  node_config {
    preemptible  = "${var.node_preemptible}"
    machine_type = "${var.node_machine_type}"
    disk_size_gb = "${var.node_disk_size}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }

  autoscaling {
	min_node_count = "${var.min_node_count}"
	max_node_count = "${var.max_node_count}"
  }

}

resource "google_container_cluster" "jx-cluster" {
  name               = "${var.cluster_name}"
  description        = "jx k8s cluster"
  zone               = "${var.gcp_zone}"
  enable_kubernetes_alpha = "true"
  enable_legacy_abac = "true"
  initial_node_count = "${var.min_node_count}"
  remove_default_node_pool = "true"

  lifecycle {
    ignore_changes = ["node_pool"]
  }
}
