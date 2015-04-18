#!/usr/bin/env bash
function tool_mkdir_if_not_exist () 
{
	if [[ ! -d $1 ]]; then
		sudo mkdir -p $1
		sudo chown root:root $1 -R
		if [[ "$2" != "" ]]; then
			sudo chmod $2 $1
		fi
	fi
}

function tool_set_mode () 
{
	if [[ $# -lt 3 ]]; then echo "usage: tool_set_mode {path} {dir-mode} {file-mode}">&2; return -1; fi
	if [[ ! -d $1 && ! -f $1 ]]; then echo "dir|file $1 not found.">&2; return 0; fi
	sudo chmod -R $3 $1
	if [[ -f "$1" ]];then 
		return; 
	else
		sudo find $1 |while read f; do
			if [[ -d $f ]]; then sudo chmod $2 $f; fi
		done
	fi
	return 0
}

function tool_set_own () 
{
	if [[ ! -d $1 && ! -f $1 ]]; then echo "dir|file $1 not found.">&2; return 0; fi
	sudo chown -R $2:$2 $1
}

function tool_keep_safe () { tool_set_mode $1 755 600; } 
function tool_keep_safe_read () { tool_set_mode $1 755 644; } 
function tool_keep_safe_exec () { tool_set_mode $1 755 755; } 

function tool_get_src_dir () 
{
	_dir="/"
	a1=`echo "$1"|sed "s#\(//*\)#/#g"`
	if [[ "$a1" != "" && "$a1" != "/" && -d "$a1" ]]; then
		_dir=`echo "$a1"|sed "s/\/$//g"`
	fi
	echo "$_dir"
}
function tool_get_src_name ()
{
	basename $1
}
function tool_get_src_version ()
{
	if [[ ! -f "$1/VERSION" ]]; then return; fi
	head -n 1 $1/VERSION
}
function tool_get_src_type ()
{
	t=":"
	if [[ -d "$1/lua" ]]; then
		t="${t}lua:"
	fi
	#TODO @zhanghaipeng, 
	# make a rule to tell whether it's a php-project, or not.
	if [[ -d "$1/php" ]]; then
		t="${t}php:"
	fi
	echo "$t"
	#$t should be ":lua:", ":php:", or ":lua:php:"
}

function tool_backup_general ()
{
	if [[ $# -lt 2 ]]; then echo "usage: tool_backup_general dest-proj backup-dir">&2; return -1; fi
	if [[ ! -d "$1" ]]; then echo "backup $dest_name...NONE."; return 0; fi
	if [[ ! -d "$2" ]]; then echo "backup-dir: $2 doesnot exist.">&2; return -1; fi
	dest_name=`tool_get_src_name $1`
	dest_dir=`tool_get_src_dir $1`
	dest_ver=`tool_get_src_version $1`
	if [[ "$dest_ver" == "" ]]; then echo "VERSION is not specified.">&2; return -1; fi
	mkdir -p ~/tmp
	sudo cp -R $1 ~/tmp/
	cd ~/tmp
	sudo tar -jcvf $dest_name.$dest_ver.tar.bz2 $dest_name
	sudo mv $dest_name.$dest_ver.tar.bz2 $2/
	echo "backup $dest_name...$dest_ver"
	return 0
}

