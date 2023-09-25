# create application load balancer
resource "aws_lb" "alb" {
  name               = "${var.project_name}-lb1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.mysg_id]
  subnets            = [var.subnet_ids[0], var.subnet_ids[1]]

 tags = {
      name        = "${var.project_name}-lb"
  }
}


# create target group
resource "aws_lb_target_group" "webtg1" {
  name     = "${var.project_name}-tg1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id


health_check {
                path = "/var/www/html/index.html"
                port = "80"
                protocol = "HTTP"
                healthy_threshold = 5
                unhealthy_threshold = 2
                interval = 30 
                timeout = 4
                matcher = "200-299"
        }
}

# create a listener on port 80 with redirect action
resource "aws_lb_listener" "web_tg1" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webtg1.arn
  }
}

resource "aws_launch_template" "my_launch_1" {
  name_prefix            = "${var.project_name}-launch1"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.keypair
  vpc_security_group_ids = [var.launch_sg]
  user_data              = base64encode(<<EOF
                        #!/bin/bash
                        sudo yum install httpd -y
                        systemctl start httpd
                        systemctl enable httpd
                        echo "<html><body><h1>Hello from Terraform</h1></body></html>" > /var/www/html/index.html
   EOF
   )
}

resource "aws_autoscaling_group" "my_asg_1" {
  name                      = "${var.project_name}-asg1"
  max_size                  = 5
  min_size                  = 1
  desired_capacity          = 2
  health_check_grace_period = "100"
  health_check_type         = "EC2"
  vpc_zone_identifier       = [var.subnet_ids[0], var.subnet_ids[1]]
  target_group_arns         = [aws_lb_target_group.webtg1.arn]
   launch_template {
    id      = aws_launch_template.my_launch_1.id
    }
  }

resource "aws_autoscaling_policy" "policy_1" {
  name                   = "${var.project_name}-policy1"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.my_asg_1.name
}
resource "aws_autoscaling_attachment" "alb1_attachment" {
  autoscaling_group_name = aws_autoscaling_group.my_asg_1.name
  lb_target_group_arn   = aws_lb_target_group.webtg1.arn
}

#INTERNAL ALB & ASG

# create application load balancer
resource "aws_lb" "alb_2" {
  name               = "${var.project_name}-lb2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.mysg_id]
  subnets            = [var.subnet_ids[2], var.subnet_ids[3]]

 tags = {
      name        = "${var.project_name}-lb2"
  }
}


# create target group
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project_name}-tg2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id


health_check {
                path = "/var/www/html/index.html"
                port = "80"
                protocol = "HTTP"
                healthy_threshold = 5
                unhealthy_threshold = 2
                interval = 30 
                timeout = 4
                matcher = "200-299"
        }
}

# create a listener on port 80 with redirect action
resource "aws_lb_listener" "app_tg1" {
  load_balancer_arn = aws_lb.alb_2.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_launch_template" "my_launch_2" {
  name_prefix            = "${var.project_name}-launch2"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.keypair
  vpc_security_group_ids = [var.launch_sg]
  user_data              = base64encode(<<EOF
                        #!/bin/bash
                        sudo yum install httpd -y
                        systemctl start httpd
                        systemctl enable httpd
                        echo "<html><body><h1>Hello from Terraform private</h1></body></html>" > /var/www/html/index.html
   EOF
   )
}

resource "aws_autoscaling_group" "my_asg_2" {
  name                      = "${var.project_name}-asg2"
  max_size                  = 5
  min_size                  = 1
  desired_capacity          = 2
  health_check_grace_period = "100"
  health_check_type         = "EC2"
  vpc_zone_identifier       = [var.subnet_ids[2], var.subnet_ids[3]]
  target_group_arns         = [aws_lb_target_group.app_tg.arn]
   launch_template {
    id      = aws_launch_template.my_launch_2.id
    }
  }

resource "aws_autoscaling_policy" "policy_2" {
  name                   = "${var.project_name}-policy2"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.my_asg_2.name
}
resource "aws_autoscaling_attachment" "alb2_attachment" {
  autoscaling_group_name = aws_autoscaling_group.my_asg_2.name
  lb_target_group_arn   = aws_lb_target_group.app_tg.arn
}
#RDS MY SQL
resource "aws_db_subnet_group" "db" {
  name       = "db"
  subnet_ids = [var.subnet_ids[4], var.subnet_ids[5]]
}

resource "aws_db_instance" "MainDatabase" {
  identifier             = var.masterdb_identifier
  allocated_storage      = 20
  storage_type           = var.db_storage_type  
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [var.db_id]
  availability_zone      = "us-east-1b"
  db_name                = var.masterdb_name
  username               = var.masterdb_username
  password               = var.masterdb_password
  backup_retention_period = 7
  skip_final_snapshot    = true
  multi_az               = false

  tags = {
    Name = "Master DB Instance"
  }
}

resource "aws_db_snapshot" "shot1" {
  db_instance_identifier = aws_db_instance.MainDatabase.identifier
  db_snapshot_identifier = "snap1"  
}
resource "aws_db_instance" "ReplicaDatabase" {
  identifier             = var.replicadb_identifier
  storage_type           = var.db_storage_type
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  availability_zone      = "us-east-1a"
  skip_final_snapshot    = true
  backup_retention_period = 7
  multi_az               = false
  replicate_source_db    = aws_db_instance.MainDatabase.arn
  vpc_security_group_ids = [var.db_id]
  
  tags = {
    Name = "Read Replica Database"
  } 
}
