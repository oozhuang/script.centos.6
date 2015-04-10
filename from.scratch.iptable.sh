#!/usr/bin/env bash
sudo iptables -F #clear all iptable-rule
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT #allow ssh
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT #allow http
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT #allow https
sudo iptables -A INPUT -p icmp -j ACCEPT  #allow ping/traceroute
sudo iptables -P INPUT DROP    #input-policy: drop
sudo iptables -P FORWARD DROP  #forward-policy: drop
sudo iptables -P OUTPUT ACCEPT #output-policy: accept
sudo iptables -A INPUT -i lo -j ACCEPT #allow localhost access
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo /etc/init.d/iptables save #save to /etc/sysconfig/iptables

