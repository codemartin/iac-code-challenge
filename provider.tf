terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    docker = {
      source = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "kubernetes" {}

/*
running this on windows so its a bit buggy per 
https://github.com/hashicorp/terraform-provider-docker/issues/180

using docker for windows workaround instead.... or maybe its my computer 

provider "docker" {
  alias = "kreuzwerker"

  registry_auth {
    address = "https://index.docker.io/v1/"
    auth    = base64encode(file("${path.module}/docker_credentials.txt"))
  }
}
*/
provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
}
