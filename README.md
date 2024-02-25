Kubernetes Cluster Setup 
========================

- [Kubernetes Cluster Setup](#kubernetes-cluster-setup)
- [1. The Introduction](#1-the-introduction)
    - [1.1 Namespaces](#11-namespaces)
    - [1.2 Labels](#12-labels)
  - [2. The Terraform](#2-the-terraform)
  - [3. The Cloud](#3-the-cloud)
  - [4. The Cluster Initialization](#4-the-cluster-initialization)
    - [4.1 The pre-requisites](#41-the-pre-requisites)
      - [4.1.1 Create a self signed certificate to secure API server.](#411-create-a-self-signed-certificate-to-secure-api-server)
      - [4.1.2 Create SSH keys for the authentication](#412-create-ssh-keys-for-the-authentication)
      - [4.1.3 Environment Variables required for Terraform](#413-environment-variables-required-for-terraform)
      - [4.1.4 Setup and configure AWS/Azure backend](#414-setup-and-configure-awsazure-backend)
  - [5. The Tools](#5-the-tools)
    - [5.1 Prometheus](#51-prometheus)
    - [5.2 Grafana](#52-grafana)
    - [5.3 Traefik](#53-traefik)
    - [5.4 Istio](#54-istio)
      - [5.4.1 Kiali Dashboard](#541-kiali-dashboard)
    - [5.5 GrayLog](#55-graylog)
    - [5.6 Longhorn](#56-longhorn)
    - [5.7 CrowdSec](#57-crowdsec)
    - [5.8 RKE2](#58-rke2)
    - [5.9 kubectx](#59-kubectx)
    - [5.10 kubens](#510-kubens)
    - [5.11 Vault](#511-vault)
    - [5.12 Kube-bench](#512-kube-bench)
    - [5.13 Kustomize](#513-kustomize)
    - [5.14 k9s](#514-k9s)
    - [5.15 Kubeflow](#515-kubeflow)
    - [5.16 Policy Management](#516-policy-management)
      - [5.16.1 Datree](#5161-datree)
      - [5.16.2 OPA Gatekeeper](#5162-opa-gatekeeper)
      - [5.16.3 Kyverno](#5163-kyverno)
    - [5.17 Jaegar](#517-jaegar)
    - [5.18 Metallb](#518-metallb)
  - [5.19 Gitlab (CE)](#519-gitlab-ce)
  - [5.20 Jenkins](#520-jenkins)
  - [6. The Security](#6-the-security)
    - [6.1 Image Security](#61-image-security)
    - [6.2 RBAC](#62-rbac)
      - [6.2.1 Users and Services](#621-users-and-services)
      - [6.3 Network policies](#63-network-policies)
      - [6.4 mTLS (Mutual TLS)](#64-mtls-mutual-tls)
      - [6.5 Secure Secret Data](#65-secure-secret-data)
      - [6.6 Secure etcd store](#66-secure-etcd-store)
      - [6.7 Backup and Restore](#67-backup-and-restore)
- [Setting up Docker local private repository](#setting-up-docker-local-private-repository)


# 1. The Introduction
The POC includes a NFS storage (CSI Driver), and installs the following tools, by default.
1. Traefik
2. Cert Manager
3. Kyverno

Creates a NFS PV of 250GB. This NFS server is on the Proxmox server.


### 1.1 Namespaces
| Name space | Description |
| --- | --- |
| default | The default name space, in which K8S services will be running |
| tools | All monitoring and deployment tools will be deployed |
| apps | All applications will be deployed|

### 1.2 Labels
Naming convention for labels: 
***cloud-provider***-***environment***-***appName***-***serviceType***

> **Cloud Providers:** 
> | Provider | Description |
> | --- | --- |
> | aws | (AWS) Amazon Web Services |
> | az | (Azure) Microsoft Web Services |
> | lw | Liquid Web |
> | prox | On-prem Cloud |
> | gcp | Google|  
  
> **Environments:**  
> | Environment | Description |
> | --- | --- |
> | prod | Production |
> | prep | Preproduction |
> | stage | Staging |
> | uat | User Acceptance Testing |
> | qual| QA |
> | dev | Intergrated Dev Environment|
> | udev | Unit development environment, Individual Work Environment|
> | poc | Proof of Concept|
  
> **appName:**  
> | Application | Description |
> | --- | --- |
> | devops | DevOps Portal, build tools such as Jenkins etc |
> | tools | Any third party Tools, such as Traefik etc | 
> | mon | Monitoring Tools, such as Promethues |
> | logs | Logging tools, such as Graylog|
> | ***custom*** | Custom applications, in house| 
  
> **serviceType:**  
> | Service | Description | 
> | --- | --- |
> | web | Frondend application|
> | app | Middleware, API providers etc |
> | db | Backends, such as database|

**An Exmaple:**  
 *prox-prod-devops-web*: Represents a devops UI application (for example, Jenkins) deployed in an on-premise production environment.


## 2. The Terraform 
**Workspaces**:
> | Workspace | Description | 
> | --- | --- |
> | prod | Production |
> | prep | Preproduction |
> | stage | Staging |
> | uat | User Acceptance Testing |
> | qual| QA |
> | dev | Intergrated Dev Environment|
> | udev | Unit development environment, Individual Work Environment|
> | poc | For proof of Concept |

**Backends for Terraform States**:
> | Provider | Description |
> | --- | --- |
> | aws | S3 and DynamoDB |
> | az | Storage |


## 3. The Cloud

The on-premise server is built with [Proxmox](https://www.proxmox.com/en/) Virtual Environment 7.4-17.  

The staging and production environment can be built on AWS EKS or Azure AKS.  

The POC environment consists of one Control node and two worker nodes. 

Two OS templates created for Ubuntu 20.04 and Ubunut 22.04. 

The **cloud-init** has been configured to create standard users, and install required packages. 

Only one cloud-init template will be used to create all nodes. The values will be passed from Terraform scripts. 

A local SSH keys will be generated and added to all the standard users to login without password. 

---

## 4. The Cluster Initialization

The passwords mentioned in the following section are applicable only for POC, and not to be used in other environments. 

### 4.1 The pre-requisites

#### 4.1.1 Create a self signed certificate to secure API server.
**Steps to create a TLS certificate:**
**(THIS IS AN OPTIONAL STEP)**
1.  Install OpenSSL, if required.
```
# openssl version
OpenSSL 3.0.2 15 Mar 2022 (Library: OpenSSL 3.0.2 15 Mar 2022)
```
2.  Generate CA'private key and certificate
```
# openssl req -x509 -newkey rsa:4096 -days 3650 -keyout ca-key.pem -out ca-cert.pem
Enter PEM pass phrase: T3stC3rt!ficat3ForP0C
Country Name (2 letter code) [AU]:US
State or Province Name (full name) [Some-State]:MD
Locality Name (eg, city) []:CLRKS
Organization Name (eg, company) [Internet Widgits Pty Ltd]:MyComp
Organizational Unit Name (eg, section) []:DevOps
Common Name (e.g. server FQDN or YOUR name) []:vaanj.com
Email Address []:rsesetty@vaanj.com

```
3.  Generate web server's private key and CSR 
```
# openssl req -newkey rsa:4096 -keyout k8s-api-key.pem -out k8s-api-req.pem 

Enter PEM pass phrase: T3stC3rt!ficat3ForP0C
Verifying - Enter PEM pass phrase: T3stC3rt!ficat3ForP0C
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:US
State or Province Name (full name) [Some-State]:MD
Locality Name (eg, city) []:CLARKS
Organization Name (eg, company) [Internet Widgits Pty Ltd]:vaanj.com
Organizational Unit Name (eg, section) []:DevOps
Common Name (e.g. server FQDN or YOUR name) []:vaanj.com
Email Address []:rsesetty@vaanj.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:

```
4.  Sign the web server's certificate request
```
# openssl x509 -req -in k8s-api-req.pem -days 3650 -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out k8s-api-cert.pem
```
5.  Verify the certificate:
**# openssl x509 -in k8s-api-cert.pem -noout -text**
**# openssl verify -CAfile ca-cert.pem k8s-api-cert.pem**

#### 4.1.2 Create SSH keys for the authentication

Make sure that to have the following keys in the users $HOME/.ssh directory:
```
id_proxmox.pub
id_proxmox
id_proxmox_svc_ansible.pub
id_proxmox_svc_ansible
```

#### 4.1.3 Environment Variables required for Terraform
```
export TF_VAR_ansible_pwd=master_pve
export TF_VAR_ceph_key=AQ<MASKED>Q==
export TF_VAR_pm_api_url="https://192.168.1.47:8006/api2/json"
export TF_VAR_pm_api_token_id='<MASKED>'
export TF_VAR_pm_api_token_secret="0bcd<MASKED>570282"
```

#### 4.1.4 Setup and configure AWS/Azure backend
Configure aws command line authentication to connect to S3 and Dynamodb to store terraform state.


## 5. The Tools
### 5.1 Prometheus
### 5.2 Grafana
### 5.3 Traefik
helm repo add traefik https://traefik.github.io/charts  

### 5.4 Istio

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system --set defaultRevision=default
helm ls -n istio-system
helm install istiod istio/istiod -n istio-system --wait
helm ls -n istio-system
helm status istiod -n istio-system

#### 5.4.1 Kiali Dashboard

### 5.5 GrayLog
Tools to explore: Styra, Envoy, Kong

### 5.6 Longhorn
URL: https://longhorn.io/

### 5.7 CrowdSec
URL: https://www.crowdsec.net/blog/kubernetes-crowdsec-integration

### 5.8 RKE2
URL: https://docs.rke2.io/

### 5.9 kubectx  

### 5.10 kubens  

### 5.11 Vault  

### 5.12 Kube-bench  

### 5.13 Kustomize  

### 5.14 k9s  
```
Install on Ubuntu:

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
export PATH=$PATH:/home/linuxbrew/.linuxbrew/bin
brew install derailed/k9s/k9s

```

https://k9scli.io/topics/commands/


### 5.15 Kubeflow

### 5.16 Policy Management  
#### 5.16.1 Datree  
#### 5.16.2 OPA Gatekeeper
#### 5.16.3 Kyverno  
helm repo add kyverno https://kyverno.github.io/kyverno/

helm install kyverno-policies kyverno/kyverno-policies -n kyverno

### 5.17 Jaegar
URL: https://www.jaegertracing.io/

### 5.18 Metallb
helm repo add metallb https://metallb.github.io/metallb

kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

helm --namespace metallb-system \
    install --create-namespace \
    metallb metallb/metallb 

```
Create IP Address Range:

apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: production
  namespace: metallb-system
spec:
  # Production services will go here. Public IPs are expensive, so we leased
  # just 4 of them.
  addresses:
  - 192.168.1.200 - 192.168.1.225

```
    
To Test:
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --type=LoadBalancer --port 80

## 5.19 Gitlab (CE)
```
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
  --timeout 600s \
  --set global.hosts.domain=gitlab.vaanj.com \
  --set global.hosts.externalIP=192.168.1.110 \
  --set certmanager-issuer.email=me@example.com \
  --set postgresql.image.tag=13.6.0 \
  --set global.edition=ce

Get the root password:
kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo


```

## 5.20 Jenkins
root password: fdbb510b6795477cb0a5816859127c98

/var/jenkins_home/secrets/initialAdminPassword

kubectl exec -it <pod-name> cat  /var/jenkins_home/secrets/initialAdminPassword -n devops


## 6. The Security
### 6.1 Image Security
The **synk** or **sysdig** tools to scan images.

### 6.2 RBAC
#### 6.2.1 Users and Services
K8S does not manage users natively, and not K8S objects exists for representing normal user accounts. Admins can choose a *static token file*, *client certificates* or *3rd party identity service*. 

**Roles:**
1. Namespace roles
2. Cluster roles
   

#### 6.3 Network policies
To make sure that a restricted communication between the pods.

#### 6.4 mTLS (Mutual TLS)

#### 6.5 Secure Secret Data
AWS KMS, Harhicorp Vault

#### 6.6 Secure etcd store

#### 6.7 Backup and Restore


# Setting up Docker local private repository

1. mkdir ~/docker-registry
2. cd ~/docker-registry
3. mkdir data
4. Create docker compose file:
```
version: '3'

services:
  registry:
    image: registry:2
    restart: always
    ports:
    - "5000:5000"
    environment:
      REGISTRY_AUTH: htpasswd
      REGISTRY_AUTH_HTPASSWD_REALM: Registry
      REGISTRY_AUTH_HTPASSWD_PATH: /auth/registry.password
      REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /data
    volumes:
      - ./auth:/auth
      - ./data:/data
```
5. sudo snap install --classic certbot
6. sudo ln -s /snap/bin/certbot /usr/bin/certbot
7. sudo certbot --nginx -d docker.vaanj.com
8. Add the following to nginx configuration under HTTPS section:
```
        location / {
            # Do not allow connections from docker 1.5 and earlier
            # docker pre-1.6.0 did not properly set the user agent on ping, catch "Go *" user agents
            if ($http_user_agent ~ "^(docker\/1\.(3|4|5(?!\.[0-9]-dev))|Go ).*$" ) {
              return 404;
            }
            proxy_pass                          http://192.168.1.120:5000;
            proxy_set_header  Host              $http_host;   # required for docker client's sake
            proxy_set_header  X-Real-IP         $remote_addr; # pass on real client's IP
            proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
            proxy_set_header  X-Forwarded-Proto $scheme;
            proxy_read_timeout                  900;
        }

```
9. sudo vi /etc/nginx/nginx.conf, and add the following:
    http {
        client_max_body_size 16384m;
        ...
    } 
10. sudo systemctl restart nginx
11. mkdir ~/docker-registry/auth
12. mkdir ~/docker-registry/auth
13. cd ~/docker-registry/auth
14. htpasswd -Bbc ~/docker-registry/auth/registry.password docker-user testpw123
15. cd ~/docker-registry
16. docker-compose up

Testing:
1. docker run -t -i ubuntu /bin/bash --> Thiw will pull the image from docker hub
2. touch /SUCCESS
3. exit
4. docker commit $(docker ps -lq) test-image
5. docker login https://docker.vaanj.com
6. docker tag test-image docker.vaanj.com/test-image
7. docker push docker.vaanj.com/test-image

Now the image can be pulled from local private repository.