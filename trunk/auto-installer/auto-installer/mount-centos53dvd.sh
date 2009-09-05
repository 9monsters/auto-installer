#!/bin/bash
# 文件名：mount-centos53dvd.sh
# 功能，挂载CentOS5.3_DVD安装光盘。

scriptBaseDir="/data/InitScript"
colorFile="${scriptBaseDir}/color-string.sh"
dvdDir="/mnt/CentOS_5.3_Final"
dvdFile="/mnt/wol-fileshare-s/OPVol/Linux.Release/CentOS.v5.3/x86_64/CentOS-5.3-x86_64-bin-DVD.iso"
result=0
# 确定是否为卸载先
if [ "${1}" = "u" -o "${1}" = "-u" ];then
	mount -l | grep "${dvdFile}" > /dev/null
	hasDVD="${?}"
	if [ "${hasDVD}" -eq 0 ];then
		umount "${dvdDir}"
		ec="${?}"
		if [ "${ec}" -eq 0 ];then
			echo `"${colorFile}" "卸载：${dvdDir} 成功！" Green 0 0`
		else
			echo `"${colorFile}" "卸载：${dvdDir} 失败！ErrorCode:${ec}" Red 0 0`
			((result++))
		fi
	else
	 	echo `"${colorFile}" "未挂载：${dvdDir} 。" Brown 0 0`
	fi
	exit 0	
fi
# 先挂载网络驱动器
if [ -f "${dvdFile}" ];then
	mount -l | grep "${dvdFile}" > /dev/null
	hasDVD="${?}"
	if [ "${hasDVD}" -ne 0 ];then
		mkdir -p ${dvdDir}
		mount -t iso9660 -o loop "${dvdFile}" "${dvdDir}"
		ec="${?}"
		if [ "${ec}" -eq 0 ];then
			echo `"${colorFile}" "挂载：${dvdDir} 成功！" Green 0 0`
		else
			echo `"${colorFile}" "挂载：${dvdDir} 失败！ErrorCode:${ec}" Red 0 0`
			((result++))
		fi	
	else
		echo `"${colorFile}" "已挂载：${dvdDir} 。" Brown 0 0`
	fi
else
# mount-netdisk.sh脚本里已经调用了此脚本，在此不要回调，否则进入死循环。
	echo `"${colorFile}" "请先挂载网络驱动器："${scriptBaseDir}/mount-netdisk.sh Red 0 0`
	((result++))
fi 

exit "${result}"