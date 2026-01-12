# deploy-poc.ps1

## these commands are primarily meant to be run by copying and pasting them into a local powershell session with the git repo already cloned to it.
## this allows for more controlled deployment for the POC
## for ease of quick deploy and destroy testing, parameters were added as switches to run the whole stack quickly
## this simulates a "poor mans pipeline" style deployment for a quick and dirty full deploy and destroy

## alternatively, the script can be run with a switch for creating
##    EX. ./deploy-poc.ps1 -create

## alternatively, the script can be run with a switch for destroying
##    EX. ./deploy-poc.ps1 -destroy

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [switch]$create = $false,

    [Parameter(Mandatory = $false)]
    [switch]$destroy = $false
)

##########################
###  Deployment Notes  ###
##########################

if ($create) {
    ## Bootstrap the deployment by creating an SP, Storage Account, and setting Terraform Env Variables
    . .\scripts\bootstrap-terraform.ps1

    ## Deploy Network
    set-location .\env\poc\network\
    terraform init -backend-config="./tfstate.tfbackend"
    terraform plan -out="atc-poc-network.plan"
    terraform apply "atc-poc-network.plan"

    ## Deploy Management
    set-location ..\mgmt\
    terraform init -backend-config="./tfstate.tfbackend"
    terraform plan -out="atc-poc-mgmt.plan" -var admin_password="Te5tPa552026!!!"
    terraform apply "atc-poc-mgmt.plan"

    ## Deploy Web
    set-location ..\web\
    terraform init -backend-config="./tfstate.tfbackend"
    terraform plan -out="atc-poc-web.plan" -var admin_password="Te5tPa552026!!!"
    terraform apply "atc-poc-web.plan"
}

###################################
###  Deployment Clean-up Notes  ###
###################################

if ($destroy) {
    ## Destroy Web (assumes starting in root repo directory)
    set-location .\env\poc\web\
    terraform destroy -var admin_password="Any5ecur3Pa55!!!" --auto-approve
    ## Destroy Mgmt
    set-location ..\mgmt\
    terraform destroy -var admin_password="Any5ecur3Pa55!!!" --auto-approve
    ## Destroy Network
    set-location ..\network\
    terraform destroy --auto-approve
    ## Clean-up default NetworkWatcherRG
    Remove-AzResourceGroup -Name NetworkWatcherRG -Force -AsJob
    ## Remove storage account resource group
    Remove-AzResourceGroup -Name rg-atc-poc-storage -Force -AsJob

    ## Remove service principal
    ## must re-auth with creds outside the SP to run this command
#    Remove-AzADServicePrincipal -DisplayName "sp-atc-deploy-01"
}

# EOF