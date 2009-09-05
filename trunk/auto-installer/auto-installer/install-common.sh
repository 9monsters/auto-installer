#!/bin/bash
# filename : install-common.sh
# 通用安装脚本

cd $(dirname $0)
# ./environment-set.sh
. ./logs/env.log
install_usage="
Usage: $0 [OPTIONS] [=VALUE]...

	-h, --help			打印帮助信息并退出
	--nickname=<YourName>		指定安装包名称
	--packagelist			打印当前支持的安装包列表
	--with-setupfile=<FilePath>	指定安装文件的路径（包含文件名）
	--cmd-before-conf=<YourCommand>	指定在配置应用程序前需要执行的命令［集合］
	--cmd-before-make=<YourCommand>	指定在编译应用程序前需要执行的命令［集合］
	--cmd-after-make=<YourCommand>	指定在编译应用程序后需要执行的命令［集合］
	--cmd-after-i=<YourCommand>	指定在安装应用程序后需要执行的命令［集合］
"
hasErr=0
ac_option=""
ac_optarg=""
unkonw_option=""
fileType=""
# 打印当前支持的安装包
PackageList(){
	echo "当前已有软件包："
	cat ${setupIni}	| awk -F, 'BEGIN{
		i=0;j=1;
	}{
		if ( $1 == "nickname") i=NR;
		if (NR > i && i != 0) printf("%s\t",$1);
		if (j++%5 == 0) printf("\n"); 
	}END{
		printf("\n");
	}'
}
# 处理程序参数
while test $# != 0
do
	case $1 in
		--*=*)
		ac_option=`echo $1 | awk -F= '{print $1}'`
		ac_optarg=`echo $1 | awk -F= '{print $2}'`
		;;
		*)
		ac_option=$1
		;;
	esac

	case $ac_option in
	--help | -h )
		echo "$install_usage"
		exit 0
		;;
	--packagelist | -p )
		PackageList
		exit 0
		;;
	--nickname | -name )
		export nickname="${ac_optarg}"
		;;
	--with-setupfile )
		setupFile=${ac_optarg}
		;;
	--without-config )
		cbc_cmd="${ac_optarg}"
		noConf="true"
		;;
	--cmd-before-conf | --cbc )
		cbc_cmd="${ac_optarg}"
		cbc="true"
		;;
	--cmd-before-make | --cbm )
		cbm_cmd="${ac_optarg}"
		cbm="true"
		;;
	--cmd-after-make | --cam )
		cam_cmd="${ac_optarg}"
		cam="true"
		;;
	--cmd-after-install | cai )
		cai_cmd="${ac_optarg}"
		cai="true"
		;;
	*)
		unkonw_option="$unkonw_option $1" ;((hasErr++));;
	esac
	shift
done
# 检查安装包名称和安装包路径
if [ -z "${nickname}" ];then
	echo "软件包名称为空，请检查变量'nickname'或使用--nickname=somevalue传入需要安装的软件包名称！"
	((hasErr++));exit ${hasErr}
elif [ -z "${setupFile}" ];then
	setupFile=`grep ${setupIni} ${nickname} | awk F, '{print $2}'`
elif [ -f "${setupFile}" ];then
	echo "指定的安装文件${setupFile}不存在，请查证！"
	((hasErr++));exit ${hasErr}
else
	echo -n `${colorFile} "nickname:${nickname}\nsetupfile:${setupFile}\n"
fi
# 检查是否有无法识别的参数
if [ -n "${unkonw_option}" ];then
	 echo  "未知选项：${unkonw_option}${install_usage}"
	((hasErr++))
	exit ${hasErr}
fi
# 根据文件类型确定解压方式
if [[ -n "$(grep tar.gz ${setupFile})" ]] || [[ -n "$(grep tar.gz ${setupFile})" ]];then
	verName=`tar -ztf ${setupFile} | head -1`
	fileType="tar.gz"
elif [[ -n "$(grep tar.bz2 ${setupFile})" ]];then
	verName=`tar -jtf ${setupFile} | head -1`
	fileType="tar.bz2"
elif [[ -n "$(grep zip ${setupFile})" ]];then
	verName=`unzip -l ${setupFile} | awk '{if(NR==4)print $4}'`
	fileType="zip"
else

fi
linkDir="${linkTarget}/${nickname}"
setupDir="${extractDir}/${verName}"
programDir="${installDir}/${verName}"
# 创建安装目录
mkdir -p "${programDir}"
if [ -k "${linkDir}" ];then
        rm -f "${linkDir}"
elif [ -d "${linkDir}" ];then
        mv "${linkDir}" "${linkDir}_${nowTime}"
fi
ln -s "${programDir}" "${linkDir}"
# 解压
case "${fileType}" in
	tar.gz )
	tar -zxvf "${setupFile}" -C "${extractDir}";;
	tar.bz2)
	tar -jxvf "${setupFile}" -C "${extractDir}";;
	zip )
	unzip "${setupFile}" -d "${extractDir}";;
esac
# 不需要编译时执行指定命令并退出
if [ "${noConf}" = "true" ];then 
	eval "${cbc_cmd}"
	exit 0;
fi
# 清理编译环境
cd "${setupDir}"
make clean
make distclean
# 预编译
./configure --prefix="${linkDir}" --with-extra-charsets=all --with-charset=utf8
# 检测预编译结果
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/configure"`${colorFile} " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi
# 编译
make
# 检测编译结果
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi
# 安装
make install
# 检测安装结果
ec="${?}"
if [ "${ec}" -ne 0 ];then
	echo `pwd`"/make install"`"${colorFile}" " 失败！ErrorCode:${ec}" Red 0 0`
	rm -f "${linkDir}";exit 1
fi	
# 修改默认配置
cp -f ./support-files/my-medium.cnf "${myCnf}"
cd "${programDir}"
# 安装数据库文件
./bin/mysql_install_db --user=mysql
# 授权
chown -R root  .
chown -R mysql var
chgrp -R mysql .
# 启动mysql
"${linkDir}/bin/mysqld_safe --user=mysql &"
chmod 777 "${linkDir}/var"
# 注册到系统服务
cp "${linkDir}/share/mysql/mysql.server" "/etc/rc.d/init.d/mysql" 
chmod +x "/etc/rc.d/init.d/mysql"
chkconfig --add mysql
# 设置访问的用户名和密码
"${linkDir}/bin/mysql" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'10.20.%' IDENTIFIED BY '3335688' WITH GRANT OPTION;"
"${linkDir}/bin/mysql" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.%' IDENTIFIED BY '3335688' WITH GRANT OPTION;"
# 首次启动后ID文件不知什么原因不见了，强制关闭重启一下就正常了
${linkDir}/bin/mysqladmin shutdown
if [ -f "${myCnf}" ];then
	mv "${myCnf}" "${myCnf}".${nowTime}
	echo `${colorFile} "备份${myCnf}为${myCnf}.${nowTime} 。" Green 0 0`
fi

echo `${colorFile} "安装成功！目标目录：${linkDir}" Green 0 0`
echo `${colorFile} "查询启动方式：service mysql，启动mysql：" Green 0 0`
# 启动MYSQL服务
service mysql start





