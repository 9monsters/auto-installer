#!/bin/bash
# 文件名：mount-netdisk.sh
# 默认：挂载目前已知且需要的网络共享目录
# 参数: u/-u 为卸载已挂载的网络共享
scriptBaseDir="/data/InitScript"
colorFile="${scriptBaseDir}/color-string.sh"
# 数组成员依次为：源目录、挂载目录
netDisk1="//10.20.221.17/OPVol,/mnt/wol-fileshare-s/OPVol"
netDisk2="//10.20.221.17/SoftVol,/mnt/wol-fileshare-s/SoftVol"
netDisk3="//10.20.219.41/Document,/mnt/autotestsvr/Document"
result=0
# 卸载网络磁盘函数
unmount-netdisk()
{
# 先卸载DVD镜像的挂载	
	${scriptBaseDir}/mount-centos53dvd.sh -u
	
	for netDisk in "${netDisk1}" "${netDisk2}" "${netDisk3}"
	do
		sDir=`echo "${netDisk}" | awk -F, '{print $1}'`
		tDir=`echo "${netDisk}" | awk -F, '{print $2}'`
		mount -l | grep "${tDir}" > /dev/null
		if [ "${?}" -eq 0 ];then
			umount "${tDir}"
			ec="${?}"
			if [ "${ec}" -eq 0 ];then
				echo `"${colorFile}" "卸载：${tDir} 成功！" Green 0 0`
			else
				echo `"${colorFile}" "卸载：${tDir} 失败！ErrorCode:${ec}" Red 0 0`
				((result++))
			fi
		else
		 	echo `"${colorFile}" "未挂载：${tDir} 。" Brown 0 0`
		fi
	done
}
# 判断是否为卸载
if [ "${1}" = "u" -o "${1}" = "-u" ];then
	unmount-netdisk
	exit 0
fi
# 挂载网络磁盘
for netDisk in "${netDisk1}" "${netDisk2}" "${netDisk3}"
do
	sDir=`echo "${netDisk}" | awk -F, '{print $1}'`
	tDir=`echo "${netDisk}" | awk -F, '{print $2}'`
	mkdir -p "${tDir}"
	mount -l | grep "${tDir}" > /dev/null
	if [ "${?}" -eq 1 ];then
		mount -t cifs "${sDir}" "${tDir}" -o username=wps,password=wps -r
		ec="${?}"
		if [ "${ec}" -eq 0 ];then
			echo `"${colorFile}" "挂载：${tDir} 成功！" Green 0 0`
		else
			echo `"${colorFile}" "挂载：${tDir} 失败！ErrorCode:${ec}" Red 0 0`
			((result++))
		fi
	else
	 	echo `"${colorFile}" "已挂载：${tDir} 。" Brown 0 0`
	fi
done
# 挂载DVD镜像	
"${scriptBaseDir}/mount-centos53dvd.sh"

exit "${result}"
