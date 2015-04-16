#!/usr/bin/env bash
CUR_DIR=$(cd `dirname $0`;pwd)

if [[ $# -lt 2 ]]; then
	echo "usage:$0 user email">&2; exit;
fi

set -e
sudo useradd -m $1
pwd=`cat /dev/urandom | sed 's/[^a-zA-Z0-9]//g' | strings -n 6 | head -n 1`
echo "$pwd"| sudo passwd $1 --stdin

cat $CUR_DIR/resource/gitconfig \
	| sudo sed "s/USERNAME/$1/g" \
	| sudo sed "s/EMAIL/$2/g" > /home/$1/.gitconfig
sudo chown $1:$1 /home/$1/.gitconfig

sudo mkdir -p /home/.ssh
sudo chmod 700 /home/.ssh
touch /home/.ssh/authorized_keys
sudo chmod 600 /home/.ssh/authorized_keys
sudo chown $1:$1 /home/.ssh -R

echo "$1 is ready: $pwd"

