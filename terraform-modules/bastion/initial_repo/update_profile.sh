#!/bin/sh
# 1 - home dir, 2 - secret path, 3 - secrete file, 4 - secret password, 5 - ansible user
sudo mkdir -p ${2}
echo "export ANSIBLE_HOST_KEY_CHECKING=False" >> ${1}/.bash_profile
echo "alias ansible='ansible --vault-password-file=${3}'" >> ${1}/.bash_profile
echo "alias ansible-playbook='ansible-playbook --vault-password-file=${3}'" >> ${1}/.bash_profile
sudo echo "${4}" > ${3}
sudo chown -R ${5}:${5} ${2}
sudo chmod 700 ${2}
sudo chmod 600 ${3}

exit 0