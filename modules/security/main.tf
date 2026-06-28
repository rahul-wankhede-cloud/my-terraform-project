resource "aws_security_group" "allow_ssh" {
  name        = "${var.environment_name}-allow-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from EC2 Instance Connect"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For production, use specific AWS IP ranges
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ssh-security-group" }
}

resource "aws_security_group" "alb_sg" {
  name   = "alb-security-group"
  vpc_id = var.vpc_id

  # Inbound: Allow HTTP from everywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound: Allow all traffic out
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "alb-security-group" }
}

# The Database Security Group
resource "aws_security_group" "db_sg" {
  name        = "database-sg"
  description = "Allow traffic from Web SG only"
  vpc_id      = var.vpc_id

  ingress {
    description = "MySQL/Aurora from Web Tier"
    from_port   = 3306 # Standard port for MySQL/Aurora
    to_port     = 3306
    protocol    = "tcp"

    # THE KEY LINE: This allows the Web SG to act as the "Key"
    security_groups = [aws_security_group.allow_ssh.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "db-sg" }
}

resource "aws_security_group" "eice_sg" {
  name        = "eice-endpoint-sg"
  description = "Allows EICE to reach the database"
  vpc_id      = var.vpc_id

  # Inbound: Leave empty (AWS handles the CLI connection internally)

  # Outbound: Allow EICE to talk to your RDS Security Group
  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.db_sg.id]
  }

  tags = { Name = "eice-endpoint-sg" }
}

resource "aws_security_group_rule" "allow_eice_to_rds" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.db_sg.id
  # This is the 'Source' that was missing!
  source_security_group_id = aws_security_group.eice_sg.id
}

resource "aws_security_group_rule" "allow_bastion_to_db" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.db_sg.id # The DB SG

  # This is the magic part: only allow traffic coming from the Bastion's SG
  source_security_group_id = var.bastion_security_group_id
}