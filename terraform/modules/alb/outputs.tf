output "alb_dns_name" {
    value = aws_lb.elk.dns_name
}
output "target_group_arn" {
    value = aws_lb_target_group.kibana.arn
}