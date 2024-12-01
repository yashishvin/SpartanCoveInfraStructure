resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "allow_ssh_http"
  }
}

resource "aws_security_group" "icmp_sg" {
  name        = "allow_icmp"
  description = "Allow all ICMP traffic"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "allow_icmp"
  }
}
resource "aws_security_group" "allow_ssh_http_from_bastion" {
  name        = "allow_ssh_http_from_bastion"
  description = "Allow ssh from the bastion in the vpc"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "allow_ssh_from_bastion"
  }
}

 resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
   security_group_id = aws_security_group.allow_ssh_http.id
   from_port         = 80
   cidr_ipv4         = "0.0.0.0/0"
   ip_protocol       = "tcp"
   to_port           = 80
 }

 resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv6" {
   security_group_id = aws_security_group.allow_ssh_http.id
   from_port         = 80
   cidr_ipv6         = "::/0"
   ip_protocol       = "tcp"
   to_port           = 80
 }

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh_http.id
  from_port         = 22
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv6" {
  security_group_id = aws_security_group.allow_ssh_http.id
  from_port         = 22
  cidr_ipv6         = "::/0"
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.allow_ssh_http.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

resource "aws_security_group_rule" "allow_ssh_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.allow_ssh_http_from_bastion.id
  source_security_group_id = aws_security_group.allow_ssh_http.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_bastiontraffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh_http_from_bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_bastiontraffic_ipv6" {
  security_group_id = aws_security_group.allow_ssh_http_from_bastion.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}