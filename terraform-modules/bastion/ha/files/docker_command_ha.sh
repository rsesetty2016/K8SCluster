cd /tmp/files
sudo mkdir -p /projects/docker/ha
sudo chmod -R 755 /projects
sudo cp * /projects/docker/ha/.
cd /projects/docker/ha
sudo sed -i "s/HA_PROXY_IP/${1}/" /projects/docker/ha/haproxy.cfg
sudo sed -i "s/K8_CONTROL_IP/${2}/" /projects/docker/ha/haproxy.cfg
sudo docker stop k8-ha
sudo docker rm k8-ha
sudo docker build -t my-haproxy .
sudo docker run -dit --restart unless-stopped  -p 6443:6443 -p 8404:8404 -p 80:80 -p 3306:3306 -p 8900:8900 --name k8-ha my-haproxy
