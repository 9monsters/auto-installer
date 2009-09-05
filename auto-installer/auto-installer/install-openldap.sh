#!/bin/bash
# 文件名：install-openldap.sh

scriptBaseDir="/data/InitScript"
colorFile="${scriptBaseDir}/color-string.sh"
nowTime=`date '+%Y%m%d%H%M%S'`

setupFile=/mnt/autotestsvr/Document/ServerTestFile/SetupFiles/openldap-2.3.31.tgz
extractDir=/data/setupfiles/
verName=`tar -ztf ${setupFile} | head -1`
setupDir=/data/setupfiles/${verName}
programDir=/data/programfiles/${verName}
linkDir=/usr/local/openldap

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
# 预编译
export LD_LIBRARY_PATH=/usr/local/berkeleydb/lib/
export CPPFLAGS="-I/usr/local/berkeleydb/include"
export LDFLAGS="-L/usr/local/berkeleydb/lib" 

./configure --prefix="${linkDir}" --enable-dns --enable-cldap --enable-ldapd --enable-wrappers --enable-phonetic --enable-passwd --enable-shell
# 检测预编译结果
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/configure"`${colorFile} " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi
# 编译
make depend && make
# 检测编译结果
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi
# 安装
make install
# 检测安装结果
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make install"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi	

echo `${colorFile} "安装成功！目标目录：${linkDir}" Green 0 0`
