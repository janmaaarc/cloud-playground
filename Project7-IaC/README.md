# Project 7 – Infrastructure as Code (IaC)

## Objectives
- Automate cloud resource deployment using Infrastructure as Code (IaC)
- Use AWS CloudFormation or Terraform for provisioning
- Manage and version infrastructure consistently
- Document setup, commands, and lessons learned
- Include screenshots and notes

---


## Steps


### 1. Choose IaC Tool
- Decide between **Terraform** or **CloudFormation**.
- Install necessary CLI:
  - Terraform: `brew install terraform`
  - CloudFormation: AWS CLI (already installed)

---

### 2. Write IaC Template / Configuration

#### **Example: Terraform (main.tf)**
```hcl
provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "project7-iac-bucket"
  acl    = "private"
}

resource "aws_instance" "my_ec2" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.micro"
  tags = {
    Name = "Project7-IaC-EC2"
  }
}
```
#### **Example: CloudFormation (template.yaml)**
```yaml
Resources:
  MyS3Bucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: project7-iac-bucket

  MyEC2Instance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t3.micro
      ImageId: ami-0abcdef1234567890
      Tags:
        - Key: Name
          Value: Project7-IaC-EC2
```

### 3. Deploy Infrastructure
Terraform
```bash
# Initialize working directory
terraform init

# Preview changes
terraform plan

# Deploy resources
terraform apply
```
Cloudformation
```bash
aws cloudformation deploy \
  --template-file template.yaml \
  --stack-name Project7-IaC \
  --capabilities CAPABILITY_NAMED_IAM
```

### 4. Verify Resources
- Check AWS Console for:
 - S3 bucket creation
 - EC2 instance deployment
- Ensure all resources match your IaC configuration.

---

## Commands / AWS CLI (Optional)
```bash
# Terraform
terraform init
terraform plan
terraform apply
terraform destroy

# CloudFormation
aws cloudformation deploy --template-file template.yaml --stack-name Project7-IaC --capabilities CAPABILITY_NAMED_IAM
aws cloudformation delete-stack --stack-name Project7-IaC
```

---

## Notes / Lessons Learned

- IaC allows repeatable and version-controlled deployments.
- Terraform works across multiple cloud providers; CloudFormation is AWS-native.
- Always review the plan before applying changes to avoid unintended resource creation.
- Proper tagging and naming conventions make managing infrastructure easier.
- Using IaC reduces manual mistakes and accelerates project setup.

---

## Screenshots

### IaC Deployment Overview
![IaC Deployment Overview](screenshots/iac-deployment-overview.png)

### Terraform / CloudFormation Output
![Terraform / CloudFormation Output](screenshots/output.png)
