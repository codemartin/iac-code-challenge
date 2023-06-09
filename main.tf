# Create a new namespace
resource "kubernetes_namespace" "nginx_namespace" {
  metadata {
    name = var.namespace_name
  }
}

# Build a new nginx image with a custom nginx.conf via Dockerfile
resource "docker_image" "nginx_image" {
  name = "nginx"

  build {
    path       = "."
    dockerfile = "${path.module}/Dockerfile"
  }
}

# Create 2 Replicaset with 0.5vcpu & 512Mi Limit and ClusterIP + Port 8080
resource "kubernetes_deployment" "nginx_deployment" {
  metadata {
    name      = "nginx-deployment"
    namespace = kubernetes_namespace.nginx_namespace.metadata.0.name

    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = var.replica_count

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = docker_image.nginx_image.name

          resources {
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
          }

          port {
            container_port = 80
            name           = "http"
            protocol       = "TCP"
          }

          volume_mount {
            name       = "nginx-pvc"
            mount_path = "/var/log/nginx"
          }

          args = ["-g", "daemon off;"]
        }

        volume {
          name = "nginx-pvc"

          persistent_volume_claim {
            claim_name = "nginx-pvc"
          }
        }
      }
    }
  }
}

# Create a 1 Persistent Volume with 2Gi capacity and local file path
resource "kubernetes_persistent_volume" "nginx_persistent_volume" {
  metadata {
    name = "nginx-pv"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    capacity = {
      storage = var.pvc_capacity
    }

    persistent_volume_source {
      local {
        path = var.pvc_path
      }
    }

    storage_class_name = "local-storage"
  }
}

# Create a persistent volume claim for nginx
resource "kubernetes_persistent_volume_claim" "nginx_pvc" {
  metadata {
    name      = "nginx-pvc"
    namespace = kubernetes_namespace.nginx_namespace.metadata.0.name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.pvc_capacity
      }
    }

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    storage_class_name = "local-storage"
  }
}
