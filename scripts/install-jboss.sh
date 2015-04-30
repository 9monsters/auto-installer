#!/bin/bash
# 文件名：install-jboss.sh

scriptBaseDir="/data/InitScript"
bash ${scriptBaseDir}/mount-netdisk.sh
nowTime=`date '+%Y%m%d%H%M%S'`
colorFile="${scriptBaseDir}/color-string.sh"

setupFile="/mnt/wol-fileshare-s/OPVol/JBoss/jboss-4.2.3.GA.zip"
extractDir="/data/programfiles/"
verName=`unzip -l ${setupFile} | awk '{if(NR==4)print $4}'`
programDir="/data/programfiles/"${verName}
hostsFile="/etc/hosts"
linkDir="/usr/local/jboss"
serverXml="${linkDir}/server/default/deploy/jboss-web.deployer/server.xml"
mysqlConnectorFile="/mnt/autotestsvr/Document/ServerTestFile/SetupFiles/mysql-connector-java-5.1.8-bin.jar"
serviceFile="/etc/rc.d/init.d/jboss"
runSh="${linkDir}/bin/run.sh"
profileFile="/etc/profile.d/jboss.sh"


# 解压安装
unzip "${setupFile}" -d "${extractDir}"

if [ -k "${linkDir}" ];then
        rm -f "${linkDir}"
elif [ -d "${linkDir}" ];then
        mv "${linkDir}" "${linkDir}_${nowTime}"
fi
ln -s "${programDir}" "${linkDir}"
cp -f "${mysqlConnectorFile}" "${linkDir}/server/default/lib/"
cp -f "${scriptBaseDir}/conf/jboss-env.sh" "${profileFile}"
source "${profileFile}"
# 备份指定的两个文件
for changefile in "${serverXml}" "${runSh}"
do
	if [ -f "${changefile}" ];then
		mv "${changefile}" "${changefile}".${nowTime}
		echo `"${colorFile}" "备份${changefile}为${changefile}.${nowTime} 。" Green 0 0`
	fi
done
# 安装jboss-native
mkdir -p /tmp/${nowTime} ${linkDir}/bin/native
tar zxvf /mnt/autotestsvr/Document/ServerTestFile/SetupFiles/jboss-native-2.0.6-linux2-x64-ssl.tar.gz -C /tmp/${nowTime}/ bin/META-INF/lib/linux2/x64
tar zxvf /mnt/autotestsvr/Document/ServerTestFile/SetupFiles/jboss-native-2.0.6-linux2-x64-ssl.tar.gz -C /tmp/${nowTime}/ bin/META-INF/bin/linux2/x64/openssl
mv /tmp/${nowTime}/bin/META-INF/lib/linux2/x64/* ${linkDir}/bin/native/
mv /tmp/${nowTime}/bin/META-INF/bin/linux2/x64/openssl ${linkDir}/bin/
# 修改默认配置文件
cp -f "${scriptBaseDir}/conf/jboss-web-server.xml" "${serverXml}"
cp -f "${scriptBaseDir}/conf/jboss-run.sh" "${runSh}"
cp -f "${linkDir}/bin/jboss_init_redhat.sh" "${serviceFile}"
echo y | cp ${scriptBaseDir}/conf/jboss-run.conf ${linkDir}/bin/run.conf
# 将jboss启用用户设置为root
sed -i 's/JBOSS_USER:-"jboss"/JBOSS_USER:-"root"/g' "${serviceFile}"
chmod +x "${runSh}" "${serviceFile}"
# chkconfig --add jboss

echo `"${colorFile}" "安装成功！目标目录：${linkDir}" Green 0 0`
echo `"${colorFile}" "启动方式：service jboss start" Green 0 0`
