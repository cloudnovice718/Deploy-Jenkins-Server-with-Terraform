# Information to be displayed on the CLI after terraform apply is completed
output "jenkins_master_instance_public_ip" {
  value = aws_instance.jenkins_master_instance.public_ip
}

output "jenkins_worker_instance_public_ip_addrs" {
  value = {
    for instance in aws_instance.jenkins_worker_instance :
    instance.id => instance.public_ip
  }
}

output "alb_dns_name" {
  value = aws_lb.jenkins_alb.dns_name
}

output "url" {
  value = aws_route53_record.jenkins_alias_record.fqdn
}