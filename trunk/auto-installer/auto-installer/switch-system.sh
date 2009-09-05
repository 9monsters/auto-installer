#!/bin/bash
# 文件名：switch-system.sh

usage="Usage: 
	${0} [-w] [-l] [-h]

	-w ：默认启动Windows操作系统；
	-l ：默认启动Linux操作系统；
	-h ：显示此帮助信息。
Example:
	${0} -w
	重启后将默认进入Windows操作系统。"

if [ "$#" -eq 0 ]; then
	echo -e "${usage}"
	exit 0
fi	
# 处理第一个参数
case "${1}" in 
	-w | w) 
	  cp -f "/mnt/windows/boot.ini.win" "/mnt/windows/boot.ini"
	  exit 0
	;; 
	-l | l) 
	  cp -f "/mnt/windows/boot.ini.lin" "/mnt/windows/boot.ini"
	  exit 0
	;;	
	*)
		echo -e "${usage}"
		exit 0
esac     


