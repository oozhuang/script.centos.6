#!/usr/bin/env bash
SUDO="";if [[ "root" != `whoami` ]]; then SUDO="sudo";fi

$SUDO iptables -F #clear all iptable-rule
$SUDO iptables -A INPUT -p tcp --dport 22 -j ACCEPT #allow ssh
$SUDO iptables -A INPUT -p tcp --dport 80 -j ACCEPT #allow http
$SUDO iptables -A INPUT -p tcp --dport 443 -j ACCEPT #allow https
$SUDO iptables -A INPUT -p icmp -j ACCEPT  #allow ping/traceroute
$SUDO iptables -P INPUT DROP    #input-policy: drop
$SUDO iptables -P FORWARD DROP  #forward-policy: drop
$SUDO iptables -P OUTPUT ACCEPT #output-policy: accept
$SUDO iptables -A INPUT -i lo -j ACCEPT #allow localhost access
$SUDO iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$SUDO /etc/init.d/iptables save #save to /etc/sysconfig/iptables

