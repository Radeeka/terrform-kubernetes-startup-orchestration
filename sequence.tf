resource "kubernetes_job" "pi" {
  metadata {
    name = "pi"
  }

  spec {
    backoff_limit = 4

    template {
      metadata {}

      spec {
        container {
          name    = "pi"
          image   = "perl:5.34.0"
          command = ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
        }

        restart_policy = "Never"
      }
    }
  }
}

resource "null_resource" "wait_for_job" {
  depends_on = [kubernetes_job.pi]
  #name = "wait_for_job"

  provisioner "local-exec" {
    # Start the Kubernetes job.
    #command = "kubectl apply -f job.yaml"

    # Wait for the job to complete.
    # Replace "job-name" with the name of your job.
    # This assumes that the job creates a Kubernetes pod.
    # You may need to adjust this command to match your use case.
    command = "kubectl wait --for=condition=complete --timeout=600s job/${kubernetes_job.pi.metadata[0].name}"
  }
}

resource "kubernetes_pod" "nginx" {
  depends_on = [null_resource.wait_for_job]
  metadata {
    name = "nginx"

    labels = {
      run = "nginx"
    }
  }

  spec {
    container {
      name  = "nginx"
      image = "nginx"
    }

    restart_policy = "Always"
    dns_policy     = "ClusterFirst"
  }
}