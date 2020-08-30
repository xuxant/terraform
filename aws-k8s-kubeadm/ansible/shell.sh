#!/bin/bash

sudo apt-get update -y
sudo apt-get install python3-pip -y
sudo apt-get install ansible -y
sudo chmod 600 /tmp/ansible/k8s
cd /tmp/ansible && ansible-playbook -i hosts.yaml --private-key k8s dependency.yaml