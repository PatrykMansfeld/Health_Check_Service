terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop"
}

resource "kubernetes_config_map" "health_check_config" {
  metadata {
    name = "health-check-config"
  }

  data = {
    APP_ENV = "production"
  }
}

resource "kubernetes_deployment" "health_check_deployment" {
  metadata {
    name = "health-check-deployment"
    labels = {
      app = "health-check-service"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "health-check-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "health-check-service"
        }
      }

      spec {
        container {
          name  = "health-check-container"
          image = "health-check-service"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 8080
          }

          env {
            name = "APP_ENV"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.health_check_config.metadata[0].name
                key  = "APP_ENV"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "health_check_service" {
  metadata {
    name = "health-check-service"
    labels = {
      app = "health-check-service"
    }
  }

  spec {
    type = "NodePort"

    selector = {
      app = "health-check-service"
    }

    port {
      name        = "http"
      port        = 8080
      target_port = 8080
      node_port   = 30080
    }
  }
}
