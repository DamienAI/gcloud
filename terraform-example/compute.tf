# Create a new instance
resource "google_compute_instance" "default" {
  name         = "ubuntu-xenial"
  machine_type = "f1-micro"
  zone         = "${var.TF_VAR_zone}"

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-lts"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

output "instance_id" {
  value = "${google_compute_instance.default.self_link}"
}
