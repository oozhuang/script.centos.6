#!/usr/bin/env bash
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
	test) sudo $NGINX -t $NGINX_OPT ;;
	start) sudo $NGINX $NGINX_OPT ;;
	reload) sudo $NGINX -s reload;;
	restart) sudo $NGINX -s stop; sudo $NGINX $NGINX_OPT ;;
	stop) sudo $NGINX -s stop;;
	*) func_help ;;
esac

