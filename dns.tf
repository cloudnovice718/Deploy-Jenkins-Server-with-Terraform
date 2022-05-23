# Retrieve existing hosted zones
data "aws_route53_zone" "get_hosted_zones" {
  provider = aws.region-alpha
  name     = var.dns_name
}

# Create a DNS record in the hosted zone for ACM certificate domain verification 
resource "aws_route53_record" "validate_cert" {
  provider = aws.region-alpha
  for_each = {
    for val in aws_acm_certificate.jenkins_certificate.domain_validation_options : val.domain_name => {
      name   = val.resource_record_name
      record = val.resource_record_value
      type   = val.resource_record_type
    }
  }
  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.get_hosted_zones.zone_id
}

# Create an "A" type alias record
resource "aws_route53_record" "jenkins_alias_record" {
  provider = aws.region-alpha
  zone_id  = data.aws_route53_zone.get_hosted_zones.zone_id
  name     = join(".", ["jenkins", data.aws_route53_zone.get_hosted_zones.name])
  type     = "A"
  alias {
    name                   = aws_lb.jenkins_alb.dns_name
    zone_id                = aws_lb.jenkins_alb.zone_id
    evaluate_target_health = true
  }
}