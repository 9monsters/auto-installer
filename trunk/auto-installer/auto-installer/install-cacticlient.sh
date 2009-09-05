#!/bin/bash
# 文件名：install-cacticlient.sh
# 安装cacti客户端

scriptBaseDir="/data/InitScript"
bash /data/InitScript/mount-netdisk.sh
nowTime=`date '+%Y%m%d%H%M%S'`
colorFile="${scriptBaseDir}/color-string.sh"

setupFile="/mnt/autotestsvr/Document/ServerTestFile/SetupFiles/monitor.tar"
extractDir="/opt/kingsoft"
programDir="/opt/kingsoft/monitor"

mkdir -p /opt/kingsoft
if [ -d '/opt/kingsoft/monitor' ];then
  mv /opt/kingsoft/monitor /opt/kingsoft/monitor_${nowTime}.bak
	echo `${colorFile} "备份原monitor到monitor_${nowTime}.bak" Green 0 0`
fi
tar -xPf ${setupFile}
cd ${programDir}
/opt/kingsoft/monitor/core/cron/cactirelease.sh
/opt/kingsoft/monitor/core/cron/main.sh intranet >> /dev/null 2>&1 &
if [ "${?}" -eq 0 ];then
	echo `${colorFile} "安装成功！" Green 0 0`
else
	echo `${colorFile} "安装失败！" Red 0 0`
fi
