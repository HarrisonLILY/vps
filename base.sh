#!/bin/bash -       
# title         : base.sh
# description   : This script will update, install and configure server for serving static HTML
# author        : Neil
# date          : 22/01/2022
# version       : 1.0
# notes         : Ensure you set the hostname before running or might not work 
#
# Learn about everything affiliate marketing on affLIFT the Fastest Growing Premium Affiliate Community
#
# https://afflift.rocks/r/joinus
#
# ==============================================================================
# 
# update kernel and installed packages
dnf -y update
# configure Nginx repo
cat <<EOF > /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx repo
baseurl=https://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF
# import Nginx singing key
rpm --import  https://nginx.org/keys/nginx_signing.key
# install Nginx
dnf -y install nginx
# get IP address
ip=$(hostname  -I | cut -f1 -d' ')
# create folder to hold website files
mkdir -p /var/www/html/$ip
# create config file to display website on IP
cat <<EOF > /etc/nginx/conf.d/$ip.conf
server  {
    listen 80;
    server_name $ip;
    root /var/www/html/$ip;
    index index.html;
    location / { try_files \$uri \$uri/ =404; }
}
EOF
# create temporary index.html file in new site
cat <<EOF > /var/www/html/$ip/index.html
afflift rocks :)
EOF
# open firewall to allow HTTP and HTTPS traffic
firewall-cmd --permanent --zone=public --add-service=https --add-service=http
firewall-cmd --reload
# start the nginx service and enable it at boot
systemctl enable --now nginx
# check if SELinux should be disabled
# set text colour to yellow
tput setaf 3;
# check if SELinux should be disabled
read -r -p "Do you want to disabled SELinux? [y/N] : " -n 1
if [[ "$REPLY" =~ ^([yY])$ ]]; then
    # disable SELinux 
    sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
    # server needs a reboot check if we should do that now
    printf "\nSELinux has been set to disabled but you WILL need to reboot\n"
    read -r -p "REBOOT NOW? [Y/n] : " -n 1
    if [[ ! "$REPLY" =~ ^([Nn])$ ]]; then
        # reboot server
        printf "\nRebooting server now\n"
        reboot
    fi
else
    # add policies foe SELinux to work with Nginx
    setsebool -P httpd_can_network_connect on
    chcon -Rt httpd_sys_content_t /var/www/html/$ip/
fi
# set text colour back to default
tput sgr0;
