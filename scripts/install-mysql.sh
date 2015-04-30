#!/bin/bash
# 文件名：install-mysql.sh

scriptBaseDir="/data/InitScript"
bash ${scriptBaseDir}/mount-netdisk.sh
colorFile="${scriptBaseDir}/color-string.sh"
nowTime=`date '+%Y%m%d%H%M%S'`

setupFile="/mnt/wol-fileshare-s/OPVol/MySql/mysql-5.0.81.tar.gz"
gppFile="/mnt/CentOS_5.3_Final/CentOS/gcc-c++-4.1.2-44.el5.x86_64.rpm"
extractDir="/data/setupfiles/"
verName=`tar -ztf ${setupFile} | head -1`
setupDir="/data/setupfiles/"${verName}
programDir="/data/programfiles/"${verName}
linkDir="/usr/local/mysql"
myCnf="etc/my.cnf"
                                      
# 查看是否安装g++编译器
rpm -qa | grep gcc-c++
hasGpp="${?}"
if [ "${hasGpp}" -ne 0 ];then
	echo `${colorFile} "未发现gcc-c++编译器！" Red 0 0`
	rpm -ivh "${gppFile}"
	echo `${colorFile} "安装gcc-c++成功！" Green 0 0`
fi
# 添加MYSQL用户和组
groupadd mysql
useradd -g mysql mysql
# 创建安装目录
mkdir -p "${programDir}"

if [ -k "${linkDir}" ];then
        rm -f "${linkDir}"
elif [ -d "${linkDir}" ];then
        mv "${linkDir}" "${linkDir}_${nowTime}"
fi
ln -s "${programDir}" "${linkDir}"
# 解压
tar -zxvf "${setupFile}" -C "${extractDir}"
cd "${setupDir}"
make clean
# 预编译
./configure --prefix="${linkDir}" --with-extra-charsets=all --with-charset=utf8
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
# 安装
make install
# 检测安装结果
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make install"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi	
# 修改默认配置
cp -f ./support-files/my-medium.cnf "${myCnf}"
cd "${programDir}"
# 安装数据库文件
./bin/mysql_install_db --user=mysql
# 授权
chown -R root  .
chown -R mysql var
chgrp -R mysql .
# 启动mysql
"${linkDir}/bin/mysqld_safe --user=mysql &"
chmod 777 "${linkDir}/var"
# 注册到系统服务
cp "${linkDir}/share/mysql/mysql.server" "/etc/rc.d/init.d/mysql" 
chmod +x "/etc/rc.d/init.d/mysql"
chkconfig --add mysql
# 设置访问的用户名和密码
"${linkDir}/bin/mysql" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'10.20.%' IDENTIFIED BY '3335688' WITH GRANT OPTION;"
"${linkDir}/bin/mysql" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.%' IDENTIFIED BY '3335688' WITH GRANT OPTION;"
# 首次启动后ID文件不知什么原因不见了，强制关闭重启一下就正常了
${linkDir}/bin/mysqladmin shutdown
if [ -f "${myCnf}" ];then
	mv "${myCnf}" "${myCnf}".${nowTime}
	echo `${colorFile} "备份${myCnf}为${myCnf}.${nowTime} 。" Green 0 0`
fi

echo `${colorFile} "安装成功！目标目录：${linkDir}" Green 0 0`
echo `${colorFile} "查询启动方式：service mysql，启动mysql：" Green 0 0`
# 启动MYSQL服务
service mysql start
