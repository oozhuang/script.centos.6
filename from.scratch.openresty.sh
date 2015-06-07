#!/usr/bin/env bash
CUR_DIR=$(cd `dirname $0`;pwd)
SUDO="";if [[ "root" != `whoami` ]]; then SUDO="sudo";fi

openresty_path="/usr/local/openresty"
p_file="v1.7.10.1.tar.gz"
p_md5="06de2221495e94eb49a851c61e6b9705"
p_dir="ngx_openresty-1.7.10.1"
p_url="https://github.com/openresty/ngx_openresty/archive/$p_file"

set -e
##download...
mkdir -p ~/tmp; cd ~/tmp
if [[ -f $p_file && `md5sum $p_file|awk '{print $1}'` == "$p_md5" ]]; then
	echo "$p_file is ready."
else
	wget "$p_url" -O $p_file
fi

##install...
tar -zxvf $p_file
cd $p_dir
make try-luajit 
cd $p_dir
make
$SUDO make install

##prepare safe-config
$SUDO mkdir -p $openresty_path/{vhost,project,project.lualib}
cd $CUR_DIR
$SUDO cp ./resource/nginx.conf $openresty_path/nginx/conf/

##clean...
cd ~/tmp
rm -rf $p_file
rm -rf $p_dir

