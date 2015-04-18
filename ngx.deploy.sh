#!/usr/bin/env bash
if [[ "$1" == "" || ! -d $1 ]]; then
	echo "usage: $0 project-dir">&2; exit
fi

CUR_DIR=$(cd `dirname $0`;pwd)
. $CUR_DIR/inc/deploy.sh

src_dir="`tool_get_src_dir $1`"
src_name=`tool_get_src_name $1`
src_version=`tool_get_src_version $1`
if [[ "$src_version" == "" ]];then
	echo "$src_dir/VERSION is missing, or empty.">&2
	echo "$src_dir/VERSION should be generated, be4 deployment.">&2
	exit
fi

if [[ ! -f "$src_dir/${src_name}.ngx.conf" ]]; then
	echo "$src_dir/${src_name}.ngx.conf is missing.">&2; exit
fi

set -e

case `tool_get_src_type $1` in
	:lua:) . $CUR_DIR/inc/deploy.lua.sh ;;
	:php:) . $CUR_DIR/inc/deploy.php.sh ;;
	:lua:php:) . $CUR_DIR/inc/deploy.luaphp.sh;;
	*) echo "unrecognized project-type.">&2;exit ;;
esac

func_deploy $1

