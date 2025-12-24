provider "aws" {
  region = "us-east-1"
}

# 1. Rôle IAM (Permet au serveur d'accéder à DynamoDB et de se scanner lui-même)
resource "aws_iam_role" "ec2_role" {
  name = "SentinelEC2Role_Final"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Principal = { Service = "ec2.amazonaws.com" }, Effect = "Allow" }]
  })
}

# On donne les droits admin au serveur pour qu'il puisse lancer Prowler
resource "aws_iam_role_policy_attachment" "admin_rights" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "SentinelInstanceProfile_Final"
  role = aws_iam_role.ec2_role.name
}

# 2. Base de données (DynamoDB)
resource "aws_dynamodb_table" "history_table" {
  name           = "SentinelHistory"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "scan_id"
  attribute {
    name = "scan_id"
    type = "S"
  }
}

# 3. Security Group (CORRIGÉ : Pas de point-virgule, format multi-lignes)
resource "aws_security_group" "app_sg" {
  name        = "sentinel-sg-final"
  description = "Allow Web and SSH"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Serveur EC2
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = "sentinel-key" # Vérifie que tu as bien créé cette clé sur AWS !
  
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # Installation automatique de Docker
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io git
              sudo systemctl start docker
              sudo usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "Sentinel-Server-Final"
  }
}

# 5. IP Fixe (Elastic IP)
resource "aws_eip" "lb" {
  instance = aws_instance.app_server.id
}

# 6. Bucket S3 Frontend
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "cloud-sentinel-front-soumia-wiame-amine-2026" 
}

# Sortie console
output "server_ip" {
  value = aws_eip.lb.public_ip
}

output "bucket_name" {
  value = aws_s3_bucket.frontend_bucket.bucket
}