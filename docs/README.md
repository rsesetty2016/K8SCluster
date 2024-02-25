#### Terraform

###### Variables
> **Precendence** 
    1. Environment Variables (TF_VAR_<variable>) will loaded first
    2. ***terraform.tfvars*** will be loaded next
    3. ***\*.auto.tfvars*** or JSON files will be loaded 
    4. Finally, command line arguments passwd with ***-var*** 

> --refresh=false, uses the statefile to manage resources, without reconciling actual state, this improves performance.

> **The following two commands create a json file with plan:**
> terraform plan -out x.json
> terraform show -json x.json > <outfilename> 

> **Terrform State**
> list, mv, pull, rm and show are available options.

> taint/untaint to force a resource to recreate or make a resource not to recreate. 

> **Provisioners**
> remote-exec, local-exec
> By default this will be "create", but **when = destroy** will executed during the destroy phase. Also, **on_failure = fail** directs if there is file not found exists or some other errors. This option will make apply phase to fail. If you want apply phase to continue even if there is an error, then set **on_failure = continue**.
> | Provider | Resource | Option |
> | --- | --- | --- |
> | AWS | aws_instance| user_data |
> | Azure|azurerm_virtual_machine| custom_data|
> | GCP | google_compute_instance | meta_data|
> |VMWare vSphere| vsphere_virtual_machine| user_data.txt|

> **Backends for State management**
> | Backend | Notes |
> | --- | --- |
> | local| default, stores locally |
> | remote | he remote backend is unique among all other Terraform backends because it can both store state snapshots and execute operations for Terraform Cloud's CLI-driven run workflow. It used to be called an "enhanced" backend.|
> | artifactory| Deprecated| 
> | azurerm| Stores the state as a Blob with the given Key within the Blob Container within the Blob Storage Account. This backend supports state locking and consistency checking with Azure Blob Storage native capabilities.| 
> | consul| Stores in Consul KV store at a given path| 
> | cos| Tencent Cloud Object Storage(COS)| 
> | etcd| Deprecated| 
> | etcdv3| Deprecated| 
> | gcs| Google Cloud Storage| 
> | http| Uses REST API| 
> | Kubernetes| Stores state in K8S secret, and it has a limit of 1MB | 
> | manta| Deprecated |   
> | oss| Alibaba Cloud OSS| 
> | pg| Postgres| 
> | S3| AWS S3 Bucket and Dynomodb | 
> | swift| Deprecated.| 
> 
> Create the following buckets before changing the backend:
> 
> provider "aws" {
    region = "us-east-1"
   }
resource "aws_s3_bucket" "state_bucket" {
  bucket = "state-s3-sesettybiz"
}
resource "aws_dynamodb_table" "state_table" {
  name = "terraform-up-and-running-locks" 
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}



> **Graph (dependency)**
terraform graph
apt install -y graphviz
terraform graph | dot -Tsvc > <file.svg>

> **LifeCycle**
>* ignore_changes
>* create_before_destroy
>* prevent_destroy

> **Data Source**
> * data "local_file" --> Local file

> **Meta arguments**
> * depends_on
> * lifecycle
> * count

> **Functions**
> * length(), index(list, value), element(list, index), contains(string, value)
> * keys(dict), values(dict), lookup(dict, value), lookup(dict, value, default_value_if_not_found)
> * toset()
> * file()
> * max(), min(), expansion function (...), ceil(), floor()
> * split(delimiter, string),  lower(), upper(), title(), substr(str, index, length), join(delimiter, list)

> **Locking provider versions**
>    Use required_providers
>   version = "!= <version>" ---> Don't use this, use one version before this
> Comparison operates can be used to define a range.
>   version = "~> 1.2" --> (Pessimistic constraint operator) Specific version or any incremental versions in 1.x.
> Example: version = "> 3.45.0, !=3.46.0, < 3.48.0", this downloads 3.47.x


#### Case Study - Terraform and AWS
Prereqs:
1. IAM (independing of Region)
   1. Create users
      1. Access types: Programmatic access and/or management console
   2. Create groups
   3. Attach policy
   4. Create custom IAM policy, and 
   5. IAM role --> create a role and attach a policy

