#!/bin/bash
#### changing hostname
hostnamectl set-hostname microk8s

# installing Docker CE Prerequisites
sudo apt-get update -y
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# to validate the fingerprint use the following command
# sudo apt-key fingerprint 0EBFCD88

# Installing Docker CE
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

# installing Docker Compose, and making the downloaded binary executable
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# adding the running user ubuntu to the docker group
sudo usermod -aG docker ubuntu


#### install microk8s
snap install microk8s --classic --channel=1.17/stable

echo "alias kubectl=microk8s.kubectl" >> /home/ubuntu/.bashrc
echo "alias kubectl=microk8s.kubectl" >> /root/.bashrc

microk8s.enable dns

microk8s.status > /home/ubuntu/microk8s.status.txt
chown ubuntu:ubuntu /home/ubuntu/microk8s.status.txt

usermod -aG microk8s ubuntu