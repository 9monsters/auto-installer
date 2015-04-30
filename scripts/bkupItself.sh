#!/bin/bash
# backup or resume /data/InitScript
usage="Usage: 
        ${0} [resume|u] [backupFile]
		resume: Cover from backupFile .
		u     : Replace by backupFile .
        Example: ${0} 
		 ${0} resume ${bkupFolder}/${bkupFileName}
		 ${0} u ${bkupFolder}/${bkupFileName}"
nowTime=`date '+%Y%m%d%H%M%S'`
scriptBaseDir="/data/InitScript"
colorFile="${scriptBaseDir}/color-string.sh"
bkupFolder=/tmp
bkupFileName=AutoInstaller_${nowTime}.tgz

CheckParam(){
	if [ -z "${2}"];then
		echo -e "${usage}"
		echo "Please input backupFile !"
	elif [ -e "${2}" ];then
		echo -n `"${colorFile}" "从文件${2}进行恢复..." Green 0 0`  
	else
		echo "Make sure backupFile ${2} exist !"
		exit 1
	fi
}
case "${1}" in
        -h | --help)
          echo -e "${usage}"
          exit 0
        ;;
        '' | 0)
	tar -zcvPf "${bkupFolder}/${bkupFileName}" ${scriptBaseDir} ${extractDir} ${programDir} --exclude=/data/setupfiles/* --exclude=/data/programfiles/* --exclude=${scriptBaseDir}/*~
	echo -n `"${colorFile}" "备份InitScript到${bkupFolder}/${bkupFileName}成功！" Green 0 0`
	exit 0
	;;
	-resume | resume)
	  CheckParam
	  tar -zxvPf ${2}
	  exit 0
        ;;
        -u | u)
	  CheckParam
	  mv /data/web/data /data/web/data_${nowTime}.old
	  mv /data/web/cacti4 /data/web/cacti4_${nowTime}.old
	  tar -zxvPf ${2}
          exit 0
        ;;
esac
echo "${usage}"
