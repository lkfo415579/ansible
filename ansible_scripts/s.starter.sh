#!/bin/bash

nv_gpu_idx=;
local_port=;
local_volume_path=;
image_file_url=;
decoder_version=;

nmt_script_home=`realpath $0`;
nmt_script_home=${nmt_script_home%/*};


function usage()
{
    echo "Usage: $0 -p <port> -v <volume-path> [-m <remote-image-path>]";
    echo "     : -p Specify local port to map, must digit, eg: 2001";
    echo "     : -v Specify volume pathname, is absolute path, eg: ./volume.2001";
    echo "     : -m Specify image access path, don't content image name, defalut nothing.";
    echo "          eg: 10.0.100.138/newtranx/";
    echo "     : -h Output help message.";
    echo "     : -t Decoder version.";
    echo ;
    echo "Built:";
    echo "     : 2017年 04月 12日 星期三 16:32:24 CST (By Shizhengxian),edit 10/13/2017 revo";
    echo ;
}


help_output_flag=;

#-- 必须得添加选项 --#
while getopts "p:v:t:m:h" opt_c; do
    case ${opt_c} in
        p)
            local_port=$OPTARG;
            if [[ $local_port =~ ^[0-9][0-9]*$ ]]; then
                echo "Local port.<"$local_port">";
            else
                help_output_flag=1;

                echo "[Error]: Local port must digit.";
            fi
        ;;
        v)
            local_volume_path=`realpath $OPTARG`;
            if [ -d "$local_volume_path" ]; then
                echo "Local volume absolute path.<"$local_volume_path">";
            else 
                help_output_flag=1;

                echo "[Error]: $local_volume_path : no such directory";
            fi
        ;;
        m)
            image_file_url=$OPTARG;
        ;;
        t)
			decoder_version=$OPTARG;
		;;
        h)
            help_output_flag=1;

            usage;
        ;;
        ?)
            help_output_flag=1;

            usage;
        ;;
    esac
done


if [ ! -n "$help_output_flag" ]; then
    if [ -n "$local_port" ] && [ -n "$local_volume_path" ]; then
	  echo "Current version:v"$decoder_version
      nvidia-docker run -d -w /root/SERVER/bin -p ${local_port}:2001 -v ${local_volume_path}:/nmtserver --name newtranx_server-gpu-v${decoder_version}-${local_port} ${image_file_url}newtranx_server-gpu:v${decoder_version} /root/SERVER/server.start
    else 
        usage;
    fi
fi


exit 0;

