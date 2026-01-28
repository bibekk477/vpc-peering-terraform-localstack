locals {
  primary_user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1> Primary VPC instance- ${var.primary}</h1>" > /var/www/html/index.html
echo "<p> Private IP: $(hostname -I)</p>" >> /var/www/html/index.html
EOF

    secondary_user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1> Secondary VPC instance- ${var.secondary}</h1>" > /var/www/html/index.html
echo "<p> Private IP: $(hostname -I)</p>" >> /var/www/html/index.html
EOF
}