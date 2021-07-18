#!/bin/bash

sudo yum update -y

# Installing Jenklins
sudo yum-config-manager --enable rhui-REGION-rhel-server-extras
sudo yum -y install docker 
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo docker pull jenkins/jenkins
sudo docker run -d -p 8080:8080 --name=jenkins-master jenkins/jenkins


# Installing Ansible
#sudo curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
#sudo python get-pip.py
#sudo python -m pip install ansible
