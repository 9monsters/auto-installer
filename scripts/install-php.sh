#!/bin/bash
# 文件名：install-php.sh

scriptBaseDir="/data/InitScript"
colorFile="${scriptBaseDir}/color-string.sh"
nowTime=`date '+%Y%m%d%H%M%S'`

setupFile=/mnt/wol-fileshare-s/OPVol/Php/php-5.2.6.tar.bz2
extractDir=/data/setupfiles/
verName=`tar -jtf ${setupFile} | head -1`
setupDir=/data/setupfiles/${verName}
programDir=/data/programfiles/${verName}
linkDir=/usr/local/php

 安装前依赖软件
cd ${scriptBaseDir}
./install-berkeleydb.sh &
./install-libxml.sh &
./install-libmcrypt.sh &
./install-libiconv.sh
./install-libtool.sh
./install-openldap.sh
./install-zlib.sh &
./install-pcre.sh &
./install-spawn-fcgi.sh &
./install-libpng.sh &
./install-zlib.sh &
./install-jpeg.sh
./install-nginx.sh
./install-freetype.sh
./install-gd.sh

mkdir -p "${programDir}"

if [ -k "${linkDir}" ];then
        rm -f "${linkDir}"
elif [ -d "${linkDir}" ];then
        mv "${linkDir}" "${linkDir}_${nowTime}"
fi
ln -s "${programDir}" "${linkDir}"

tar -jxvf "${setupFile}" -C "${extractDir}"
cd "${setupDir}"
cd ../
cp /mnt/autotestsvr/Document/ServerTestFile/SetupFiles/php-5.2.6-fpm-0.5.9.diff.gz ./
gzip -cd php-5.2.6-fpm-0.5.9.diff.gz | patch -d php-5.2.6 -p1
rm -f ./php-5.2.6-fpm-0.5.9.diff.gz
cd "${setupDir}"
make clean
# 预编译
./configure --prefix="${linkDir}" \
	--with-apxs2=/usr/local/apache/bin/apxs \
	--with-mysql=/usr/local/mysql --with-mysql-sock=/tmp/mysql.sock --with-pdo-mysql=/usr/local/mysql/bin/mysql_config \
	--with-ldap=/usr/local/openldap \
	--with-zlib=/usr/local/zlib \
	--with-gd=/usr/local/gd --enable-gd-native-ttf \
	--with-freetype-dir=/usr/local/freetype \
	--with-jpeg-dir=/usr/local/jpeg \
	--with-png-dir=/usr/local/libpng \
	--with-xmlpc --with-pcre-regex --with-curl --with-curlwrappers \
	--enable-xml --enable-fastcgi --enable-sockets --enable-mbstring=all \
	--enable-magic-quotes --enable-force-cgi-redirect --enable-mbregex \
	--enable-shmop --enable-sysvsem --enable-inline-optimization \
	--enable-force-cgi-redirect --enable-fpm --enable-calendar --enable-bcmath \
	--enable-safe-mode --disable-debug --enable-zend-multibyte --enable-discard-path \
	--enable-inline-optimization --enable-exif --enable-pdo --with-openssl=/usr/local/openssl

sed -i 's#-lz -lm -lxml2 -lz -lm -lxml2 -lz -lm -lcrypt#& -liconv#' Makefile
# 检测预编译结果
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/configure"`${colorFile} " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi
# 编译
make
# 检测编译结果
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi
# 编译测试
make test
# 检测编译结果
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make test"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
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
