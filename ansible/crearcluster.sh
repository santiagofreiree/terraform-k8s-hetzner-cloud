#!/bin/bash

#Intial user and ssh hardening
ansible-playbook -i inventory_setup0.ini 01_initial_setup/setup_vps.yml
ansible-playbook -i inventory_setup1.ini 01_initial_setup/setup_vps.yml
ansible-playbook -i inventory_setup2.ini 01_initial_setup/setup_vps.yml

#Configure Nat Router
ansible-playbook -i inventory.ini 02_natworker0/base.yml

#Install kubeadmin and configure controlplane and worker0
ansible-playbook -i inventory.ini 03_controlplane-worker0/controlplane-worker0.yml

#Install kubeadmin and configure worker1
ansible-playbook -i inventory.ini 04_worker1/worker1.yml
