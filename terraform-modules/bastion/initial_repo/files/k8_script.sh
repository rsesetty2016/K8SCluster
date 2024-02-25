sudo cp /tmp/files/docker.json /etc/docker/daemon.json
sudo systemctl enable docker 
sudo systemctl daemon-reload 
sudo systemctl restart docker
# sudo rm /etc/containerd/config.toml
sudo systemctl restart containerd
cd /tmp/files
python3 k8_template_handler.py "template-file=ceph_pv_template.yaml out-file=ceph-pv.yaml name=${1} storage=${2} accessModes=${3} monitors=${4} pool=${5} image=${6} user=${7} secret=${8} fsType=${9} readOnly=${10}"
python3 k8_template_handler.py "template-file=nfs_template.yaml out-file=nfs-pv.yaml nfs_server=${11} mount_point=${12} storage_size=${13}"
sudo sh -c 'echo "source <(kubectl completion bash)\nalias k=kubectl\ncomplete -F __start_kubectl k" >> ~kube_user/.profile'