provider "aws"{
    region = "us-east-1"
}

resource "aws_instance" "test01" {
  ami                     = "ami-066784287e358dad1"
  instance_type           = "t2.nano"
  key_name = "awsTest01"
  security_groups = [aws_security_group.ssh_rule.name]  
  depends_on = [aws_security_group.ssh_rule] 
}
