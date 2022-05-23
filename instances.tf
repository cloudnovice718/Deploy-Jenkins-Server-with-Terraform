# Retrieve AMI ID using SSM Parameter store in the Alpha region
data "aws_ssm_parameter" "amiAlpha" {
  provider = aws.region-alpha
  name     = var.ami_name
}

# Retrieve AMI ID using SSM Parameter store in the Bravo region
data "aws_ssm_parameter" "amiBravo" {
  provider = aws.region-bravo
  name     = var.ami_name
}

# Create a key pair for EC2 instances in the Alpha region
resource "aws_key_pair" "alpha_region_key_pair" {
  provider   = aws.region-alpha
  key_name   = "jenkins_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create a key pair for EC2 instances in the Bravo region
resource "aws_key_pair" "bravo_region_key_pair" {
  provider   = aws.region-bravo
  key_name   = "jenkins_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Deploy an EC2 instance in the Alpha region
resource "aws_instance" "jenkins_master_instance" {
  provider                    = aws.region-alpha
  ami                         = data.aws_ssm_parameter.amiAlpha.value
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.alpha_region_key_pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_master_sg.id]
  subnet_id                   = aws_subnet.subnet_1_alpha.id

  tags = {
    Name = "jenkins_master_instance"
  }

  depends_on = [aws_main_route_table_association.vpc_alpha_rt_assoc]

# Establish a remote connection to the Jenkins Master node
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip

  }

# Copy files from local machine to Jenkins Master node
  provisioner "file" {
    source      = "ansible_files/jenkins_master_bootstrap.yml"
    destination = "/home/ec2-user/jenkins_master_bootstrap.yml"
  }

  provisioner "file" {
    source      = "ansible_files/jenkins_install_master_node.yml"
    destination = "/home/ec2-user/jenkins_install_master_node.yml"
  }

  provisioner "file" {
    source      = "ansible_files/jenkins_install_vars.yml"
    destination = "/home/ec2-user/jenkins_install_vars.yml"
  }  

# Run commands on the Jenkins master node once previous files have finished copying over
  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install ansible2 -y",
      "ansible-playbook jenkins_master_bootstrap.yml",
      "ansible-playbook jenkins_install_master_node.yml",
    ]
  }
}

# Deploy an EC2 instance in the Bravo region
resource "aws_instance" "jenkins_worker_instance" {
  provider                    = aws.region-bravo
  count                       = var.workers_count
  ami                         = data.aws_ssm_parameter.amiBravo.value
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.bravo_region_key_pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_worker_sg.id]
  subnet_id                   = aws_subnet.subnet_1_bravo.id

  tags = {
    Name = join("_", ["jenkins_worker_instance", count.index + 1])
    Jenkins_Master_Private_IP = aws_instance.jenkins_master_instance.private_ip
  }

  depends_on = [aws_main_route_table_association.vpc_bravo_rt_assoc, aws_instance.jenkins_master_instance]


# Establish a remote connection to the Jenkins worker node
# Copy files from local machine to Jenkins worker node
# Run commands on the Jenkins worker node once previous files have finished copying over
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip

  }

  provisioner "file" {
    source      = "ansible_files/jenkins_worker_bootstrap.yml"
    destination = "/home/ec2-user/jenkins_worker_bootstrap.yml"
  }

  provisioner "file" {
    source      = "ansible_files/jenkins_install_worker_node.yml"
    destination = "/home/ec2-user/jenkins_install_worker_node.yml"
  }

  provisioner "file" {
    source      = "ansible_files/jenkins_install_vars.yml"
    destination = "/home/ec2-user/jenkins_install_vars.yml"
  }   

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install ansible2 -y",
      "ansible-playbook jenkins_worker_bootstrap.yml",
      "ansible-playbook jenkins_install_worker_node.yml --extra-vars 'jenkins_ip=${self.tags.Jenkins_Master_Private_IP}'",
    ]
  }

/*  provisioner "remote-exec" {
    when = destroy
    inline = [
      "java -jar /home/ec2-user/jenkins-cli.jar -auth @/home/ec2-user/jenkins_auth_file -s http://${self.tags.Jenkins_Master_Private_IP}:8080 ${self.private_ip}"
    ]    
  }*/

}




