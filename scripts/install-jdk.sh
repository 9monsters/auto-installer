#!/bin/bash
# 文件名：install-jdk.sh

scriptBaseDir="/data/InitScript"
bash ${scriptBaseDir}/mount-netdisk.sh
nowTime=`date '+%Y%m%d%H%M%S'`
colorFile="${scriptBaseDir}/color-string.sh"

setupFile="/mnt/wol-fileshare-s/OPVol/jdk/jdk-6u12-linux-i586.bin"
extractDir="/data/programfiles/"
linkDir="/usr/local/jdk"
profileFile="/etc/profile.d/java.sh"

# 进入解压目录、解压
cd "${extractDir}"
ls "${extractDir}" > /tmp/s.ls
# 执行安装
"${setupFile}"
# 检查安装状态
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo "${setupFile}"`"${colorFile}" " 安装失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi
ls "${extractDir}" > /tmp/t.ls
#  通过比较目录来确定解压目录
verName=`comm -13 /tmp/s.ls /tmp/t.ls`
if [ -z "${verName}" ];then
# 若目录已存在则取不到解压目录名，取个默认的名字
	verName="jdk1.6.0_12"
fi
rm -f /tmp/s.ls /tmp/t.ls
programDir="/data/programfiles/${verName}"

if [ -k "${linkDir}" ];then
        rm -f "${linkDir}"
elif [ -d "${linkDir}" ];then
        mv "${linkDir}" "${linkDir}_${nowTime}"
fi
ln -s "${programDir}" "${linkDir}"
# 添加JAVA_HOME、JAVA到环境变量
cp -f "${scriptBaseDir}/conf/java-env.sh" "${profileFile}"
source "${profileFile}"
# 添加java到Path
echo "$PATH" | grep "$JAVA_HOME/bin"
if [ "$?" -ne 0 ];then
	export PATH="$PATH:$JAVA_HOME/bin"
fi
