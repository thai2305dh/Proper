#!/bin/bash
sudo apt update
sudo apt-get install -y unzip
sudo apt-get install -y nfs-common
sudo mkdir -p /var/lib/jenkins
while ! (sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_dns_name}:/ /var/lib/jenkins); do sleep 10; done
while ! (echo ${efs_dns_name}:/ /var/lib/jenkins nfs defaults,vers=4.1 0 0 >> /etc/fstab) ; do sleep 10; done
sudo apt install openjdk-11-jdk -y
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y