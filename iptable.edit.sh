#!/usr/bin/env bash
SUDO="";if [[ "root" != `whoami` ]]; then SUDO="sudo";fi

$SUDO vi /etc/sysconfig/iptables

