#!/bin/bash
sudo su -
yum update -y 
yum install httpd -y
systemctl start httpd
systemctl enable httpd
echo "<html><body><h1>Hello from my EC2 instance! 2</h1></body></html>" > /var/www/html/index.html