#!/bin/bash
# 文件名install-fuse.sh

scriptBaseDir="/data/InitScript"
bash ${scriptBaseDir}/mount-netdisk.sh
nowTime=`date '+%Y%m%d%H%M%S'`
colorFile="${scriptBaseDir}/color-string.sh"

setupFile="/mnt/autotestsvr/Document/ServerTestFile/SetupFiles/fuse-2.7.4.tar.gz"
extractDir="/data/setupfiles/"
verName=`tar -ztf ${setupFile} | head -1`
setupDir="/data/setupfiles/"${verName}
programDir="/data/programfiles/"${verName}
linkDir="/usr/local/fuse"

mkdir -p "${programDir}"

if [ -k "${linkDir}" ];then
        rm -f "${linkDir}"
elif [ -d "${linkDir}" ];then
        mv "${linkDir}" "${linkDir}_${nowTime}"
fi
ln -s "${programDir}" "${linkDir}"

tar -zxvf "${setupFile}" -C "${extractDir}"
cd "${setupDir}"
make clean
./configure --prefix="${linkDir}"
ec=${?}
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/configure"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi	
make
ec=${?}
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi	
make install
ec=${?}
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make install"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi	

echo `"${colorFile}" "安装成功！目标目录：${linkDir}" Green 0 0`
