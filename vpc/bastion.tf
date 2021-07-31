# resource "aws_instance" "bastion" {
#   ami           = var.ami
#   instance_type = var.type
#   key_name   = var.key_name
#   vpc_security_group_ids = var.securitygroupname
  

#   tags = {
#     Name = "HelloWorld"
#   }
# }