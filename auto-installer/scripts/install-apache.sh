#!/bin/bash
# 文件名：intall-apache.sh
# 指定安装文件目录、安装目录等依赖信息

scriptBaseDir="/data/InitScript"
bash ${scriptBaseDir}/mount-netdisk.sh
nowTime=`date '+%Y%m%d%H%M%S'`
colorFile="${scriptBaseDir}/color-string.sh"

setupFile="/mnt/wol-fileshare-s/OPVol/Apache/httpd-2.2.11.tar.bz2"
extractDir="/data/setupfiles/"
verName=`tar -jtf ${setupFile} | head -1`
setupDir="/data/setupfiles/"${verName}
programDir="/data/programfiles/"${verName}
linkDir="/usr/local/apache"
httpConf="${linkDir}/conf/httpd.conf"

# 创建安装目录
mkdir -p "${programDir}"
# 创建软件链接到安装目录
if [ -k "${linkDir}" ];then
        rm -f "${linkDir}"
elif [ -d "${linkDir}" ];then
        mv "${linkDir}" "${linkDir}_${nowTime}"
fi
ln -s "${programDir}" "${linkDir}"
# 解压安装文件
tar -jxvf "${setupFile}" -C "${extractDir}"
cd "${setupDir}"
make clean
# 告诉编译器将程序安装到链接地址
./configure --prefix="${linkDir}" --enable-so --enable-mods-shared=most --enable-rewrite --enable-forward 
# 检测是否预编译成功
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/configure"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi
# 执行编译
make
# 检查编译是否成功
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi
# 执行安装
make install
# 检查是否安装成功
ec=${?}
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make install"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi	
# 修改默认配置文件，若存在则备份一个
# if [ -f "${httpConf}" ];then
#	mv "${httpConf}" "${httpConf}".${nowTime}
#	echo `"${colorFile}" "备份${httpConf}为${httpConf}.${nowTime} 。" Green 0 0`
# fi

# cp -f "${scriptBaseDir}/conf/httpd.conf" "${httpConf}"
cp -f "${linkDir}/bin/apachectl" /etc/rc.d/init.d/httpd
# 打印安装信息
echo `"${colorFile}" "安装成功！目标目录：${linkDir}" Green 0 0`
echo `"${colorFile}" "启动方式：service httpd -k start" Green 0 0`
