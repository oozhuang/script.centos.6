#!/usr/bin/env bash

sudo yum -y update && \
sudo yum -y install \
git wget md5sum \
gcc-c++ patch ctags \
openssl openssl-devel zlib zlib-devel pcre pcre-devel \
php fpm 

#sudo yum install "http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm"

