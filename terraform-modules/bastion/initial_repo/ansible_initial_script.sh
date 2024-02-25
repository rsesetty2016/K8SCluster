#!/bin/sh

cd ${HOME}/initial_repo
. ~/.bash_profile
echo ${1}
ansible-playbook -i inventory.yml update_etc_hosts.yml > /tmp/ansible.log 2>&1
ansible-playbook -i inventory.yml k8_cluster.yml > /tmp/k8_cluster.log 2>&1
exit 0