#!/bin/bash
# 文件名；set-openfiles.sh
# 参数一：需要修改的数值，默认为81920
nowTime=`date '+%Y%m%d%H%M%S'`
scriptBaseDir="/data/InitScript"
profileFile="/etc/profile.d/openfile.sh"
colorFile="${scriptBaseDir}/color-string.sh"
openFileValue="81920"
# 处理参数一
if [ -z "${1}" ] ;then
	echo `"${colorFile}" "使用默认值：${openFileValue}" Brown 0 0`
else 
	echo "${1}" | grep '[^0-9]'
	if [ "${?}" -eq 1 ];then
		openFileValue="${1}"
	fi
fi
# 修改文件描述符大小
echo "ulimit -n ${openFileValue}" > "${profileFile}"
echo `${colorFile} "重启系统、注销或手动执行：source /etc/profile 生效。" Green 0 0`

source "${profileFile}"
echo `"${colorFile}" "文件描述符修改为：${openFileValue}" Green 0 0`
