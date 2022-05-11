variable "name" {
  description = "A name to give the integration and resources created for it."
  type = string
}

variable "url" {
  description = "The URL of the API to receive callbacks to each event."
  type = string
}

variable "s3_paths" {
  description = "A map of S3 paths to listen to, labelled after their context."
  type = map(string)
}
