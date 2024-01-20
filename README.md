# Project **Ensuring Quality Releases**  
This project centers around harnessing cutting-edge tools, specifically Microsoft Azure, to establish a resilient pipeline for generating disposable test environments, effortlessly executing automated tests, and ensuring the quality of software releases.

### Pipeline Resources
This CI/CD pipeline is configured to generate the following crucial resources:

* Resource Group
* App Service
* Virtual Network
* Network Security Group
* Virtual Machine

I've orchestrated these resources to deploy a demonstration REST API within the App Service. Meanwhile, I've set up thorough automated tests that run against the REST API from a virtual machine, created using Terraform right in the heart of the CI/CD pipeline.

### Tests
In crafting this pipeline, I've incorporated automated tests crafted with:

* *Postman* for API Testing (Integration Testing)
* *JMeter* for Performance Testing
* *Selenium* with Chromedriver for Functional UI Testing

The conclusive pipeline, detailed in the *azure-pipelines.yaml* file, walks you through effortlessly integrating these tests.

## Set up

## Dependencies

The following are the dependencies of the project you will need:

- Install the following tools:
  - [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
  - [Terraform](https://www.terraform.io/downloads.html)
  - [JMeter](https://jmeter.apache.org/download_jmeter.cgi)
  - [Postman](https://www.postman.com/downloads/)
  - [Python](https://www.python.org/downloads/)
  - [Selenium](https://www.selenium.dev/)

## Instructions

### Login with Azure CLI

To begin, initiate your Azure CLI session by executing: `az login`

## Run Packer image for VM

To supply the image for the Terraform-created VM, certain specifications must be set. Initially, you'll have to modify the variables outlined in the packer-image.json file:

```json
    "variables": {
        "subscription_id": "...",
        "tenant_id": "...",
        "client_id": "...",
        "client_secret": "...",   
        "resource_group_name": "...", 
        "image_name": "packer-image",
        "vm_size": "..."
    }
```

Once you've supplied the necessary variables, the VM image will be generated upon execution.
```cmd
packer build ./packer-image.json
```

If you wish to retrieve information from the created image afterward, execute the get_imageid.sh script located in terraform/environments/test/. Ensure that you update the credentials within the file:
```bash
subscription_id="..."
resource_group="..." # e.g. Azuredevops
image_name="packer-image"
```
![Packer Image](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/packer-init1.png)
![Packer Image BUILD](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/packerbuild1.png)

### Configure the storage account and state backend
Terraform facilitates the persistence of state in remote storage. Refer to the Tutorial: Store Terraform state in Azure Storage for comprehensive instructions, or adhere to the steps outlined below.

Begin by running the `create-tf-storage.sh` script:
```bash
bash create-tf-storage.sh
```
Be aware that this creates the tf storage specified in the file as
```bash
RESOURCE_GROUP_NAME="..." # e.g. Azuredevops
```

This will create a storage in the resource group saving the *tfstate* and provide relevant information for setting up the Terraform files, e.g. an access key for the storage.

After that, update `terraform/main.tf` with the Terraform storage account and state backend configuration variables:

- `storage_account_name`: The name of the Azure Storage account
- `container_name`: The name of the blob container
- `key`: The name of the state store file to be created

```bash
terraform {
  backend "azurerm" {
    storage_account_name = "tfstate..." # number of created tf storage
    container_name       = "tfstate" 
    key                  = "test.terraform.tfstate"
    access_key           = "..." # access key provided by the created tf storage
  }
}
```

If you wish to obtain the access key from the created image afterward, execute the *get_key.sh* script located in terraform/environments/test/. 
Be sure to update the credentials within the file:

```bash
STORAGE_ACCOUNT_NAME="tfstate..." # insert number of created tf storage
RESOURCE_GROUP="... " # e.g. Azuredevops
```

### Configuring Terraform

Please modify the following values in `terraform.tfvars` as needed:
```bash
# Azure subscription vars
subscription_id = "..." # service principal id
tenant_id = "..."
client_id = "..." # application id
client_secret = "..." # secret key

# Resource Group/Location
location = "..." # location where the resource group is located at
resource_group = "..." # e.g. Azuredevops
application_type = "..."

# Network
virtual_network_name = "..."
address_space = ["..."]
address_prefix_test = "..."

# VM
vm_admin_username = "..."
packer_image = "/subscriptions/.../resourceGroups/Azuredevops/providers/Microsoft.Compute/images/packer-image" # provide the same resource group as above (VM uses this image)
```

Also, generate an SSH key pair in the Azure command shell on https://portal.azure.com
```bash
ssh-keygen -t rsa
cat ~/.ssh/id_rsa.pub
```
Provide this key in terraform/modules/vm for *vm.tf*:
```bash
  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = "..." # starts with "ssh-rsa"
  }
```
### Executing Terraform

Terraform generates the subsequent resources for a designated environment tier:

-App Service
-App Service Plan
-Network
-Network Security Group
-Public IP
-Resource Group
-VM (utilizes the Packer image provided)

The CD pipeline will execute the following commands in terraform/environments/test to construct the infrastructure:
```bash
terraform init
terraform validate
terraform apply
```
### Setting up Azure DevOps

### Create a Service Principal for Terraform

A Service Principal is essentially an application within Azure Active Directory, and its authentication tokens can be utilized as the client_id, client_secret, and tenant_id fields required by Terraform (the subscription_id can be independently retrieved from your Azure account details). For detailed information, refer to Azure Provider: Authenticating using a Service Principal with a Client Secret.

Within Azure Pipelines, you have the flexibility to run parallel jobs on either Microsoft-hosted infrastructure or your own (self-hosted) infrastructure. In this project, I've configured a self-hosted agent. Follow these steps on Azure DevOps:

* Create a new project.
* Generate a personal access token (PAT) in Azure DevOps and locally store the PAT on your PC. This will be needed for setting up your agent on the VM for the "Build" step.
* Set up a service connection named `myServiceConnection` with access to all pipelines (Project -> Project settings).
* Create an agent pool named `myApplication` with access to all pipelines. Add an agent automatically with the Azure Resource Manager. Include this agent in a new VM within the same resource group, which will handle the "Build" step.
* Establish a new environment `test-vm` (Azure Pipelines -> Environments) and assign it to another new VM in the same resource group. This VM will handle the "Deploy" and "Test" phases.
* Create a new pipeline. Choose GitHub and select your GitHub repository. Configure the pipeline by opting for "Existing Azure Pipelines YAML File" and select the azure-pipelines.yaml file from the menu on the right.
![My Token](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/mytoken.png)
![MyServiceConecction](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/serviceconection-2.png)
![myAgent](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/myagentpool.png)
![myAgent](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/myagent-ok.png)
![myAgent](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/myagentok2.png)

On the Review page, ensure to update the Terraform variables:

```yaml
variables:
  python.version: '...' # Python version the VMs are running on
  azureServiceConnectionId: 'mySC'
  projectRoot: $(System.DefaultWorkingDirectory)
  environmentName: 'test-vm'
  tfstatenumber: 'tfstate...' # number of created tf storage
  tfrg: '...' # resource group for all files
  application_type: '...'  # name of the project given in dev.azure.com
```

Once the pipeline will run the "Build" step, it will provide the Terraform resources:
![terraform init](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/terraform-init1.png)
![terraform init2](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/terraform-init.png)
![terraform plan](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/terraform-plan1.png)
![terraform plan2](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/terraform-plan2.png)
![terraform apply](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/terraform-apply1.png)

When having run the pipeline up to the "Deploy" step, the FakeRestAPI will be deployed as an app service at URL defined at terraform/modules/appservice in *appservice.tf*:
```bash
name = "${var.application_type}-${var.resource_type}"
```

So if you use for instance 
```bash
application_type = "myapplication-project"
```

the web app will be named `project-qa-Appservice` and will be hosted at https://my-application-appservice.azurewebsites.net

When opening this URL after deployment, it will look like that:
![FastRestAPI](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/fakeapi.png)

### Automated testing

#### Integration testing with Postman

Screenshots of the Test Run Results from Postman shown in Azure DevOps:

* *Data Validation Test*: Ensures the integrity and accuracy of the data exchanged between the client and the server by verifying that the response received meets expected criteria 
![Postman Data Validation Test](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/postmanvalidation.png)

* *Regression Test*: Verifies that recent code changes have not adversely affected existing API functionalities by systematically retesting a suite of previously validated requests and ensuring they still produce the expected responses.
![Postman Regression Test](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/postmantest.png)

#### Performance testing with JMeter

Log outputs of JMeter when executed by the CI/CD pipeline:

* *Stress Test*: Evaluates the system's robustness and performance under high loads by simulating a large number of concurrent users or heavy transaction volumes to identify potential bottlenecks and assess system stability.
![Jmeter Stress Test](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/jmaterstresstest.png)
![Jmeter Stress Test Report](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/stressreport.png)

* *Endurance Test*: Measures the system's ability to sustain prolonged, continuous loads over an extended period, ensuring that performance remains stable and reliable under sustained usage conditions, helping to identify any gradual degradation or resource leaks.
![Jmeter Endurance Test](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/endurance.png)
![Jmeter Endurance Test](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/endurancereport.png)

#### Funktional UI testing with Selenium

The selenium test will be performed on a different web app (https://www.saucedemo.com/):
![Selenium Test](screenshots/selenium_test.png)


### Monitoring & Observability

### Azure Monitor

Go to the Azure Portal, select your application service and create a new alert in the "Monitoring" group:

Execute the Azure Pipeline to trigger an alert.

![Alerts](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/alerta.png)
![Appservice metrics "requests"](https://github.com/Camilafabiani87/cd1807-Project-Ensuring-Quality-Releases/blob/main/img/metricas-alerta.png)

### Configure Azure Log Analytics

#### Setting up custom logs

Download the *selenium-test.log* artifact from Azure Devops
![selenium-test.log Artifact](screenshots/seleniumlog_artifact.png)

Go to the Azure Portal to Azure Log Analytics workspaces and set up an agent on the VM the test step where the Selenium test will be performed and install an agent on it. For that, you need to connect this VM to Log Analytics and create a Data Collection Rule including the logs on it.
![Log Analytics connected VMs](screenshots/la_connectedVMs.png)
![Log Analytics connected Data sSts](screenshots/linuxsyslog.png)

Then go to ***Logs*** and create a new custom log. Upload *selenium-test.log*. Then select "Timestamp" `YYYY-MM-DD HH:MM:SS` as the record delimiter and add the path of *selenium-test.log* of the VM the step has been performed on as the log collections path (it can some time for the VM to be able to collect the logs).
![selenium log found on VM](screenshots/vm_seleniumlog.png)

![Log Analytics path for selenium-test.log Artifact](screenshots/linuxpath.png)

#### Querying custom logs

To query the custom logs, go to "Logs" in the "General" group of your Log Analytics workspace.

Select your custom log and run it:
![selenium.log Custom Log KQL](screenshots/selenium_cl.png)

## Clean-up

Destroy the Terraform resources:

```bash
cd terraform
terraform destroy
```



