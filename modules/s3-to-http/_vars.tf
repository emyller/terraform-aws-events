variable "name" {
  description = "A name to give the integration and resources created for it."
  type = string
}

variable "url" {
  description = "The URL of the API to receive callbacks to each event."
  type = string
}

variable "s3_paths" {
  type = map(string)
}
