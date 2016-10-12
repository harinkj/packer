provider "google" {
  credentials = "${file("Harin's First Project-335635df82f2.json")}"
  project = "quick-replica-95101"
  region = "us-east1"
}
resource "google_compute_network" "test" {
  name       = "test-network"
}
resource "google_compute_firewall" "test" {
  name    = "firewall-test-network"
  network = "${google_compute_network.test.name}"
  allow {
    protocol = "tcp"
    ports    = ["80", "8080","22"]
  }

  target_tags = ["http-server", "https-server"]
}
resource "google_compute_subnetwork" "test-us-east1" {
  name          = "test-us-east1"
  ip_cidr_range = "10.0.0.0/16"
  network       = "${google_compute_network.test.self_link}"
  region        = "us-east1"
  depends_on = ["google_compute_network.test","google_compute_firewall.test"]
}
resource "google_compute_instance" "docker-test-us-east1-b" {
  name        = "docker-test-us-east1-b"
  description = "docker-test-us-east1-b"
  tags = ["http-server", "https-server"]
  zone="us-east1-b"
  machine_type = "n1-standard-1"
//  depends_on = ["google_compute_subnetwork.test-us-east1"]
	disk {
		image = "https://www.googleapis.com/compute/v1/projects/quick-replica-95101/global/images/a-ubuntu-trusty-docker"
	}
	network_interface {
		subnetwork = "test-us-east1"
		access_config{
		}
	}
	metadata {
		ssh-keys = "${file("./keys/rootkey.pub")}"
	}
	metadata_startup_script = "${file("startup_script.txt")}"
	service_account {
		scopes = [ "compute-rw", "storage-ro", "datastore" ]
	}
}
resource "google_compute_instance" "docker-test-us-east1-b-provision" {
  name        = "docker-test-us-east1-b-provision"
  description = "docker-test-us-east1-b-provision"
  tags = ["http-server", "https-server"]
  zone="us-east1-b"
  machine_type = "n1-standard-1"
//  depends_on = ["google_compute_subnetwork.test-us-east1"]
	disk {
		image = "https://www.googleapis.com/compute/v1/projects/quick-replica-95101/global/images/a-ubuntu-trusty-docker"
	}
	network_interface {
		subnetwork = "test-us-east1"
		access_config{
		}
	}
	metadata {
		ssh-keys = "root:${file("./keys/ssh-keygen.pub")}"
	}
	metadata_startup_script = "${file("startup_script.txt")}"
	service_account {
		scopes = [ "compute-rw", "storage-ro", "datastore" ]
	}

    provisioner "remote-exec" {
		connection {
			type = "ssh"
			user = "root"
			//password = "${var.root_password}"
			private_key = "${file("./keys/ssh-keygen")}"
			timeout = "30s"
		}
        inline = [
			"echo testing------ > /tmp/test.txt"
        ]
    }

}
