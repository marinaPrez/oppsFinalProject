#!bin/bash
set -e

jenkins_home="/home/ubuntu/jenkins_home"

sudo apt-get update -y
sudo apt install docker.io git -y
sudo systemctl start docker
sudo apt install openjdk-11-jre-headless -y
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
mkdir -p ${jenkins_home}
sudo chown -R 1000:1000 ${jenkins_home}