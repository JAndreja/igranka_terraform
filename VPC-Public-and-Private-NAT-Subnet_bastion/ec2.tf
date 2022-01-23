resource "aws_key_pair" "ssh-key" {
  key_name = "ssh-key"
  public_key = file(var.ssh_public_key)
}

resource "aws_instance" "myec2" {
   ami = "ami-05cafdf7c9f772ad2"
   instance_type = "t2.micro"
   availability_zone = var.avail_zone
   subnet_id = aws_subnet.public_subnet.id
   vpc_security_group_ids = [aws_security_group.web_acces.id]
   key_name = "terraform_aws"
    provisioner "file" {
       source ="./terraform_aws.pem"
       destination = "/home/ec2-user/terraform_aws.pem" 

    connection {
       type = "ssh"
       user = "ec2-user"
       private_key = file("./terraform_aws.pem")
       host = self.public_ip
       
    }     
   }
   tags = {
     Name  = "${var.env_name}-publicEC2"
   }

}

resource "aws_instance" "myec2-private" {
   ami = "ami-05cafdf7c9f772ad2"
   instance_type = "t2.micro"
   availability_zone = var.avail_zone
   subnet_id = aws_subnet.private_subnet.id
   vpc_security_group_ids = [aws_security_group.web_acces.id]
   key_name = "terraform_aws"
  
   tags = {
     Name  = "${var.env_name}-privateEC2"
   }

}