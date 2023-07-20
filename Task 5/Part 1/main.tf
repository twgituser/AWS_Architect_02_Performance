# Designate a cloud provider, region, and credentials
provider "aws" {
  access_key = "xxx"
  secret_key = "xxx"
  region = "us-east-1"
}

# Provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "UdacityT2" {
  count = "4"
  ami = "ami-06ca3ca175f37dd66"
  instance_type = "t2.micro"
  tags = {
    Name = "Udacity T2"
  }
}  

# Provision 2 AWS m4.large EC2 instances named Udacity M4
resource "aws_instance" "UdacityM4" {
  count = "2"
  ami = "ami-06ca3ca175f37dd66"
  instance_type = "m4.large"
  tags = {
    Name = "Udacity M4"
  }
}  