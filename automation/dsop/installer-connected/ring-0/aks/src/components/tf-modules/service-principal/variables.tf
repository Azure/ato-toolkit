variable "tags" {
  description = "The set of tags to be used to add to all resources created"
  type        = map(string)
}

variable "name" {
  description = "A name used for this Service Principal"
  type        = string
}
