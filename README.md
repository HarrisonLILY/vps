# Rocky

## Table of contents
* [General info](#general-info)
* [Base.sh](#base)

## General Info
A few simple scripts to help deploying Rocky Linux servers, can also be used on CentOS and AlmaLinux  

## base.sh
This is the main deplyment script it will ask if you wish to disable SELinux and then reboot if you wish

- Update the server
- Install Nginx
- Create a simple site on the server IP 
- Enable Nginx at boot and start service
- Open HTTP & HTTPS ports on firewall
- Disabled SELinux (if required)
- Reboot (if required)
