# ssh-keygen -t rsa -b 4096 -f filename
resource "aws_key_pair" "zw" {
  key_name   = "terraform_aws_keypair"
  public_key = file(var.aws_keypair)
}



resource "aws_instance" "pub01" {
  ami           = "ami-0648880541a3156f7"
  instance_type = "t2.micro"
	associate_public_ip_address = true
	subnet_id = aws_subnet.pub1.id
	key_name = aws_key_pair.zw.key_name
	vpc_security_group_ids = [aws_security_group.secgrp_pub.id]

  tags = {
    Name = "HelloWorld from public"
  }
}

resource "aws_instance" "priv01" {
  ami           = "ami-0648880541a3156f7"
  instance_type = "t2.micro"
	subnet_id = aws_subnet.priv1.id
	key_name = aws_key_pair.zw.key_name
	vpc_security_group_ids = [aws_security_group.secgrp_priv.id]

  tags = {
    Name = "HelloWorld from private"
  }
}
