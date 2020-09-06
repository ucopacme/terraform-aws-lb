# Load balancer ID
output "id" {
  value = join("", aws_lb.this.*.id)
}

# Load balancer arn
output "arn" {
  value = join("", aws_lb.this.*.arn)
}

# Load balancer dns name
output "dns_name" {
  value = join("", aws_lb.this.*.dns_name)
}
