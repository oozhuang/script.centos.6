#!/usr/bin/env bash
SUDO="";if [[ "root" != `whoami` ]]; then SUDO="$SUDO";fi
#!!!
#depend on inc/deploy.sh
#!!!
g_openresty_dir="/usr/local/openresty"
g_proj_dir="$g_openresty_dir/project"
g_host_dir="$g_openresty_dir/vhost"
g_nginx="$g_openresty_dir/nginx/sbin/nginx"
g_backup_dir="/bak"
g_uniq_key="`date +"%s"`-php-$$"
#---the following var(s) should be initialized.---
g_name=""
g_ver=""
#---
g_src_dir=""
g_src_conf=""
#---
g_tmp_dir=""
g_tmp_conf=""
#---
g_dest_dir=""
g_dest_conf=""
#-------------------------------------------------
g_init_dir=""

# 初始化
function func_deploy_init()
{
    g_name=`tool_get_src_name $1`
    g_ver=`tool_get_src_version $1`
    g_src_dir=`tool_get_src_dir $1`
    g_src_conf="$g_src_dir/$g_name.ngx.conf"
    g_tmp_dir="$g_proj_dir/$g_name.$g_uniq_key"
    g_tmp_conf="$g_host_dir/$g_name.$g_uniq_key.ngx.conf"
    g_dest_dir="$g_proj_dir/$g_name"
    g_dest_conf="$g_host_dir/$g_name.ngx.conf"
    g_init_dir="$g_dest_dir/Init"
}

# 备份原项目
function func_deploy_backup()
{

    if [[ -d "$g_dest_dir" ]]; then
        tool_backup_general $g_dest_dir $g_backup_dir
        return $?
    fi

    return 0
}

# 准备部署
function func_deploy_prepare() {
    # 复制原目录到临时目录
    $SUDO cp -R $g_src_dir     $g_tmp_dir
    $SUDO cp    $g_src_conf    $g_tmp_conf

    _list="$g_tmp_dir $g_tmp_conf"
    for f in $_list; do tool_set_own $f nobody; done

    # 设置权限
    # php-fpm需要php文件要有可执行的权限
    tool_keep_safe_exec $g_tmp_dir

    # keep Cache Public allow to read
    _list="$g_tmp_conf"
    for f in $_list; do tool_keep_safe_read $f; done

    $SUDO $g_nginx -t

    return $?
}

# 确认部署
function func_deploy_finalize() {
    _list="$g_dest_dir $g_dest_conf"
    for f in $_list; do $SUDO rm -rf $f; done

    $SUDO rm -rf $g_tmp_dir/.git
    $SUDO mv $g_tmp_dir     $g_dest_dir
    $SUDO mv $g_tmp_conf    $g_dest_conf

    # 初始化项目需要的数据或其他
    if [[ -f "$g_init_dir/init.php" ]]; then
        # /usr/bin/php "$g_tmp_dir/Init/init.php"
        $SUDO php "$g_init_dir/init.php"

        # 初始化完成，删除初始化目录
        # $SUDO rm -rf "$g_init_dir"
    fi

    echo "$g_name($g_ver) deployed"
    return 0
}

# 清除部署
function func_deploy_clear() {
    _list="$g_tmp_dir $g_tmp_conf"
    for f in $_list; do $SUDO rm -rf $f; done
    return 0
}

# 部署项目
function func_deploy() {
    func_deploy_init $1
    func_deploy_backup
    func_deploy_prepare
    if [[ $? -ne 0 ]]; then
        func_deploy_clear
        return
    fi
    echo -n "src is ready. deploy? [y|n]"
    while read a; do
        case $a in
            y|Y) func_deploy_finalize; break ;;
            n|N) func_deploy_clear;break ;;
            *) echo -n "src is ready. deploy? [y|n]" ;;
        esac
    done
}

