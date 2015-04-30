#!/bin/bash
# 文件名：environment-set.sh
# 负责初始化任务

cd $(dirname $0)

scriptBaseDir=`pwd`
colorFile="${scriptBaseDir}/color-string.sh"
setupIni="${scriptBaseDir}/conf/setup.ini"
timeMark=`date '+%Y%m%d-%H%M%S'`
envTmpFile=${scriptBaseDir}/logs/env.log

export scriptBaseDir colorFile timeMark
# 将脚本目录保存到配置文件中
sed -i "s%^scriptBaseDir*.$%scriptBaseDir=${scriptBaseDir}%g" ${scriptBaseDir}/conf/setup.ini
# 检查系统是否支持中文显示
if [ $(locale -a | grep "zh_CN.utf8") = "" ];then
	echo `${colorFile} "Warning ! your system Don't support zh_CN.utf8 ." Brown 0 0`
else
	echo `${colorFile} "系统支持'zh_CN.utf8'编码" Green 0 0`
fi
# 读取所有环境变量并导出
grep "=" ${setupIni} > ${envTmpFile}
. ${envTmpFile}
# 打印基础信息
cat >> ${envTmpFile} <<_baseInfo
timeMark=${timeMark}
colorFile=${colorFile}
extractDir=${extractDir}
installDir=${installDir}
setupIni=${setupIni}
envTmpFile=${envTmpFile}
_baseInfo
echo "基础环境信息："
cat ${envTmpFile}
# 挂载网络驱动器
echo "挂载网络驱动器："
${scriptBaseDir}/mount-netdisk.sh
if [ "${?}" -ne 0 ];then
	echo `${colorFile} "挂载网络磁盘失败，程序退出！" Red 0 0`
	exit 1
fi
# 检查本机DVD安装源
grep "\[AutoInstaller\]" /etc/yum.repos.d/CentOS-Media.repo
if [ "${?}" -ne 0 ];then
	cat >> /etc/yum.repos.d/CentOS-Media.repo <<_yumSource
[AutoInstaller]
name=CentOS-$releasever - Media
baseurl=file:///mnt/CentOS_5.3_Final/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
_yumSource
	echo `${colorFile} "添加[AutoInstaller]安装源" Green 0 0`
else
	echo `${colorFile} "发现[AutoInstaller]安装源" Green 0 0`
fi
# 查看是否安装g++编译器
rpm -qa | grep gcc-c++
if [ "$?" -ne 0 ];then
	gppFile="${centosDVD}/gcc-c++-4.1.2-44.el5.x86_64.rpm"
	echo `${colorFile} "未发现gcc-c++编译器！" Red 0 0`
	yum -y --disablerepo=\* --enablerepo=AutoInstaller localinstall "${gppFile}"
	echo `${colorFile} "安装gcc-c++成功！" Green 0 0`
else
	echo `${colorFile} "系统已安装gcc-c++" Green 0 0`
fi
