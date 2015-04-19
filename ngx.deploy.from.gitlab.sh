#!/usr/bin/env bash
CUR_DIR=$(cd `dirname $0`;pwd)

if [[ $# -lt 1 ]]; then
	echo "usage: $0 gitlab-repo-name tag-name">&2; exit
fi
_repo="$1"
_tag="$2"
_dir=`echo "$_repo"| sed "s#\(.*/\)\(.*\)#\2#g"`

if [[ -d "$_dir" ]]; then
	echo "dir[$_dir] for repo[$_repo] exists">&2; exit
fi

set -e
mkdir -p ~/tmp/; cd ~/tmp
git clone "git@gitlab.com:$_repo.git"
cd $_dir
git checkout master
if [[ "$_tag" != "" ]]; then
	if [[ `git tag |grep "^$_tag$"|wc -l` -lt 1 ]]; then
		echo "tag-name '$_tag' does not exists.">&2; exit
	fi
	if [[ `git branch|grep "deploy.$_tag"|wc -l` -ge 1 ]]; then
		git branch -d deploy.$_tag
	fi
	git checkout -b deploy.$_tag $_tag
	echo "$_tag" > VERSION
else
	_tag=`git show|grep commit|head -n 1|awk '{print $2}'`
	echo "master.$_tag" > VERSION
fi
cd -

$CUR_DIR/ngx.deploy.sh $_dir
rm -rf $_dir

