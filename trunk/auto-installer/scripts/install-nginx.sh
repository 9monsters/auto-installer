#!/bin/bash
# 文件名：install-nginx.sh

scriptBaseDir="/data/InitScript"
# 检查pcre是否安装
pcreDir="/usr/local/pcre"
if [ -k "${pcreDir}" ];then
        rm -f "${pcreDir}"
elif [ -d "${pcreDir}" ];then
        mv "${pcreDir}" "${pcreDir}_${nowTime}"
fi
${scriptBaseDir}/install-pcre.sh
# 安装Nginx
bash ${scriptBaseDir}/mount-netdisk.sh
nowTime=`date '+%Y%m%d%H%M%S'`
colorFile="${scriptBaseDir}/color-string.sh"

setupFile="/mnt/wol-fileshare-s/OPVol/nginx-0.6.36.tar.gz"
gppFile="/mnt/CentOS_5.3_Final/CentOS/gcc-c++-4.1.2-44.el5.x86_64.rpm"
extractDir="/data/setupfiles/"
verName=`tar -ztf "${setupFile}" | head -1`
setupDir="/data/setupfiles/"${verName}
programDir="/data/programfiles/"${verName}
linkDir="/usr/local/nginx"

# 查看是否安装g++编译器
rpm -qa | grep gcc-c++
hasGpp="${?}"
if [ "${hasGpp}" -ne 0 ];then
	echo `${colorFile} "未发现gcc-c++编译器！" Red 0 0`
	rpm -ivh "${gppFile}"
	echo `${colorFile} "安装gcc-c++成功！" Green 0 0`
fi
# 创建用户和组
/usr/sbin/groupadd www 
/usr/sbin/useradd -g www www
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
./configure --prefix="${linkDir}" --user=www --group=www --with-http_stub_status_module --with-http_perl_module --with-pcre=${extractDir}/pcre-6.3/ 
# --without-http_rewrite_module
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
ec=${?}
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make install"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi	

echo `"${colorFile}" "安装成功！目标目录：${linkDir}" Green 0 0`
