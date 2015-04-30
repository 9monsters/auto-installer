#!/bin/bash
# 文件名：mount-ntfsdisk.sh
# 默认：挂载NTFS分区
# 参数: u/-u 为卸载NTFS分区

scriptBaseDir="/data/InitScript"
colorFile="${scriptBaseDir}/color-string.sh"
fuseFile="${scriptBaseDir}/install-fuse.sh"
ntfs3gFile="${scriptBaseDir}/install-ntfs-3g.sh"
tDir="/mnt/windows"
fstabFile="/etc/fstab"
# 数组成员依次为：源目录、挂载目录
ntfsDisk=`fdisk -l | grep NTFS | awk '{print $1}'`
if [ -z "${ntfsDisk}" ];then
	echo `"${colorFile}" "未发现NTFS分区。" Brown 0 0`
	exit 0
fi
# 卸载网络磁盘函数
unmount-ntfsdisk()
{
	mount -l | grep "${tDir}" > /dev/null
	if [ "${?}" -eq 0 ];then
		umount "${tDir}"
		ec="${?}"
		if [ "${ec}" -eq 0 ];then
			echo `"${colorFile}" "卸载：${tDir} 成功！" Green 0 0`
		else
			echo `"${colorFile}" "卸载：${tDir} 失败！ErrorCode:${ec}" Red 0 0`
		fi
	else
	 	echo `"${colorFile}" "未挂载：${tDir} 。" Brown 0 0`
	fi
}
# 判断是否为卸载
if [ "${1}" = "u" -o "${1}" = "-u" ];then
	unmount-ntfsdisk
	exit 0
fi
# 检查挂载前置条件
fuser -V
if [ "${?}" -ne 0 ];then
	${fuseFile}
fi
ntfs-3g -V
if [ "${?}" -ne 0 ];then
	${ntfs3gFile}
fi
# 挂载NTFS磁盘
mkdir -p ${tDir}
mount -l | grep ${tDir} > /dev/null
if [ ${?} -eq 1 ];then
	mount -t ntfs-3g ${ntfsDisk} ${tDir}
	ec=${?}
	if [ ${ec} -eq 0 ];then
		echo `${colorFile} "挂载：${tDir} 成功！" Green 0 0`
	else
		echo `${colorFile} "挂载：${tDir} 失败！ErrorCode:${ec}" Red 0 0`
	fi
else
 	echo `${colorFile} "已挂载：${tDir} 。" Brown 0 0`
fi
# 设置开机自动加载
grep ${tDir} ${fstabFile}
if [ "$?" -ne 0 ];then
	echo "${ntfsDisk}		${tDir}		ntfs-3g defaults	0 0" >> ${fstabFile}
fi