#!/usr/bin/env bash
SUDO="";if [[ "root" != `whoami` ]]; then SUDO="sudo";fi

$SUDO service iptables restart

