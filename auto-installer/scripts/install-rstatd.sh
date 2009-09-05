#!/bin/bash
# 文件名：install-rstatd.sh

scriptBaseDir="/data/InitScript"
bash ${scriptBaseDir}/mount-netdisk.sh
nowTime=`date '+%Y%m%d%H%M%S'`
colorFile="${scriptBaseDir}/color-string.sh"

setupFile="/mnt/autotestsvr/Document/ServerTestFile/SetupFiles/rpc.rstatd-4.0.1.tar.gz"
extractDir="/data/setupfiles/"
verName=`tar -ztf "${setupFile}" | head -1`
setupDir="/data/setupfiles/${verName}"
programDir="/data/programfiles/${verName}"
linkDir="/usr/local/rstatd"

tar zxvf "${setupFile}" -C "${extractDir}"
mkdir -p "${programDir}"

if [ -k "${linkDir}" ];then
        rm -f "${linkDir}"
elif [ -d "${linkDir}" ];then
        mv "${linkDir}" "${linkDir}_${nowTime}"
fi
ln -s "${programDir}" "${linkDir}"
cd "${setupDir}"
make clean
./configure --prefix="${linkDir}"
make
make install



# 启动
/usr/local/rstatd/sbin/rpc.rstatd
# 查看启动状态
rpcinfo -p
