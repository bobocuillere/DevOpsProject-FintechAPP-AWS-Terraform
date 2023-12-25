output "grafana_instance_id" {
  value = aws_instance.grafana.id
}

output "grafana_instance_ip" {
  value = aws_instance.grafana.public_ip
}

output "prometheus_instance_id" {
  value = aws_instance.prometheus.id
}

output "prometheus_instance_ip" {
  value = aws_instance.prometheus.public_ip
}
