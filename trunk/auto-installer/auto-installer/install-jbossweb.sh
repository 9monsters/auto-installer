#!/bin/bash
# 文件名：install-jboss.sh

scriptBaseDir="/data/InitScript"
bash ${scriptBaseDir}/mount-netdisk.sh
nowTime=`date '+%Y%m%d%H%M%S'`
colorFile="${scriptBaseDir}/color-string.sh"

setupFile="/mnt/autotestsvr/Document/ServerTestFile/SetupFiles/jboss-web-2.1.2.GA.zip"
extractDir="/data/programfiles/"
verName=`unzip -l ${setupFile} | awk '{if(NR==4)print $4}'`
programDir="/data/programfiles/"${verName}
# hostsFile="/etc/hosts"
linkDir="/usr/local/jbossweb"
serverXml="${linkDir}/conf/server.xml"
# serviceFile="/etc/rc.d/init.d/jbossweb"
runSh="${linkDir}/bin/startup.sh"
# profileFile="/etc/profile.d/jbossweb.sh"


# 解压安装
unzip "${setupFile}" -d "${extractDir}"

if [ -k "${linkDir}" ];then
        rm -f "${linkDir}"
elif [ -d "${linkDir}" ];then
        mv "${linkDir}" "${linkDir}_${nowTime}"
fi
ln -s "${programDir}" "${linkDir}"
# cp -f "${scriptBaseDir}/conf/jboss_env.sh" "${profileFile}"
# source "${profileFile}"
# 备份指定的两个文件
# for changefile in "${serverXml}" "${runSh}"
# do
# 	if [ -f "${changefile}" ];then
# 		mv "${changefile}" "${changefile}".${nowTime}
# 		echo `"${colorFile}" "备份${changefile}为${changefile}.${nowTime} 。" Green 0 0`
# 	fi
# done
# 修改默认配置文件
cp -f "${scriptBaseDir}/conf/jbossweb-server.xml" "${serverXml}"
cp -f "${scriptBaseDir}/conf/jbossweb-catalina.sh" "${linkDir}/conf/catalina.sh"
# cp -f "${linkDir}/bin/jboss_init_redhat.sh" "${serviceFile}"

# 将jboss启用用户设置为root
# sed -i 's/JBOSS_USER:-"jboss"/JBOSS_USER:-"root"/g' "${serviceFile}"
# chmod +x "${runSh}" "${serviceFile}"
# chkconfig --add jboss
chmod +x ${linkDir}/bin/*.sh
echo `"${colorFile}" "安装成功！目标目录：${linkDir}" Green 0 0`
echo `"${colorFile}" "启动方式：${runSh}" Green 0 0`
