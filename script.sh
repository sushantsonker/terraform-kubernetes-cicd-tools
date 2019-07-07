#!/bin/bash 
sudo apt-get update -y 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce git nodejs nodejs-legacy
sudo usermod -a -G docker ubuntu
sudo systemctl start docker
sudo git clone https://github.com/sushantsonker/terraform-kubernetes-cicd-tools.git && cd terraform-kubernetes-cicd-tools/jenkins
sudo docker build -t jenkins . && cd ~
sudo chmod 777 /var/run/docker.sock
sudo docker run --name jenkins -d -p 8080:8080 -v /var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins
sudo docker exec jenkins kubectl config set-cluster kube
sudo docker cp config jenkins:/var/jenkins_home/.kube
