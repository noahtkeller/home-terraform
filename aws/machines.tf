resource aws_instance k8s-master {
  subnet_id = aws_subnet.worker_subnet.id
  ami = data.aws_ami.kubernetes-master.id
  instance_type = "t2.medium"
  associate_public_ip_address = true
  private_ip = "172.31.0.22"
  key_name = "noahhome"

  tags = {
    Name = "k8s-master-0"
  }
}

output k8s_master_ip_addr {
  value = aws_instance.k8s-master.public_ip
}

resource aws_instance k8s-worker-0 {
  subnet_id = aws_subnet.worker_subnet.id
  ami = data.aws_ami.kubernetes-worker.id
  instance_type = "t2.small"
  associate_public_ip_address = true
  private_ip = "172.31.0.7"
  key_name = "noahhome"

  tags = {
    Name = "k8s-worker-0"
  }
}

output k8s_worker_0_ip_addr {
  value = aws_instance.k8s-worker-0.public_ip
}

resource aws_instance k8s-worker-1 {
  subnet_id = aws_subnet.worker_subnet.id
  ami = data.aws_ami.kubernetes-worker.id
  instance_type = "t2.small"
  associate_public_ip_address = true
  private_ip = "172.31.0.8"
  key_name = "noahhome"

  tags = {
    Name = "k8s-worker-1"
  }
}

output k8s_worker_1_ip_addr {
  value = aws_instance.k8s-worker-1.public_ip
}
