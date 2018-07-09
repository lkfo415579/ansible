#!/bin/bash

function nmtserver_stop()
{
    start_cmd="./nmtserver.stop.rm $1";
    echo "[Stop]: $start_cmd";
    rc=`$start_cmd`;
}

function nmtserver_start()
{
    start_cmd="./s.start -p $1 -v ~/nmt_volumes/volumes.$1 -t $2";
    echo "[Start]: $start_cmd";
    rc=`$start_cmd`;
}

function nmtserver_remove_start()
{
	start_cmd="./remove_online.sh $1 $2";
	echo "[Stop/Start]: $start_cmd";
	rc=`$start_cmd`;
}

filename="volumes";
while read -r line
do
	# nmtserver_stop "$line";
	nmtserver_remove_start "$line" $1;
done < "$filename"
echo "All Finished"
docker ps -a

exit 0;
