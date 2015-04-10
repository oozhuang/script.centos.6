#!/usr/bin/env bash

sudo yum update && \
sudo yum -y install \
git wget md5sum \
gcc-c++ patch ctags \
openssl openssl-devel zlib zlib-devel pcre pcre-devel \
php fpm 

