#!/bin/bash
# 文件名：color-string.sh
# 参数一：消息内容
# 参数二：颜色
# 参数四：特殊处理
# 返回：拼接后的带色字符串
usage="Usage: 
	${0} {Message} {FrontColor} {BackColor} {Style}

	{Message}:Message you want display;
	{FrontColor}:FrontColor will display,values:
		0:Normal 1:\e[0;30mBlack\e[m 2:\e[0;31mRed\e[m 3:\e[0;32mGreen\e[m 4:\e[0;33mBrown\e[m 5:\e[0;34mBlue\e[m 6:\e[0;35mPurple\e[m 7:\e[0;36mCyan\e[m 8:\e[0;37mWhite\e[m
	{BackColor}:BackColor will display,values:
		0:Normal 1:\e[0;30mBlack\e[m 2:\e[0;31mRed\e[m 3:\e[0;32mGreen\e[m 4:\e[0;33mBrown\e[m 5:\e[0;34mBlue\e[m 6:\e[0;35mPurple\e[m 7:\e[0;36mCyan\e[m 8:\e[0;37mWhite\e[m
	{Style}:Style will display,values:
		0:Normal 1:\e[1mBold\e[m 2:\e[4mUnderline\e[m 3:\e[5mBlink\e[m 4:\e[7mInverse\e[m

	Example: ${0} \"hello\" Green Brown Blink
					 ${0} \"hello\" 3 4 3"
# 判断参数个数
if [ $# -eq 0 ]; then
	echo -e "${usage}"
	exit 0
fi	
# 处理第一个参数
case "${1}" in 
	-h | --help) 
	  echo -e "${usage}"
	  exit 0
	;; 
esac      
# 处理第二个参数
case ${2} in 
	1 | Black) 
	  fStr="30"
	;; 
	2 | Red) 
	  fStr="31"
	;; 
	3 | Green) 
	  fStr="32" 
	;; 
	4 | Brown) 
	  fStr="33"
	;; 
	5 | Blue) 
	  fStr="34"
	;; 
	6 | Purple) 
	  fStr="35"
	;; 
	7 | Cyan) 
	  fStr="36"
	;; 
	8 | White) 
	  fStr="37"
	;; 	
	*) 
	  fStr="0"
	;;         
esac
# 处理第三个参数
case ${3} in 
	1 | Black) 
	  bStr="40"
	;; 
	2 | Red) 
	  bStr="41"
	;; 
	3 | Green) 
	  bStr="42" 
	;; 
	4 | Brown) 
	  bStr="43"
	;; 
	5 | Blue) 
	  bStr="44"
	;; 
	6 | Purple) 
	  bStr="45"
	;; 
	7 | Cyan) 
	  bStr="46"
	;; 
	8 | White) 
	  bStr="47"
	;; 	
	*) 
	  bStr="0"
	;;         
esac
# 处理第四个参数
case ${4} in
 1 | Bold)
 	sStr="1"
 ;;
 2 | Underline)
 	sStr="4"
 ;;
 3 | Blink)
 	sStr="5"
 ;;
 4 | Inverse)
 	sStr="5"
 ;; 
 *)
 	sStr="0"
 ;;	 	
esac 
# 拼接字符串
if [ ${bStr} -eq 0 ] && [ ${sStr} -eq 0 ]; then
    rtnString="\e[${fStr}m"
elif [ ${bStr} -eq 0 ]; then
    rtnString="\e[${fStr};${sStr}m"
elif [ ${sStr} -eq 0 ]; then
    rtnString="\e[${fStr};${bStr}m"
else
    rtnString="\e[${fStr};${bStr};${sStr}m"
fi    
printf "${rtnString}${1}\e[m"
exit 0
