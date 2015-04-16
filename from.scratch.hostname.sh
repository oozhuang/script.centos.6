#!/usr/bin/env bash
CUR_DIR=$(cd `dirname $0`;pwd)

set -e
mkdir -p ~/tmp
f_tmp=~/tmp/tmp.network
f_target=/etc/sysconfig/network

sudo cat $f_target | \
	sudo sed "s/HOSTNAME=\(.*\)$/HOSTNAME=hahaha/g" > $f_tmp
if [[ `cat $f_tmp| grep "HOSTNAME"|wc -l` -lt 1 ]];then
	echo "HOSTNAME=$1" >> $f_tmp
fi
sudo mv $f_tmp $f_target
sudo chmod 644 $f_target
sudo hostname $1
