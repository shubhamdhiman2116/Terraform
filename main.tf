resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr
    map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidr  
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main.id  
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "rds_sg" {
    vpc_id = aws_vpc.main.id
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.ec2_sg.id]
    } 
}

resource "aws_instance" "app" {
    ami = "ami-0f5ee92e2d63afc18"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]
    tags = {
        name= "App-Server"
    }
}

resource "aws_db_subnet_group" "db_subnet" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.private.id]
}

resource "aws_db_instance" "db" {
    identifier = "mydb"
    engine = "mysql"
    instance_class = "db.t3.micro"
    allocated_storage = 20

    db_name = "mydatabase"
    username = var.db_username
    password = var.db_password

    multi_az = true
    publicly_accessible = false
    db_subnet_group_name = aws_db_subnet_group.db_subnet.name
    vpc_security_group_ids = [aws_security_group.rds_sg.id]

    backup_retention_period = 7
    skip_final_snapshot = true
}
