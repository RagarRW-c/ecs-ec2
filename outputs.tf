output "alb_dns" {
  value = aws_lb.app.dns_name
}

output "ecs_cluster" {
  value = aws_ecs_cluster.this.name
}