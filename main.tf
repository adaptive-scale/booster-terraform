resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "adaptive-keypair"
  public_key = tls_private_key.example.public_key_openssh
}

variable "awsprops" {
  type = map
  default = {
    region = "ap-south-1"
    vpc = "vpc-9cf909f7"
    itype = "t4g.medium"
    subnet = "subnet-758f911d"
    publicip = true
    // Every region has a different ami, See here - https://aws.amazon.com/amazon-linux-ami/ or https://cloud-images.ubuntu.com/locator/ec2/
    // For us-east-2 -> ami-0b59bfac6be064b78
    ami = "ami-0ae12517fe595ce17"
    keyname = "test"
    secgroupname = "adaptive-booster-sec"
  }
}

provider "aws" {
  region = lookup(var.awsprops, "region")
}

resource "aws_security_group" "project-iac-sg" {
  name = lookup(var.awsprops, "secgroupname")
  description = lookup(var.awsprops, "secgroupname")
  vpc_id = lookup(var.awsprops, "vpc")

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"] // This should be changed to specific IPs. All route is required to install booster for now.
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "adaptive-booster" {
  ami  = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = lookup(var.awsprops, "subnet") #FFXsubnet2
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = aws_key_pair.generated_key.key_name

  vpc_security_group_ids = [
    aws_security_group.project-iac-sg.id
  ]
  root_block_device {
    delete_on_termination = true
    iops = 150
    volume_size = 50
    volume_type = "gp3"
  }
  tags = {
    Name ="adaptive-booster"
    Environment = "PROD"
    OS = "AMAZON LINUX"
    Managed = "IAC"
  }

  depends_on = [ aws_security_group.project-iac-sg ]
}

output "ec2instance" {
  value = aws_instance.adaptive-booster.public_ip
}

output "private_key" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}