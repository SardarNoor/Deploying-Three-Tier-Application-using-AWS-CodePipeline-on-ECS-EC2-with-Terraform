output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
output "docdb_endpoint" {
  value = aws_docdb_cluster.docdb.endpoint
}
