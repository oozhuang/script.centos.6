#!/usr/bin/env bash
SUDO="";if [[ "root" != `whoami` ]]; then SUDO="sudo";fi

$SUDO yum -y update && \
$SUDO yum -y install \
git wget md5sum \
gcc-c++ patch ctags \
openssl openssl-devel zlib zlib-devel pcre pcre-devel \
php fpm 

#$SUDO yum -y install "http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm"
#$SUDO yum -y install GraphicsMagick
