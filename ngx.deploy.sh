#!/usr/bin/env bash
if [[ "$1" == "" || ! -d $1 ]]; then
	echo "usage: $0 project-dir">&2; exit
fi

openresty_path="/usr/local/openresty"
proj_name=`basename $1`
proj_path="$openresty_path/projects/$proj_name"
host_path="$openresty_path/vhosts"

if [[ ! -f "$1/${proj_name}.ngx.conf" ]]; then
	echo " $1/${proj_name}.ngx.conf is missing.">&2; exit
fi

set -e

sudo mkdir -p $host_path
sudo mkdir -p $proj_path
sudo cp $1/${proj_name}.ngx.conf $host_path/
sudo cp -R $1/* $proj_path/
sudo rm $proj_path/${proj_name}.ngx.conf

sudo chown root:root $host_path/* -R
sudo chown root:root $proj_path/* -R
sudo chmod 644 $host_path/* -R
sudo chmod 740 $proj_path/* -R

function func_set_mode(){
	if [[ $# -lt 3 ]]; then echo "usage: func_set_mode {path} {dir-mode} {file-mode}">&2; return -1; fi
	if [[ ! -d $1 ]]; then echo "$1 not found.">&2; return 0; fi
	sudo chmod -R $3 $1
	sudo find $1 |while read f; do
		if [[ -d $f ]]; then sudo chmod $2 $f; fi
	done
}

function func_set_safe_read() { func_set_mode $1 755 644; } 
function func_set_safe_exec() { func_set_mode $1 755 755; } 

func_set_safe_read $proj_path/html 
func_set_safe_exec $proj_path/lua

echo "$proj_path deployed."

