resource "kubernetes_deployment" "echo" {
  metadata {
    name      = "echo"
    namespace = "debug"
    labels = {
      app = "echo"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "echo"
      }
    }

    template {
      metadata {
        labels = {
          app = "echo"
        }
      }

      spec {
        container {
          name  = "echo"
          image = "ealen/echo-server:latest"

          port {
            container_port = 80
          }

          env {
            name  = "PORT"
            value = "80"
          }

          resources {
            requests = {
              cpu    = "10m"
              memory = "32Mi"
            }
            limits = {
              memory = "64Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "echo" {
  metadata {
    name      = "echo"
    namespace = "debug"
  }

  spec {
    selector = {
      app = "echo"
    }

    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kustomization_resource" "debug_httproute" {
  manifest = jsonencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "echo"
      namespace = "debug"
    }
    spec = {
      parentRefs = [{
        name        = "default"
        namespace   = "gateway-system"
        sectionName = "https"
      }]
      hostnames = ["debug.leogues.com.br"]
      rules = [{
        matches = [{
          path = {
            type  = "PathPrefix"
            value = "/"
          }
        }]
        backendRefs = [{
          name = "echo"
          port = 80
        }]
      }]
    }
  })

  depends_on = [
    module.nginx_gateway,
    kubernetes_service.echo,
  ]
}
