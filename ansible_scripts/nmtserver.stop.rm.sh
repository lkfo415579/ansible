#!/bin/bash

if [ $# -gt 0 ]; then
	for p in $@; do
		for id in `nvidia-docker ps -a | grep newtranx_server | grep "\-$p" | awk '{print $1'}`; do 
		    if [ ! "$id" = "CONTAINER" ]; then
		        echo "Stop  : "$id; 
		        rc=`nvidia-docker stop $id`;
		        echo "Delete: "$id; 
		        rc=`nvidia-docker rm $id`;
		    fi
		done
	done
else 
	echo "Usage: $0 <ports>";
	echo "   eg: $0 2001 2002 2003";
	echo "Thanks.";
fi


nvidia-docker ps -a


exit 0;

