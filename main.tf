provider "google" {
  credentials = file(var.credentials_file)

  project = var.project
  region  = var.region
  zone    = var.zone
#  service_account_key = var.account_key
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-jsp-network-by-tfe"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-jsp-instance-by-tfe"
  machine_type = var.machine_types[var.environment]
  tags         = ["web", "dev"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }
  
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      nat_ip  = google_compute_address.vm_static_ip.address
    }
  }
}

resource "google_compute_address" "vm_static_ip" {
  name  = "tf-jsp-static-ip-by-tfe"
}

resource "google_storage_bucket" "example_bucket" {
  name  = "tf-example-bucket-jsp-20200220"
  location = "ASIA"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_compute_instance" "another_instance" {
  depends_on = [google_storage_bucket.example_bucket]
  
  name         = "tf-instance-2-by-tfe"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }
  
  network_interface {
    network = google_compute_network.vpc_network.self_link
    access_config {
    }
  }
}
