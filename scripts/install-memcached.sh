#!/bin/bash
# 文件名：install-memcached.sh

scriptBaseDir="/data/InitScript"
bash ${scriptBaseDir}/mount-netdisk.sh
nowTime=`date '+%Y%m%d%H%M%S'`
colorFile="${scriptBaseDir}/color-string.sh"

setupFile="/mnt/autotestsvr/Document/ServerTestFile/SetupFiles/memcached-1.4.0-rc1.tar.gz"
extractDir="/data/setupfiles/"
verName=`tar -ztf ${setupFile} | head -1`
setupDir="/data/setupfiles/"${verName}
programDir="/data/programfiles/"${verName}
linkDir="/usr/local/memcached"

# 创建安装目录
tar -zxvf "${setupFile}" -C "${extractDir}"
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
./configure --prefix="${linkDir}" --with-libevent="/usr/local/libevent"
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/configure"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi
# 编译
make
ec=${?}
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi
# 安装	
make install
ec=${?}
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make install"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi	

echo `"${colorFile}" "安装成功！目标目录：${linkDir}" Green 0 0`
# 安装程序没做好，LIB库里总是差这个文件，拷贝之
cp -f "/usr/local/libevent/lib/libevent-1.4.so.2" "/usr/lib/libevent-1.4.so.2"
cp -f "/usr/local/libevent/lib/libevent-1.4.so.2" "/usr/lib64/libevent-1.4.so.2"
echo "启动示例："
echo `"${colorFile}" "${linkDir}/bin/memcached -d -m 100 -u root -p 11211 -c 1024 -P /tmp/memcached.pid"  Green 0 0`