provider "aws" {
  region = local.region
}

locals {
    name   = "FactoryDigital_Devops_test"
    region = "eu-west-3"
    instance_type = "t2.micro"


  tags = {
    Owner       = "Abdelnasser"
    Environment = "testing"
  }
}



################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = local.name
  cidr = "10.99.0.0/18"

  azs              = ["${local.region}a"]
  public_subnets   = ["10.99.0.0/24"]

  enable_ipv6 = true
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = local.tags
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = local.name
  description = "Security group allowing http, https and ssh traffic"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

  tags = local.tags
}


resource "tls_private_key" "deployer_priv_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer_pub_key" {
  key_name   = "deployer-pub-key"
  public_key = tls_private_key.deployer_priv_key.public_key_openssh
}

resource "local_file" "deployer_priv_key_file" {
  content = tls_private_key.deployer_priv_key.private_key_pem
  filename = "deployer-priv-key"
  file_permission = "0600"
  
}


resource "null_resource" "FactoryDigital_Devops_test" {

  
  triggers = {
    instance_ids = module.ec2_complete.id
  }

  
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready!!'"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(local_file.deployer_priv_key_file.filename)
      host        = module.ec2_complete.public_ip
    }
  }

  

  # Note that the -i flag expects a comma separated list, so the trailing comma is essential!

  provisioner "local-exec" {
    command = "ansible-playbook aws-install-docker.yaml -u ec2-user --private-key ${local_file.deployer_priv_key_file.filename} -i '${module.ec2_complete.public_ip},' "
  }
}

################################################################################
# EC2 Module
################################################################################


module "ec2_complete" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.3.0"

  name = local.name

  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = local.instance_type
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true
  disable_api_termination     = true
  key_name                    = aws_key_pair.deployer_pub_key.key_name

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
  }


  tags = local.tags
}




