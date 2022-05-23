# Create security group rules for the ELB
resource "aws_security_group" "elb_sg" {
  provider    = aws.region-alpha
  name        = "elb_sg"
  description = "Enable port 443 and allow traffic to Jenkins Master"
  vpc_id      = aws_vpc.vpc_alpha.id
  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.external_ip]
  }
}

# Security group rules for Jenkins Master
resource "aws_security_group" "jenkins_master_sg" {
  provider    = aws.region-alpha
  name        = "jenkins_master_sg"
  description = "Allow ports 8080 and 22"
  vpc_id      = aws_vpc.vpc_alpha.id
  ingress {
    description = "Allow SSH traffic from public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description     = "Enable port 8080"
    from_port       = var.web_port
    to_port         = var.web_port
    protocol        = "tcp"
    security_groups = [aws_security_group.elb_sg.id]
  }
  ingress {
    description = "Allow traffic from Bravo region"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_bravo_cidr_block]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.external_ip]
  }
}

# Create security group rules for the Jenkins Worker
resource "aws_security_group" "jenkins_worker_sg" {
  provider    = aws.region-bravo
  name        = "jenkins_worker_sg"
  description = "Enable ports 8080 and 22"
  vpc_id      = aws_vpc.vpc_bravo.id
  ingress {
    description = "Allow SSH traffic from public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow traffic from VPC Alpha"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_alpha_cidr_block]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.external_ip]
  }
}