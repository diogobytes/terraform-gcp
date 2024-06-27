provider "google" {
  project = "arctic-ocean-427610-u4"
  region  = "us-central1"
}


resource "google_compute_instance" "default" {
  name         = "default"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  network_interface {
    network = "default"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-focal-v20220712"
    }
  }
}
