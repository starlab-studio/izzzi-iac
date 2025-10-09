terraform {
  backend "s3" {
    bucket       = "izzzi-terraform-backend"
    key          = "izzzi.tfstate"
    region       = "eu-west-3"
    profile      = "izzzi/starlab"
    use_lockfile = true
  }
}
