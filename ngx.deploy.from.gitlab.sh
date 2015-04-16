#!/usr/bin/env bash
CUR_DIR=$(cd `dirname $0`;pwd)

if [[ $# -lt 1 ]]; then
	echo "usage: $0 gitlab-repo-name tag-name">&2; exit
fi
repo="$1"
tag="$2"

if [[ -d "$repo" ]]; then
	echo "dir $repo exists">&2; exit
fi

set -e
mkdir -p ~/tmp/
cd ~/tmp
git clone "git@gitlab.com:$repo.git"
cd $repo
if [[ "$tag" != "" ]]; then
	if [[ `git tag |grep "$tag"|wc -l` -lt 1 ]]; then
		echo "tag-name $tag does not exists.">&2; exit
	fi
	git checkout "$tag"
fi
cd -

$CUR_DIR/ngx.deploy.sh $repo
rm -rf $repo

