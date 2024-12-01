resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "key"
  public_key = tls_private_key.key.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.key.private_key_pem}' > ${path.module}/key.pem && chmod 0700 ${path.module}/key.pem"
  }
}

resource "aws_eip" "lb" {
  instance = aws_instance.bastion_host.id
  domain   = "vpc"
}
resource "aws_instance" "bastion_host" {
  ami                    = "ami-0d53d72369335a9d6" # Ubuntu 22.04 free tier ami in us-west-1
  instance_type          = "t2.nano"
  key_name               = aws_key_pair.key_pair.key_name
  availability_zone      = "us-west-1b"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

}

resource "aws_instance" "private_instance" {
  ami               = "ami-0d53d72369335a9d6"
  instance_type     = "t2.nano"
  key_name          = aws_key_pair.key_pair.key_name
  availability_zone = "us-west-1b"
  subnet_id         = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.icmp_sg.id,
  aws_security_group.allow_ssh_http_from_bastion.id]
  tags = {
    Name = "PrivateInstance"
  }
}


output "instance" {
  value = [aws_instance.bastion_host.public_ip,
    aws_instance.private_instance.private_ip
  ]
  description = "The public and private IP addresses of the instances"
}