#!/bin/bash
# 文件名：install-pcre.sh
# 被nginx安装调用

scriptBaseDir="/data/InitScript"
bash ${scriptBaseDir}/mount-netdisk.sh
nowTime=`date '+%Y%m%d%H%M%S'`
colorFile="${scriptBaseDir}/color-string.sh"

setupFile="/mnt/autotestsvr/Document/ServerTestFile/SetupFiles/pcre-6.3.tar.bz2"
extractDir="/data/setupfiles/"
verName=`tar -jtf "${setupFile}" | head -1`
setupDir="/data/setupfiles/${verName}"
programDir="/data/programfiles/${verName}"
linkDir="/usr/local/pcre"

tar -jxvf "${setupFile}" -C "${extractDir}"
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
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/configure"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi	
make
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi	
make install
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make install"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi	

echo `"${colorFile}" "安装成功！目标目录：${linkDir}" Green 0 0`
