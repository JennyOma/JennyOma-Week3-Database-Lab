terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Project = "JennyOma-Week3-RDS-Lab"
      Purpose = "AWS-SAA-Training"
    }
  }
}

# SECTION 1 - NETWORKING

resource "aws_vpc" "main" {
  cidr_block           = "10.30.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "JennyOma-RDS-VPC"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "JennyOma-RDS-IGW"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.30.1.0/24"
  availability_zone = "eu-north-1a"

  tags = {
    Name = "JennyOma-RDS-Public"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.30.11.0/24"
  availability_zone = "eu-north-1a"

  tags = {
    Name = "JennyOma-RDS-Private-A"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.30.12.0/24"
  availability_zone = "eu-north-1b"

  tags = {
    Name = "JennyOma-RDS-Private-B"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "JennyOma-RDS-Public-RT"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# SECTION 2 - SECURITY GROUPS

resource "aws_security_group" "client" {
  name        = "JennyOma-RDS-Client-SG"
  description = "Database client without inbound access"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "database" {
  name        = "JennyOma-RDS-Database-SG"
  description = "MySQL access from authorised EC2 client"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from EC2 client"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.client.id]
  }
}

# SECTION 3 - DATABASE SUBNET GROUP

resource "aws_db_subnet_group" "main" {
  name = "jennyoma-rds-subnet-group"

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

# SECTION 4 - AMAZON RDS MYSQL

resource "aws_db_instance" "main" {
  identifier     = "jennyoma-week3-mysql"
  engine         = "mysql"
  instance_class = "db.t4g.micro"

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "shoplab"
  username = "labadmin"

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]

  availability_zone   = "eu-north-1a"
  publicly_accessible = false
  multi_az            = false
  port                = 3306

  backup_retention_period = 1

  engine_lifecycle_support = "open-source-rds-extended-support-disabled"

  deletion_protection      = false
  skip_final_snapshot      = true
  delete_automated_backups = true

  tags = {
    Name = "JennyOma-Week3-MySQL"
  }
}

# SECTION 5 - IAM ROLE FOR EC2

resource "aws_iam_role" "client" {
  name = "JennyOma-RDS-Client-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.client.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "secret_access" {
  name = "JennyOma-RDS-Secret-Access"
  role = aws_iam_role.client.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "secretsmanager:GetSecretValue"
      Resource = aws_db_instance.main.master_user_secret[0].secret_arn
    }]
  })
}

resource "aws_iam_instance_profile" "client" {
  name = "JennyOma-RDS-Client-Profile"
  role = aws_iam_role.client.name
}

# SECTION 6 - EC2 DATABASE CLIENT

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "client" {
  ami           = data.aws_ssm_parameter.ami.value
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.client.id]
  iam_instance_profile   = aws_iam_instance_profile.client.name

  root_block_device {
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_tokens = "required"
  }

  credit_specification {
    cpu_credits = "standard"
  }

  user_data = <<-EOF
    #!/bin/bash
    systemctl enable --now amazon-ssm-agent
    dnf install -y mariadb105
  EOF

  depends_on = [
    aws_route_table_association.public,
    aws_iam_role_policy_attachment.ssm
  ]

  tags = {
    Name = "JennyOma-RDS-Client"
  }
}

# SECTION 7 - OUTPUTS

output "database_endpoint" {
  value = aws_db_instance.main.address
}

output "database_name" {
  value = aws_db_instance.main.db_name
}

output "client_instance_id" {
  value = aws_instance.client.id
}

output "database_secret_arn" {
  value = aws_db_instance.main.master_user_secret[0].secret_arn
}