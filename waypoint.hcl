project = "better-chef-rundeck-docker"

app "better-chef-rundeck" {
  labels = {
    "service" = "better-chef-rundeck",
    "env" = "dev"
  }

  build {
    use "docker" {}
  }

  deploy { 
    use "docker" {
        service_port = 3000
    }
  }
}
