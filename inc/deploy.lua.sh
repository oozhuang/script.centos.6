#!/usr/bin/env bash
#!!!
#depend on inc/deploy.sh
#!!!
g_openresty_dir="/usr/local/openresty"
g_proj_dir="$g_openresty_dir/project"
g_host_dir="$g_openresty_dir/vhost"
g_lualib_dir="$g_openresty_dir/project.lualib"
g_nginx="$g_openresty_dir/nginx/sbin/nginx"
g_backup_dir="/bak"
g_uniq_key="`date +"%s"`-lua-$$"
#---the following var(s) should be initialized.---
g_name=""
g_ver=""
#---
g_src_dir=""
g_src_lib_dir=""
g_src_conf=""
#---
g_tmp_dir=""
g_tmp_lib_dir=""
g_tmp_conf=""
#---
g_dest_dir=""
g_dest_lib_dir=""
g_dest_conf=""
#-------------------------------------------------

function func_deploy_init() 
{
	g_name=`tool_get_src_name $1`
	g_ver=`tool_get_src_version $1`
	g_src_dir=`tool_get_src_dir $1`
	g_src_lib_dir="$g_src_dir/lualib/$g_name"
	g_src_conf="$g_src_dir/$g_name.ngx.conf"
	g_tmp_dir="$g_proj_dir/$g_name.$g_uniq_key"
	g_tmp_lib_dir="$g_lualib_dir/$g_name.$g_uniq_key"
	g_tmp_conf="$g_host_dir/$g_name.$g_uniq_key.ngx.conf"
	g_dest_dir="$g_proj_dir/$g_name"
	g_dest_lib_dir="$g_lualib_dir/$g_name"
	g_dest_conf="$g_host_dir/$g_name.ngx.conf"
}

function func_deploy_backup() 
{
	tool_backup_general $g_dest_dir $g_backup_dir
	return $?
}

function func_deploy_prepare() {
	sudo cp -R $g_src_dir     $g_tmp_dir
	sudo cp -R $g_src_lib_dir $g_tmp_lib_dir
	sudo cp    $g_src_conf    $g_tmp_conf

	_list="$g_tmp_dir $g_tmp_lib_dir $g_tmp_conf"
	for f in $_list; do tool_set_own $f root root; done

	tool_keep_safe $g_tmp_dir

	_list="$g_tmp_dir/html $g_tmp_dir/lua $g_tmp_lib_dir $g_tmp_conf"
	for f in $_list; do tool_keep_safe_read $f; done
		
	#_list="$g_tmp_dir/lua" # TODO keep_safe_read is ok?
	#for f in $_list; do tool_keep_safe_exec $f; done
	
	sudo $g_nginx -t || ( func_deploy_clear && return 1 )

}

function func_deploy_finalize() {
	_list="$g_dest_dir $g_dest_lib_dir $g_dest_conf"
	for f in $_list; do sudo rm -rf $f; done
	#.git should not be deleted
	# at the very beginning?
	sudo rm -rf $g_tmp_dir/.git 
	sudo mv $g_tmp_dir     $g_dest_dir
	sudo mv $g_tmp_lib_dir $g_dest_lib_dir
	sudo mv $g_tmp_conf    $g_dest_conf
	echo "$g_name($g_ver) deployed"
	return 1
}

function func_deploy_clear() {
	_list="$g_tmp_dir $g_tmp_lib_dir $g_tmp_conf"
	for f in $_list; do sudo rm -rf $f; done
	echo "clear...done"
	return 0
}

function func_deploy() {
	func_deploy_init $1
	func_deploy_backup
	func_deploy_prepare || return 0
	echo -n "src is ready. deploy? [y|n]"
	while read a; do
		case $a in
			y|Y) func_deploy_finalize; break ;;
			n|N) func_deploy_clear;break ;;
			*) echo -n "src is ready. deploy? [y|n]" ;;
		esac
	done
}

