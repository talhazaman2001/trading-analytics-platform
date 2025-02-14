output "alb_dns_name" {
    description = "DNS name of the Application Load Balancer"
    value = module.alb.alb_dns_name
}

output "kibana_url" {
    description = "URL to access Kibana"
    value = "http://${module.alb.alb_dns_name}:5601"
}

output "elasticsearch_endpoint" {
    description = "Elasticsearch endpoint"
    value = "http://${module.alb.alb_dns_name}:9200"
}