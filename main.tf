# Create a new namespace
resource "kubernetes_namespace" "nginx_namespace" {
  metadata {
    name = var.namespace_name
  }
}

# Build a new nginx:latest image with a custom nginx.conf via Dockerfile
resource "docker_image" "nginx_image" {
  name         = "nginx"
  build {
    context    = "${path.module}/"
    dockerfile = "${path.module}/Dockerfile"
  }
}

# Create 2 Replicaset with 0.5vcpu & 512Mi Limit and ClusterIP + Port 8080
resource "kubernetes_replica_set" "nginx_replica_set" {
  metadata {
    name      = "nginx-replica-set"
    namespace = kubernetes_namespace.nginx_namespace.metadata.0.name
    labels = {
      app = "nginx"
    }
  }

  spec {
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
          image = docker_image.nginx_image.latest
          name  = "nginx"

          resources {
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
          }

          ports {
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

    replicas = var.replica_count
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

    local {
      path = var.pvc_path
    }

    storage_class_name = "local-storage"
  }
}

# Create a persistent volume claim for nginx
resource "kubernetes_persistent_volume_claim" "nginx_pvc" {
  metadata {
    name      = "nginx-pvc"
    namespace = kubernetes_namespace.ng
