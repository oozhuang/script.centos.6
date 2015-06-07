#!/usr/bin/env bash
CUR_DIR=$(cd `dirname $0`;pwd)
SUDO="";if [[ "root" != `whoami` ]]; then SUDO="sudo";fi

if [[ $# -lt 2 ]]; then
	echo "usage:$0 mount-dev mount-dir">&2; exit;
fi

if [[ ! -b "$1" ]]; then
	echo "mount-dev $1 is not a special-block, or doesnot exist.">&2; exit
fi

if [[ -f "$2" || -d "$2" ]]; then
	echo "mount-dir $2 already exists.">&2; exit
fi

m_dev="$1"
m_dir="$2"

set -e
echo "-----hints:begin----"
echo "n :new partition"
echo "p :primary"
echo "1 "
echo "-----hints:end----"
$SUDO fdisk $m_dev
#fdisk -l
$SUDO mkfs.ext3 ${m_dev}1
#cat /etc/fstab 
$SUDO echo "${m_dev}1 $m_dir    ext3    defaults    0  0" | $SUDO tee -a /etc/fstab
#cat /etc/fstab 
$SUDO mkdir $m_dir
mount -a

