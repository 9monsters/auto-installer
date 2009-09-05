#!/bin/bash
nowTime=`date '+%Y%m%d%H%M%S'`
scriptBaseDir="/data/InitScript"
ifcfgFile="/etc/sysconfig/network-scripts/ifcfg-eth0"
resolvFile="/etc/resolv.conf"
networkFile="/etc/sysconfig/network"
rollbackFile="/tmp/rollbackIP.sh"
colorFile="${scriptBaseDir}/color-string.sh"

# 生成ifcfg-eth0文件
echo -n `"${colorFile}" "请输入IP地址：10.20.223.11" 7 1`
read ip
echo "设置的IP为：10.20.223.11${ip}"
cp "${ifcfgFile}" "${ifcfgFile}.${nowTime}.bak"
echo "备份${ifcfgFile} --> ${ifcfgFile}.${nowTime}.bak"
echo -e "DEVICE=eth0\nBOOTPROTO=static\nIPADDR=10.20.223.11${ip}\nNETMASK=255.255.254.0\nGATEWAY=10.20.222.1\nTYPE=Ethernet\nONBOOT=yes" > ${ifcfgFile}

# 生成resolv.conf文件
cp "${resolvFile}" "${resolvFile}.${nowTime}.bak"
echo "备份${resolvFile} --> ${resolvFile}.${nowTime}.bak"
echo -e "search localdomain\nnameserver 10.20.18.10\nnameserver 10.20.18.11" > "${resolvFile}"

# 生成network文件
cp "${networkFile}" "${networkFile}.${nowTime}.bak"
echo "备份${networkFile} --> ${networkFile}.${nowTime}.bak"
echo -e "NETWORKING=yes\nNETWORKING_IPV6=no\nHOSTNAME=pSrv${ip}.rdev.kingsoft.net" > "${networkFile}"

# 生成还原配置的脚本
echo -e "mv -f ${ifcfgFile}.${nowTime}.bak ${ifcfgFile}\nmv -f ${resolvFile}.${nowTime}.bak ${resolvFile}\nmv -f ${networkFile}.${nowTime}.bak ${networkFile}\nservice network restart" > ${rollbackFile}
chmod +x "${rollbackFile}"
echo "还原IP设置请执行：${rollbackFile}"

# 重启网络
service network restart
