# terraform-express-route-direct

## Overview

This terraform code provides a sample list of required resources in order to provision ExpressRoute Direct on Azure whilst leveraging a traditional Azure Virtual Network Gateway rather than a vWan architecture.

This code can not be run all at once due to provider dependencies, as such the files have been split into two sections, pre-circuit.tf and post-circuit.tf. In the event that API access has been provided by the circuit provider then Terraform can be used to enable the ExpressRoute Port at the provider's end thus allowing for a continues deployment to run, ensuring dependencies have been built into the Terraform resources.

## Disclaimer

This code is provides as-is and has not been validated. Execute at your own risk. 
