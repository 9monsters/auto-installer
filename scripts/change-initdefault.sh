#!/bin/bash
# 文件名：change-initdefault.sh

nowTime=`date '+%Y%m%d%H%M%S'`
inittabFile="/etc/inittab"

# 开机不启用图形界面
cp ${inittabFile} ${inittabFile}.${nowTime}.bak
echo "备份${inittabFile} --> ${inittabFile}.${nowTime}.bak"
sed -i 's/\(id\):[0-6]/\1:3/g' ${inittabFile}
echo 'Chang ${inittabFile} to "Full multiuser mode", id=3 .'
