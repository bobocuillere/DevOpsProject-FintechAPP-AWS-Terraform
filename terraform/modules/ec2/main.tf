data "aws_ami" "latest_redhat" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-8*"]
  }
}

resource "aws_instance" "grafana" {
  ami                    = data.aws_ami.latest_redhat.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[0]
  key_name               = var.key_pair_name
  vpc_security_group_ids = [var.monitoring_sg_id]

  tags = merge(
    var.common_tags,
    {
      "Name" = "Grafana-Server"
    }
  )
}

resource "aws_instance" "prometheus" {
  ami                    = data.aws_ami.latest_redhat.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[0]
  key_name               = var.key_pair_name
  vpc_security_group_ids = [var.monitoring_sg_id]

  tags = merge(
    var.common_tags,
    {
      "Name" = "Prometheus-Server"
    }
  )
}

# EBS Volumes for Grafana and Prometheus
resource "aws_ebs_volume" "grafana_ebs" {
  availability_zone = aws_instance.grafana.availability_zone
  size              = var.ebs_volume_size

  tags = merge(
    var.common_tags,
    {
      "Name" = "Grafana-EBS"
    }
  )
}

resource "aws_ebs_volume" "prometheus_ebs" {
  availability_zone = aws_instance.prometheus.availability_zone
  size              = var.ebs_volume_size
  tags = merge(
    var.common_tags,
    {
      "Name" = "Prometheus-EBS"
    }
  )
}

# Attach EBS Volumes
resource "aws_volume_attachment" "grafana_ebs_attachment" {
  device_name  = "/dev/sdh"
  volume_id    = aws_ebs_volume.grafana_ebs.id
  instance_id  = aws_instance.grafana.id
  force_detach = true
}

resource "aws_volume_attachment" "prometheus_ebs_attachment" {
  device_name  = "/dev/sdh"
  volume_id    = aws_ebs_volume.prometheus_ebs.id
  instance_id  = aws_instance.prometheus.id
  force_detach = true
}
