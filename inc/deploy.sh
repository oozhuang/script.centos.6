#!/usr/bin/env bash
SUDO="";if [[ "root" != `whoami` ]]; then SUDO="$SUDO";fi
function tool_mkdir_if_not_exist () 
{
	if [[ ! -d $1 ]]; then
		$SUDO mkdir -p $1
		$SUDO chown root:staff $1 -R
		if [[ "$2" != "" ]]; then
			$SUDO chmod $2 $1
		fi
	fi
}

function tool_set_mode () 
{
	if [[ $# -lt 3 ]]; then echo "usage: tool_set_mode {path} {dir-mode} {file-mode}">&2; return -1; fi
	if [[ ! -d $1 && ! -f $1 ]]; then echo "dir|file $1 not found.">&2; return 0; fi
	$SUDO chmod -R $3 $1
	if [[ -f "$1" ]];then 
		return; 
	else
		$SUDO find $1 |while read f; do
			if [[ -d $f ]]; then $SUDO chmod $2 $f; fi
		done
	fi
	return 0
}

function tool_set_own () 
{
	if [[ ! -d $1 && ! -f $1 ]]; then echo "dir|file $1 not found.">&2; return 0; fi
	$SUDO chown -R $2:$3 $1
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
	$SUDO head -n 1 $1/VERSION
}
function tool_get_src_type ()
{
	t=":"
	if [[ -d "$1/lua" ]]; then
		t="${t}lua:"
	fi

	# make a rule to tell whether it's a php-project, or not.
	if [[ -f "$1/index.php" ]]; then
		t="${t}php:"
	fi
	echo "$t"
	#$t should be ":lua:", ":php:", or ":lua:php:"
}

function tool_backup_general ()
{
	if [[ $# -lt 2 ]]; then echo "usage: tool_backup_general dest-proj backup-dir">&2; return -1; fi
	_dir=`tool_get_src_dir $1`
	_name=`tool_get_src_name $1`
	_ver=`tool_get_src_version $1`
	_bz2="$_name.$_ver.tar.bz2"
	if [[ ! -d "$_dir" ]]; then echo "backup $_name...NONE"; return 0; fi
	if [[ ! -d "$2" ]]; then echo "backup-dir: $2 doesnot exist.">&2; return -1; fi
	if [[ "$_ver" == "" ]]; then echo "VERSION is not specified, ignored.">&2; return 0; fi
	if [[ -f "$2/$_bz2" ]]; then echo "backup $_name...$_ver(did it be4, ignored)"; return 0; fi
	cd $_dir; cd ..
	$SUDO tar -jcf $_bz2 $_name
	$SUDO mv -v $_bz2 $2/
	echo "backup $_name...$_ver"
	return 0
}

