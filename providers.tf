provider "aws" {
  profile = var.profile
  region  = var.region-alpha
  alias   = "region-alpha"
}

provider "aws" {
  profile = var.profile
  region  = var.region-bravo
  alias   = "region-bravo"
}