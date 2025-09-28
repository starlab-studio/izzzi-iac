module "ecr-frontend" {
  source = "../../modules/ecr"

  name                 = "izzzi-frontend"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
}