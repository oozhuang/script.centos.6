#!/usr/bin/env bash
SUDO="";if [[ "root" != `whoami` ]]; then SUDO="sudo";fi

function func_help(){
	echo "usage: $0 [test|start|reload|restart|stop]">&2; 
	exit -1;
}
if [[ "$1" == "" ]]; then
	func_help
fi

NGINX_OPT=""
if [[ "$2" != "" ]]; then NGINX_OPT="-c $2"; fi
NGINX="/usr/local/openresty/nginx/sbin/nginx"
case $1 in
	test) $SUDO $NGINX -t $NGINX_OPT ;;
	start) $SUDO $NGINX $NGINX_OPT ;;
	reload) $SUDO $NGINX -s reload;;
	restart) $SUDO $NGINX -s stop; $SUDO $NGINX $NGINX_OPT ;;
	stop) $SUDO $NGINX -s stop;;
	*) func_help ;;
esac

