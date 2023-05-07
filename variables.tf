variable "project_id" {
  type    = string
  default = "<your_project_id>"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "namespace_name" {
  type    = string
  default = "nginx-namespace"
}

variable "replica_count" {
  type    = number
  default = 2
}

variable "cpu_limit" {
  type    = string
  default = "500m"
}

variable "memory_limit" {
  type    = string
  default = "512Mi"
}

variable "pvc_capacity" {
  type    = string
  default = "2Gi"
}

variable "pvc_path" {
  type    = string
  default = "./pvc"
}
