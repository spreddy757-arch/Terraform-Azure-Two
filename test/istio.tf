# Istio service mesh installed via Helm with default chart values
# This should be applied after the AKS cluster is stable

# Istio system namespace
resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
    labels = {
      "app.kubernetes.io/name" = "istio"
      environment              = var.environment
    }
  }

  depends_on = [time_sleep.wait_for_cluster]
}

# Istio base chart (CRDs and cluster roles)
resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name

  timeout = 600
  wait    = true

  depends_on = [kubernetes_namespace.istio_system]
}

# Istiod control plane
resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name

  timeout       = 600
  wait          = true
  wait_for_jobs = true

  depends_on = [helm_release.istio_base]
}
