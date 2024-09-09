#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

# Pull Kubernetes images
sudo kubeadm config images pull

# Initialize Kubernetes cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=All

# Set up kubeconfig for the user
USER_HOME=$(eval echo ~$USER)
sudo mkdir -p $USER_HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $USER_HOME/.kube/config
sudo chown $USER:$USER $USER_HOME/.kube/config

# Apply Flannel pod network
sudo -i -u $USER kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml

# Apply Local Path Provisioner
sudo -i -u $USER kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml

# Set Local Path StorageClass as default
sudo -i -u $USER kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "Kubernetes cluster setup complete!"