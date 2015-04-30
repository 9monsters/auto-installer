#!/bin/bash
# 文件名：install-ntfs-3g.sh

scriptBaseDir="/data/InitScript"
bash ${scriptBaseDir}/mount-netdisk.sh
nowTime=`date '+%Y%m%d%H%M%S'`
colorFile="${scriptBaseDir}/color-string.sh"

setupFile="/mnt/autotestsvr/Document/ServerTestFile/SetupFiles/ntfs-3g-2009.4.4.tgz"
extractDir="/data/setupfiles/"
verName=`tar -tf "${setupFile}" | head -1`
setupDir="/data/setupfiles/${verName}"
programDir="/data/programfiles/${verName}"
linkDir="/usr/local/ntfs-3g"

tar -xvf "${setupFile}" -C "${extractDir}"
mkdir -p "${programDir}"

if [ -k "${linkDir}" ];then
        rm -f "${linkDir}"
elif [ -d "${linkDir}" ];then
        mv "${linkDir}" "${linkDir}_${nowTime}"
fi
ln -s "${programDir}" "${linkDir}"
cd "${setupDir}"
make clean
# 预编译
./configure --prefix="${linkDir}"
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/configure"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi
# 编译
make
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi
# 安装
make install
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make install"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi	

echo `"${colorFile}" "安装成功！目标目录：${linkDir}" Green 0 0`