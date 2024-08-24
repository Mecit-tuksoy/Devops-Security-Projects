#!/bin/bash
sudo apt-get update
sudo apt-get install docker.io -y
sudo usermod -aG docker $USER   
sudo usermod -aG docker jenkins
newgrp docker
sudo chmod 777 /var/run/docker.sock
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
