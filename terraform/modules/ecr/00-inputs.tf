variable "name" {
  type = string
  description = "Name of the repository"
}

variable "image_tag_mutability" {
  type = string
  description = "The tag mutability setting for the repository"
  default = "MUTABLE"
}

variable "scan_on_push" {
  type = bool
  description = "The boolean that defines image scanning for the repository"
  default = true
}