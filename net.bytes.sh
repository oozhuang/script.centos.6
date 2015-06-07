#!/usr/bin/env bash
SUDO="";if [[ "root" != `whoami` ]]; then SUDO="sudo";fi

keys="lo|eth0"
if [[ "$1" != "" ]]; then
	keys="$1"
fi
cat /proc/net/dev | grep -E "$keys" | awk '{printf("%s recv:%f MB, sent:%f MB\n", $1, $2/1048576,$10/1048576)}'
