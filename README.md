# Deploying a Jenkins Server with Terraform
Inspired by a tutorial I came across from ACloudGuru (https://learn.acloud.guru/course/8a6f598f-a41f-48ff-99a6-2c7a760b4119/dashboard). This project builds a Jenkins server using AWS and Terraform. I rewrote a majority amount of the original code from scratch to improve efficency and resolve issues I discovered during testing.

The infrastructure consists of:

a) A peering connection between two VPCs ("VPC-Alpha" based in US-East-1 and "VPC-Bravo" based in US-West-2)

b) Two subnets for VPC-Alpha (One in each Availability Zone) and a single subnet for VPC-Bravo

c) Internet Gateway and Route Table in each region

d) Jenkins Master and Worker EC2 instances provisioned in VPC-Alpha and VPC-Bravo respectively

e) Application Load Balancer in US-East-1 to route traffic to the Jenkins Master instance via an Instance-type Target Group

f) Registered domain (cloudnovice718.com) and hosted zone for DNS routing

g) SSL certificate provided by AWS via Certificate Manager to ensure secure access

h) Configuration management of Jenkins nodes using Ansible 

# Completed deployment (Desktop)
![jenkins-website-desktop](https://user-images.githubusercontent.com/81878657/169739973-4ce93717-f97e-4550-ac29-b66b4f1a639c.png)
# Completed deployment (Mobile)
![jenkins-website-mobile](https://user-images.githubusercontent.com/81878657/169739976-0c3fe5fb-bfee-434a-941d-b3e4b0e8ff2a.jpeg)
