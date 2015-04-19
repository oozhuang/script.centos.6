#!/usr/bin/env bash
CUR_DIR=$(cd `dirname $0`;pwd)

if [[ $# -lt 1 ]]; then
	echo "usage: $0 gitlab-repo-name tag-name">&2; exit
fi
repo="$1"
tag="$2"
dir=`echo "$repo"| sed "s#\(.*/\)\(.*\)#\2#g"`

if [[ -d "$dir" ]]; then
	echo "dir[$dir] for repo[$repo] exists">&2; exit
fi

set -e
mkdir -p ~/tmp/; cd ~/tmp
git clone "git@gitlab.com:$repo.git"
cd $dir
git checkout master
if [[ "$tag" != "" ]]; then
	if [[ `git tag |grep "^$tag$"|wc -l` -lt 1 ]]; then
		echo "tag-name '$tag' does not exists.">&2; exit
	fi
	if [[ `git branch|grep "deploy.$tag"|wc -l` -ge 1 ]]; then
		git branch -d deploy.$tag
	fi
	git checkout -b deploy.$tag $tag
	echo "$tag" > VERSION
else
	tag=`git show|grep commit|head -n 1|awk '{print $2}'`
	echo "master.$tag" > VERSION
fi
cd -

$CUR_DIR/ngx.deploy.sh $dir
rm -rf $dir

