# GRL_env_provisioner

Terraform based scripts to provision the environments of the 2 proposed solutions for the challenge assigned.

## Solutions

1) The first proposed solution pretends to cover the bare-minimun of the challenge's requirements by provisioning a gcp vm instance using terraform and configure that as a jenkins agent node. Jenkins has a job that pulls the "Timeoff" application code into the agent, compiles the dependencies and deploys the web server on it.

2) The second solution is intended to be a draft of what it would be a high-availability scenario in which a GKE cluster is provisioned along with several nodes. Using a kubernetes deployment a custom-made docker image is loaded into the POD's containers; the image pulls the latest code of the "Timeoff" application and deploys it. Right now the scenario is incomplete because the application uses sqlite as its DB, a high availability infrastructure is required for the database as well.


## Diagrams

![Infrastructure_diagram](https://raw.githubusercontent.com/andreyyec/GRL_env_provisioner/master/img/infrastructure.jpg)

In the image below a diagram showing the infrastructure of both solutions is shown. At the left side the basic solution with the vm instance. At the right hand the GKE Cluster solution.

![Deployment_diagram](https://raw.githubusercontent.com/andreyyec/GRL_env_provisioner/master/img/deployment.jpg)

The deployment process, as specified on the challenge requirements; triggers when a change is pushed into the repository master branch and it triggers the build for both solutions simultaneously.

On the repository, the solutions build scripts are independent from each other, so you can spin up one or the other at your convenience.

## Spinning up the environments

GCLOUD login:
First it is required to login into your gcp account from your console. An example on how to do it is provided below:

```bash
gcloud auth login
```


Terraform execution:
In order to create the environment please navigate to the folder of the solution you would like to provision and execute the commands below. You will be prompted to provide the values that you would like to use to create your environment (the values can be provided on a terraform.tfvars file as well).

```bash
terraform init
terraform apply
```
