# terraform_project
Terraform to create CICD Tools Jenkins and SonarQube in GCP

# terraform.tfvars
```
project     = "terraform-k8s-cicd-tools" # set your project id
region      = "us-central1"
zone        = "us-central1-c"
size        = "n1-standard-2"
public_key  = ".key/user.pub"
private_key = ".key/user.pem"
master_user = "user"
master_pass = "passwd0123456789" # password must be at least 16 characters
app_repo    = "https://github.com/sushantsonker/terraform-kubernetes-cicd-tools.git"
```

# .key
- create ssh key `ssh-keygen -f user.pem -N""` # leave an empty password
- rename public to `.pub`
- place both in `.key` subdir

# api
- enable Kubernetes Engine API by visiting service console
- enable Compute Engine API by visiting service console
- Console -> IAM & admin -> Service accounts -> select default account (or create new) ->  Edit -> Create Key -> Json
- place the service account key file into the `.key/account.json`

# build server
```
terraform init
terraform apply
```
- login to build server http://{terraform.output.build}:8080/
- create SERVICE_ACCOUNT_KEY secret file (Jenkins -> Credentials -> Global Credentials -> Add Credentials)
  * SERVICE_ACCOUNT_KEY { type = secret file } For secre file, use '.key/account.json'
- create new project using `pipeline` template and paste `jenkins/Jenkinsfile` content
- Manage Jenkins -> Manage Plugins -> Available -> filter: sonar -> SonarQube Scanner for Jenkins -> Install and restart
- Manage Jenkins -> Configure System -> SonarQube servers -> Add SonarQube -> Name: sonar, Host: http://{terraform.output.sonar}:9000 -> Save
- Manage Jenkins -> Global Tool Configuration -> Add SonarQube Scanner -> Name: scanner -> Save
- enable Poll SCM if CI mode is required

# deployment
```
run jenkins build
```

# test
- app url `http://{terraform.output.app}:5000`
- build server `http://{terraform.output.build}:8080`
- sonar `http://{terraform.output.sonar}:9000`

# destroy
```
terraform destroy
```
