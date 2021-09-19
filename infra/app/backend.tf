terraform {
 
  backend "s3" {
    bucket = "esteban-challenge"
    key    = "states/challenge-app-state"
    region = "us-east-2"
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-2"
}
