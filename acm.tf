# Create certificate using ACM and request validation through Route53 service
resource "aws_acm_certificate" "jenkins_certificate" {
  provider          = aws.region-alpha
  domain_name       = join(".", ["jenkins", data.aws_route53_zone.get_hosted_zones.name])
  validation_method = "DNS"
  tags = {
    Name = "jenkins_certificate"
  }
}

# Validating the certificate issued by the ACM via Route53
resource "aws_acm_certificate_validation" "confirm_validation" {
  provider                = aws.region-alpha
  certificate_arn         = aws_acm_certificate.jenkins_certificate.arn
  for_each                = aws_route53_record.validate_cert
  validation_record_fqdns = [aws_route53_record.validate_cert[each.key].fqdn]
}