variable "region" {
  type    = string
  default = "WESTERN_EUROPE"
}

variable "project_id" {
  type    = string
  default = "rrt"

}

variable "provider_name" {
  type    = string
  default = "GCP"
}
variable "cluster_type" {
  type    = string
  default = "REPLICASET"
}

variable "instance_size" {
  type    = string
  default = "M10"
}

variable "node_count" {
  type    = number
  default = 3
}
