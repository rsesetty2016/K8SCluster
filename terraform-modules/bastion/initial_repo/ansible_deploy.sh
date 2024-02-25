# sudo mkdir -p /var/lib/secure/ansible
# sudo pwgen -ys 15 1 > /var/lib/secure/ansible/ansible.pw
# sudo chmod 600 /var/lib/secure/ansible/ansible.pw
# sudo chown svc_ansible:svc_ansible /var/lib/secure/ansible/ansible.pw
# sudo mkdir -m 755 -p ~svc_ansible/projects/ansible/group_vars
# sudo mv /tmp/ansible/* ~svc_ansible/projects/ansible/.
# sudo rm -rf /tmp/ansible
# sudo chown -R svc_ansible:svc_ansible ~svc_ansible/projects
#mv ~svc_ansible/projects/ansible/group_vars.k8.yml ~svc_ansible/projects/ansible/group_vars/.
# mkdir -m 755 -p ~svc_ansible/projects/ansible/group_vars
# chown -R svc_ansible:svc_ansible ~svc_ansible/projects
# cp /tmp/ansible/* ~svc_ansible/projects/ansible/.
# echo 'export ANSIBLE_HOST_KEY_CHECKING=False' >> ~svc_ansible/.bash_profile 
# echo 'alias ansible="ansible --vault-password-file=/var/lib/secure/ansible/.ansible.pw"' >> ~svc_ansible/.bash_profile 
# echo 'alias ansible-playbook="ansible-playbook --vault-password-file=/var/lib/secure/ansible/.ansible.pw"' >> ~svc_ansible/.bash_profile 
#cd projects/ansible
#. ~svc_ansible/.bash_profile
rm ~/.ssh/known_hosts
#ansible-vault create --vault-password-file /var/lib/secure/ansible/.ansible.pw secrets.yml
# ansible-playbook --vault-password-file=/var/lib/secure/ansible/.ansible.pw -i inventory.yml update_etc_hosts.yml > /tmp/ansible.log 2>&1
exit 0
    