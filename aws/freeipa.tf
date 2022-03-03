# Notes:
# You'll need to update any references to 'module.vpc' with your VPC's info (subnets, security groups, etc)
# If you define your subnets as a map, this will deploy different replicas across availabity zones. Note
# that the master and first replica will be in the same AZ.
#
# Look through the 'connection' fields and update with your bastion_host/key combos
#

variable ipa_replicas {
  default = 0
}

variable ipa_password {
  default = "password"
}

variable ipa_domain {
  default = "noahtkeller.dev"
}

variable ipa_realm {
    default = "NOAHTKELLER.DEV"
}

data aws_ami base-ami {
  most_recent = true

  filter {
    name = "name"
    values = ["${var.distro}-${var.release}-base"]
  }

  owners = ["self"]
}

variable ipa_key {
  default = "some_private_key"
}

resource "aws_instance" "ipa_master" {
  ami               = data.aws_ami.base-ami
  instance_type     = "t2.medium"
  key_name          = var.ipa_key
  availability_zone = module.vpc.vpc_private_subnet_zones[count.index]
  subnet_id         = module.vpc.vpc_private_subnet_ids[count.index]

  vpc_security_group_ids = [aws_security_group.vpc_private.id]

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = 128
  }

  tags {
    Name = "FreeIPA Master"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y freeipa-server",
      "sudo ipa-server-install -U --no-host-dns -a ${var.ipa_password} --hostname=${element(aws_instance.ipa_master.*.private_dns,count.index)} -n ${var.ipa_domain} -p ${var.ipa_password} -r ${var.ipa_realm}",
    ]

    connection {
      host                = "${element(aws_instance.ipa_master.*.private_ip,count.index)}"
      user                = "centos"
      private_key         = "${file("${var.ssh_keys}/${element(aws_instance.ipa_master.*.key_name,count.index)}.pem")}"
      bastion_host        = "${var.bastion_host}"
      bastion_user        = "${var.bastion_user}"
      bastion_private_key = "${file("${var.ssh_keys}/${var.bastion_private_key}")}"
    }
  }
}

# IPA Replicas
resource "aws_instance" "ipa_replica" {
  count                  = var.ipa_replicas
  ami                    = data.aws_ami.base-ami
  instance_type          = "t2.medium"
  key_name               = var.ipa_key
  availability_zone      = module.vpc.vpc_private_subnet_zones[count.index]
  subnet_id              = module.vpc.vpc_private_subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.vpc_private.id]

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = 128
  }

  tags {
    Name         = "FreeIPA Replica - ${count.index + 1}"
    ClusterIndex = count.index
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install ipa-client",
      "sudo ipa-client-install --unattended --force --domain=${var.ipa_domain} --server=${aws_instance.ipa_master.private_dns} --realm=${var.ipa_realm} --ssh-trust-dns --principal=admin --mkhomedir -w ${var.ipa_password}",
      "sudo yum install -y freeipa-server",
      "sudo ipa-replica-install --password=${var.ipa_password} --admin-password=${var.ipa_password} --ssh-trust-dns --setup-ca --no-host-dns",
    ]

    connection {
      host                = "${element(aws_instance.ipa_replica.*.private_ip,count.index)}"
      user                = "centos"
      private_key         = "${file("${var.ssh_keys}/${element(aws_instance.ipa_replica.*.key_name,count.index)}.pem")}"
      bastion_host        = "${var.bastion_host}"
      bastion_user        = "${var.bastion_user}"
      bastion_private_key = "${file("${var.ssh_keys}/${var.bastion_private_key}")}"
    }
  }
}

# Route 53 DNS entries
#resource "aws_route53_record" "ipa_hosts" {
#  zone_id = "${aws_route53_zone.vpc_private.zone_id}"
#  name    = "ipa.${aws_route53_zone.vpc_private.name}"
#  type    = "A"
#  ttl     = "60"
#  records = ["${aws_instance.ipa_master.*.private_ip}", "${aws_instance.ipa_replica.*.private_ip}"]
#}
