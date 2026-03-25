variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  description = "SSH key name"
}

variable "ghcr_user" {
  description = "GitHub username (lowercase)"
}