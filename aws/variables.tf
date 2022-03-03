variable region {
  type = string
  default = "us-east-1"
}

variable default-availability-zone {
  type = string
  default = "us-east-1f"
}

variable release {
  type = string
  default = "focal"
}

variable distro {
  type = string
  default = "ubuntu"
}

data aws_ami kubernetes-master {
  most_recent = true

  filter {
    name = "name"
    values = ["${var.distro}-${var.release}-k8s-master"]
  }

  owners = ["self"]
}

data aws_ami kubernetes-worker {
  most_recent = true

  filter {
    name = "name"
    values = ["${var.distro}-${var.release}-k8s-worker"]
  }

  owners = ["self"]
}

output ssh_username {
  value = var.distro
}
