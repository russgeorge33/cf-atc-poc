# Coalfire Azure Technical Challenge
**Submission for Russell George** 

## Summary
These scripts are quick and dirty ways to bootstrap the deployment as well as complete a full deploy create or destroy

---
## bootstap-terraform.ps1 overview
- this script can be run to:
    - first, create a deloyment service principal
    - then, auth with that SP
    - then, create a storage account for terraform state files
    - then, setup terraform environment variables for terraform deployment without az cli login

## deploy-poc.ps1 overview
- the commands within this file were primarily meant to be run by copying and pasting them into a local powershell session with the git repo already cloned to it.
    - this allows for a controlled deployment for the POC and deploys each section of the environment as detailed in the primary README.md file in this repo
- alternatively, for ease of quick deploy and destroy testing, parameters were added as switches to run the whole stack quickly
    - this simulates a "poor mans pipeline" style deployment for a quick and dirty full deploy and destroy
    - thus, the script can be run with a switch for creating
        - EX. `. ./deploy-poc.ps1 -create`
    - and, the script can be run with a switch for destroying
        - EX. `. ./deploy-poc.ps1 -destroy`
---