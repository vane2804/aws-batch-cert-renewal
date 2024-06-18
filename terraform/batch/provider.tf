provider "aws" {  
  region     = var.region  
}

data "terraform_remote_state" "efs" {

  backend = "local"  
  config = {    
    path = "../terraform/efs/terraform.tfstate"  
  }
  
}
