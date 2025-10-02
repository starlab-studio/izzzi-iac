#!/bin/bash
# Create the 'ubuntu' user if it doesn't exist
id -u ubuntu &>/dev/null || useradd -m -s /bin/bash ubuntu

# Create the .ssh directory
mkdir -p /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh

# Add the SSH public key
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDxyuS+I9bfOaj3WKvmKjCnem691KLVaKryYlY5liU9f55X30Bv7Y7YR05lETg4KUBJ98VnJe6CqnFvQsXOJcxmwR+K20BFgBCPnRlf5JkdrkSOgvovYddtvltaUDCDOQgiMh1YBHQqD+u4TXiE0ESZDUfgiW4GWulfh3K4Fbf/tbRuGsmNPvfmo3+ROnCqz6fdC4ksr2xGF0jmOGR4fetxx9MNNPZutdQ3ck0dXLEgWowuv2CRrBi0Wag1/dyX9c96u0PTSbVgCjRgG1lj68Z/xh2sOxIUgtfJHFSHBRUHUeDBwvXEZlO8W1Civ3EMuRECy2TBNnZq7TcP8atB7549fcb16aJ7Wmj7kZMunCXT0HHd8rmh2592EihssTV3GeLiOxzhISZioKzqQVr5Xajvue47BbaZCmGQIcGfw047FqBlh3tcV5QUoh/6PaRrxb9DmCYS7lmBn0zGfQP8KtBtT72FcMGEIO21xrbF4SdHljJAN6fPptcz5wYFPtbkp3iV8df6Ka0VitkXT/+2oYGd/o1l03cKTkWfNMyRq7EG0LWleVXm5/Xzj4mDs1QhgpVRjeilCGUI8TWOWFJNqWhtYGdlKOj0pU3GB81u4EpWpi7eD0SmtK0QgulcfKKb4ysNtX5dUn25bSLeBTMuhiiZ7bsF3eI2j2/Lm8yVkltq4Q== ddaniomer@gmmail.com" > /home/ubuntu/.ssh/authorized_keys
chmod 600 /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh
