variable "app_repo" {}
variable "size" {}
variable "public_key" {}
variable "private_key" {}

locals {
  #yum   = "sudo yum -y -d 1 install"
  apt  = "sudo apt-get install -y" 
  repo = "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  image = "ubuntu-1604-xenial-v20190628"
  user  = "ubuntu"
}

resource "google_compute_instance" "build" {
  name         = "build"
  machine_type = "${var.size}"

  boot_disk {
    initialize_params {
      image = "${local.image}"
    }
  }

  network_interface {
    network       = "${data.google_compute_network.net.name}"
    access_config{}
  }

  metadata = {
    sshKeys = "${local.user}:${file(var.public_key)}"
  }

  connection {
    user        = "${local.user}"
    private_key = "${file(var.private_key)}"
    host = "${google_compute_instance.build.network_interface.0.access_config.0.nat_ip}"
  }

  provisioner "file" {
    source      = "jenkins"
    destination = "~"
  }

  provisioner "file" {
    content     = "${local.kubeconfig}"
    destination = "config"
  }
  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }

provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "bash /tmp/script.sh",
    ]
  }


#  provisioner "remote-exec" {
#    inline = [
#      "sudo apt-get update -y",
#      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -", 
#      "sudo add-apt-repository ${local.repo}",
      #"sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"',
 #     "sudo apt-get update -y",
 #     "sudo apt-get install -y docker-ce git",
 #     "sudo usermod -a -G docker ${local.user}",
 #     "sudo systemctl start docker",
 #     "sudo git clone ${var.app_repo} && cd terraform-kubernetes-cicd-tools/jenkins",
 #     "sudo docker build -t jenkins . && cd ~",
 #     "sudo chmod 777 /var/run/docker.sock",
 #     "sudo docker run --name jenkins -d -p 8080:8080 -v /var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins",
 #     "sudo docker exec jenkins kubectl config set-cluster kube",
 #     "sudo docker cp config jenkins:/var/jenkins_home/.kube",

  #  ]
#  }

}

output "build" {
  value = "${google_compute_instance.build.network_interface.0.access_config.0.nat_ip}:8080"
}
