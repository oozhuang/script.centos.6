#!/usr/bin/env bash
CUR_DIR=$(cd `dirname $0`;pwd)
SUDO="";if [[ "root" != `whoami` ]]; then SUDO="sudo";fi

if [[ $# -lt 1 ]]; then
	echo "$0 hostname">&2; exit
fi

set -e
mkdir -p ~/tmp
f_tmp=~/tmp/tmp.network
f_target=/etc/sysconfig/network

$SUDO cat $f_target | \
	sed "s/HOSTNAME=\(.*\)$/HOSTNAME=$1/g" > $f_tmp
if [[ `cat $f_tmp| grep "HOSTNAME"|wc -l` -lt 1 ]];then
	echo "HOSTNAME=$1" >> $f_tmp
fi
$SUDO mv $f_tmp $f_target
$SUDO chmod 644 $f_target
$SUDO hostname $1


