# bootstrap-terraform.ps1

## this bootstraping script is extremely basic, requires credentials with at least Cloud Application Administrator role in Entra ID and Owner role on the Subscription
## future completion of the script headers and error handling would be notable improvements to make

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$sp_name = "sp-atc-deploy-01"
)

#########################
##  Service Principle  ##
#########################
## basic auth for single tenant and sub with no error handling
"Enter credentials with at least the Cloud Application Administrator role in Entra ID and the Owner role on the subscription. This will be used to create a deployment service principal and storage account for terraform deloyments."
$credential = Get-Credential
Connect-AzAccount -Credential $credential -ErrorAction stop | Out-Null

#########################
##  Service Principle  ##
#########################
## create new sp
$deploySp = Get-AzADServicePrincipal -DisplayName $sp_name
if (!$deploySp) {
    "Creating new deployment SP..."
    $deploySp          = New-AzADServicePrincipal -DisplayName $sp_name -Role "Contributor"
    $secret_plain_text = $deploySp.PasswordCredentials.SecretText
    $secret            = $secret_plain_text | ConvertTo-SecureString -AsPlainText -Force
    ## display deploySp secret value
    "SP Details (NOTE: save the secret value in a secured location, it will not be accessible outside this inital run)..."
    "Tenant ID: $($deploySp.AppOwnerOrganizationId)"
    "Client ID: $($deploySp.AppId)"
    "Secret ID: $($deploySp.PasswordCredentials.KeyId)"
    "*Secret* : $($secret_plain_text)"
    ## wait for new creds to apply
    "Waiting 30 seconds for SP access on subscription to complete..."
    Start-Sleep -Seconds 30
} else {"SP Secret is required for existing SP named $sp_name. Please enter it now:"
    $secret_plain_text = Read-Host "Secret"
    $secret            = $secret_plain_text | ConvertTo-SecureString -AsPlainText -Force
}

"Connecting to Azure with SP..."
## re-auth as the new sp
$appId      = $deploySp.AppId
$tenantId   = (Get-AzContext).Tenant.Id
$subId      = (Get-AzContext).Subscription.Id
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $appId, $secret
Connect-AzAccount -ServicePrincipal -Credential $credential -TenantId $tenantId -ErrorAction Stop
if (!(Get-AzContext).Subscription.Id) {
    "Initial authentication failed, retrying after 30 seconds in case new service principal creation has not fully completed..."
    ## wait another 30 seconds if the connect failed
    Start-Sleep -Seconds 30
    Connect-AzAccount -ServicePrincipal -Credential $credential -TenantId $tenantId -ErrorAction Stop
    if (!(Get-AzContext).Subscription.Id) {
        "Error: authentication failed; check the service principal used and try this script again."
        Break
    } else {
        "Authentication successful."
    }
} else {
    "Authentication successful."
}

#######################
##  Storage Account  ##
#######################
## new rg, sa, & containers
$rgLocation      = "westus2"
$rgName          = "rg-atc-poc-storage"
$saName          = "statcpoc1xxxxx"
$saContainerNames = @("terraformstate", 
                      "weblogs"
                    )
"Obtaining local IP for whitelisting to deployment storage account..."
$ip_whitelist    = "$(curl -4 "http://ifconfig.me/ip")"
"Configuring storage account for terraform state file..."
## create deploy resource group
$deployRG = Get-AzResourceGroup -Name $rgName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
if (!$deployRG) {$deployRG = New-AzResourceGroup -Location $rgLocation -Name $rgName}
## create deploy storage account
$deploySA = Get-AzStorageAccount -ResourceGroupName $rgName -AccountName $saName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
if (!$deploySA) {
  ## create deploy SA and whitelist the creators IP address
  $deploySA = New-AzStorageAccount -ResourceGroupName $rgName -AccountName $saName -Location $rgLocation -SkuName Standard_GRS -Kind StorageV2 -AccessTier Hot -MinimumTlsVersion TLS1_2 -AllowBlobPublicAccess $false -NetworkRuleSet (@{bypass="AzureServices,Logging,Metrics";IpRules=(@{IPAddressOrRange=$ip_whitelist;Action="allow"});defaultAction="deny"}) 
  ## set versioning and soft delete settings
  Update-AzStorageBlobServiceProperty -ResourceGroupName $rgName -StorageAccountName $saName -IsVersioningEnabled $true
  Enable-AzStorageBlobDeleteRetentionPolicy -ResourceGroupName $rgName -StorageAccountName $saName -RetentionDays 7
}
## create containers
foreach ($saContainerName in $saContainerNames) {
    $storage_container = $deploySA | New-AzStorageContainer -Container $saContainerName -ErrorAction SilentlyContinue
}

#########################################
##  Azure SP PS Environment Variables  ##
#########################################
## set env vars for sp use in terraform
$env:ARM_SUBSCRIPTION_ID = $subId
$env:ARM_CLIENT_ID       = $appId
$env:ARM_TENANT_ID       = $tenantId
$env:ARM_CLIENT_SECRET   = $secret_plain_text
## display variables
"Current environment variables set for Terraform deployment"
"ARM_TENANT_ID        = $($env:ARM_TENANT_ID)"
"ARM_CLIENT_ID        = $($env:ARM_CLIENT_ID)"
"ARM_CLIENT_SECRET    = $($env:ARM_CLIENT_SECRET)"
"ARM_SUBSCRIPTION_ID  = $($env:ARM_SUBSCRIPTION_ID)"

# EOF