#!/bin/bash
# 文件名：install-memcached.sh

scriptBaseDir="/data/InitScript"
bash ${scriptBaseDir}/mount-netdisk.sh
nowTime=`date '+%Y%m%d%H%M%S'`
colorFile="${scriptBaseDir}/color-string.sh"

setupFile="/mnt/autotestsvr/Document/ServerTestFile/SetupFiles/libevent-1.4.11-stable.tar.gz"
extractDir="/data/setupfiles/"
verName=`tar -ztf ${setupFile} | head -1`
setupDir="/data/setupfiles/"${verName}
programDir="/data/programfiles/"${verName}
linkDir="/usr/local/libevent"

# 创建安装目录
mkdir -p "${programDir}"

if [ -k "${linkDir}" ];then
        rm -f "${linkDir}"
elif [ -d "${linkDir}" ];then
        mv "${linkDir}" "${linkDir}_${nowTime}"
fi
ln -s "${programDir}" "${linkDir}"
# 解压安装文件
tar -zxvf "${setupFile}" -C "${extractDir}"
cd "${setupDir}"
make clean
# 预编译
./configure --prefix="${linkDir}"
# 检查预编译状态
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/configure"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi
# 编译
make
# 检查编译状态
ec=${?}
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi
# 执行安装
make install
# 检查安装状态
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make install"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi	

echo `"${colorFile}" "安装成功！目标目录：${linkDir}" Green 0 0`