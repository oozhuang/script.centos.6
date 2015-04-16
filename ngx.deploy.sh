#!/usr/bin/env bash
if [[ "$1" == "" || ! -d $1 ]]; then
	echo "usage: $0 project-dir">&2; exit
fi

openresty_path="/usr/local/openresty"
proj_name=`basename $1`
proj_path="$openresty_path/project/$proj_name"
host_path="$openresty_path/vhost"
lualib_path="$openresty_path/project.lualib"

if [[ ! -f "$1/${proj_name}.ngx.conf" ]]; then
	echo " $1/${proj_name}.ngx.conf is missing.">&2; exit
fi


function create_if_not_exist_dir() {
	if [[ ! -d $1 ]]; then
		sudo mkdir -p $1
		sudo chown root:root $1 -R
		if [[ "$2" != "" ]]; then
			sudo chmod $2 $1
		fi
	fi
}

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

set -e
create_if_not_exist_dir $lualib_path 755
create_if_not_exist_dir $host_path   755
create_if_not_exist_dir $proj_path   755

sudo cp $1/${proj_name}.ngx.conf $host_path/
sudo cp -R $1/lualib/$proj_name $lualib_path/
sudo cp -R $1/* $proj_path/
sudo chown root:root $lualib_path/* -R
sudo chown root:root $host_path/* -R
sudo chown root:root $proj_path/* -R
sudo chmod 644 $host_path/* -R
sudo chmod 740 $proj_path/* -R
sudo chmod 740 $lualib_path/$proj_name -R

rm_list="${proj_name}.ngx.conf .git README.md lualib"
for f in $rm_list; do 
	sudo rm -rf $proj_path/$f
done

func_set_safe_read $proj_path/html 
func_set_safe_exec $proj_path/lua
func_set_safe_read $lualib_path/$proj_name

echo "$proj_path deployed."

sudo $openresty_path/nginx/sbin/nginx -t
#TODO need to backup running-code


