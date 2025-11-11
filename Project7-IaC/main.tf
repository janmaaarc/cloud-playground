provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "project7-iac-bucket"
  force_destroy = false
  tags = {
    Name = "Project7-IaC-Bucket"
  }
}

resource "aws_instance" "my_ec2" {
  ami           = "ami-03e2d913d4bef1246"
  instance_type = "t3.micro"
  tags = {
    Name = "Project7-IaC-EC2"
  }
}
