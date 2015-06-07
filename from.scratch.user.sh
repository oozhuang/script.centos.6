#!/usr/bin/env bash
CUR_DIR=$(cd `dirname $0`;pwd)
SUDO="";if [[ "root" != `whoami` ]]; then SUDO="sudo";fi

if [[ $# -lt 2 ]]; then
	echo "usage:$0 user email">&2; exit;
fi

set -e
$SUDO useradd -m $1
pwd=`cat /dev/urandom | sed 's/[^a-zA-Z0-9]//g' | strings -n 6 | head -n 1`
echo "$pwd"| $SUDO passwd $1 --stdin

mkdir -p ~/tmp
cat $CUR_DIR/resource/gitconfig \
	| sed "s/USERNAME/$1/g" \
	| sed "s/EMAIL/$2/g" > ~/tmp/gitconfig
$SUDO mv ~/tmp/gitconfig /home/$1/.gitconfig
$SUDO mkdir -p /home/$1/.ssh
$SUDO touch /home/$1/.ssh/authorized_keys
$SUDO chown $1:$1 /home/$1 -R
$SUDO chmod 700 /home/$1/.ssh
$SUDO chmod 600 /home/$1/.ssh/authorized_keys

echo "$1 is ready: $pwd"

