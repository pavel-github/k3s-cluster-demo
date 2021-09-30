variable "cloudsigma_username" {
  type        = string
  description = "The CloudSigma user email address."
}

variable "cloudsigma_password" {
  type        = string
  description = "The CloudSigma user password."
}

variable "cloudsigma_location" {
  type        = string
  default     = "zrh"
  description = "The CloudSigma location. Default value is zrh."
}

variable "private_key" {
  type        = string
  description = "The path to SSH private key. Note, this must be loaded using the the file function!"
  sensitive   = true
}
variable "public_key" {
  type        = string
  description = "The path to SSH public key. Note, this must be loaded using the the file function!"
  sensitive   = true
}
