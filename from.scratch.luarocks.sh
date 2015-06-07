#!/usr/bin/env bash
CUR_DIR=$(cd `dirname $0`;pwd)
SUDO="";if [[ "root" != `whoami` ]]; then SUDO="sudo";fi

openresty_path="/usr/local/openresty"
p_file="v2.2.1.tar.gz"
p_md5="397bfd22f9d9137b15881d9e2ef30f7c"
p_dir="luarocks-2.2.1"
p_url="https://github.com/keplerproject/luarocks/archive/$p_file"
lua_dir="$openresty_path/luajit"

if [[ ! -d "$lua_dir" ]]; then
	echo "$lua_dir is not found. get it ready, plz.">&2; exit 
fi

cd $lua_dir
lua_inc="$lua_dir/include/`ls ./include/ |grep luajit |head -n 1`"
lua_suffix=`ls ./bin/ |grep luajit|head -n 1 |sed "s/lua//g"`

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

./configure --prefix=$lua_dir --with-lua="$lua_dir" --lua-suffix="$lua_suffix" --with-lua-include="$lua_inc" 
make
$SUDO make bootstrap

##clean...
cd ~/tmp
rm -rf $p_file
rm -rf $p_dir

