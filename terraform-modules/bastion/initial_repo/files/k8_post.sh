sudo mkdir -p ~proxuser/.kube
sudo chown proxuser:proxuser ~proxuser/.kube
sudo cp -f /etc/kubernetes/admin.conf ~proxuser/.kube/config
sudo chown proxuser:proxuser ~proxuser/.kube/config
sudo mkdir -p ~svc_ansible/.kube
sudo cp -f /etc/kubernetes/admin.conf ~svc_ansible/.kube/config
sudo chown svc_ansible:svc_ansible ~svc_ansible/.kube
sudo chown svc_ansible:svc_ansible ~svc_ansible/.kube/config
mkdir /tmp/k8
sudo kubeadm token list > /tmp/k8/k8_token.txt
sudo kubeadm token create --print-join-command > /tmp/k8/k8_join.txt
sudo openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //' > /tmp/k8/k8_digest.txt
cd /tmp 
sudo tar zcf k8.tar.gz ./k8