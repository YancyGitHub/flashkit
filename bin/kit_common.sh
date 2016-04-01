#! /bin/bash

# ******************************************
# Author: Chongyang.Hu
# Create: 2015-01-28
# History: 
#		Owner	Date	Description
# 	
# ******************************************


# ******************************************
#  		Source Area	
# ******************************************


# ******************************************
#  		Constans Area	
# ******************************************
DEFAULT_STYLE="\033[0m"

FG_COLOR_GRAY="\033[30m"
FG_COLOR_RED="\033[31m"
FG_COLOR_GREEN="\033[32m"
FG_COLOR_YELLOW="\033[33m"
FG_COLOR_BLUE="\033[34m"
FG_COLOR_PURPLE="\033[35m"
FG_COLOR_LIGHT_BLUE="\033[36m"
FG_COLOR_WHITE="\033[37m"

BG_COLOR_GRAY="\033[40m"
BG_COLOR_RED="\033[41m"
BG_COLOR_GREEN="\033[42m"
BG_COLOR_YELLOW="\033[43m"
BG_COLOR_BLUE="\033[44m"
BG_COLOR_PURPLE="\033[45m"
BG_COLOR_LIGHT_BLUE="\033[46m"
BG_COLOR_WHITE="\033[47m"

TEXT_BOLD="\033[1m"

# ******************************************
#  		Common function Area	
# ******************************************

color_demo()
{
	echo -e "${FG_COLOR_GRAY}"
	printf "FG_COLOR_GRAY"
	echo -e "${FG_COLOR_RED}"
	printf "FG_COLOR_RED"
	echo -e "${FG_COLOR_GREEN}"
	printf "FG_COLOR_GREEN"
	echo -e "${FG_COLOR_YELLOW}"
	printf "FG_COLOR_YELLOW"
	echo -e "${FG_COLOR_BLUE}"
	printf "FG_COLOR_BLUE"
	echo -e "${FG_COLOR_PURPLE}"
	printf "FG_COLOR_PURPLE"
	echo -e "${FG_COLOR_LIGHT_BLUE}"
	printf "FG_COLOR_LIGHT_BLUE"
	echo -e "${FG_COLOR_WHITE}"
	printf "FG_COLOR_WHITE"
	echo -e "${DEFAULT_STYLE}"
	
	echo -e "${BG_COLOR_GRAY}"
	printf "BG_COLOR_GRAY"
	echo -e "${BG_COLOR_RED}"
	printf "BG_COLOR_RED"
	echo -e "${BG_COLOR_GREEN}"
	printf "BG_COLOR_GREEN"
	echo -e "${BG_COLOR_YELLOW}"
	printf "BG_COLOR_YELLOW"
	echo -e "${BG_COLOR_BLUE}"
	printf "BG_COLOR_BLUE"
	echo -e "${BG_COLOR_PURPLE}"
	printf "BG_COLOR_PURPLE"
	echo -e "${BG_COLOR_LIGHT_BLUE}"
	printf "BG_COLOR_LIGHT_BLUE"
	echo -e "${BG_COLOR_WHITE}"
	printf "BG_COLOR_WHITE"
	echo -e "${DEFAULT_STYLE}"
	
	setStyle "${TEXT_BOLD} ${FG_COLOR_YELLOW} ${BG_COLOR_BLUE}"
	printf "TEXT_BOLD FG_COLOR_YELLOW BG_COLOR_BLUE"
	echo -e "${DEFAULT_STYLE}"
	
	printf "\n\n"
}

# --------------------------
# $1 : 风格常量。为空时，恢复到默认设置
#  	多种风格一起使用时，用引号全部包裹，且个常量间以空格分开，如下
# 		setStyle "${TEXT_BOLD} ${FG_COLOR_YELLOW} ${BG_COLOR_BLUE}"
# --------------------------
setStyle()
{
	if [ "$1" ] ; then
		echo -e $1
	else
		echo -e "${DEFAULT_STYLE}"
	fi
}

# --------------------------
# 只有一个参数： 参数即为显示的文本
# 两个参数： $1 为文本风格； $2 为显示的文本
# 三个参数： $1 $2 为文本风格； $3 为显示的文本
# 四个参数： $1 $2 $3 为文本风格； $4 为显示的文本
# --------------------------
msgPrint()
{
    if [ $# == 1 ]; then
        echo -n $1
    elif [ $# == 2 ]; then
        echo -n -e "$1 $2"
    elif [ $# == 3 ]; then
        echo -n -e "$1 $2" $3
    elif [ $# == 4 ]; then
        echo -n -e "$1 $2 $3" $4
    fi

    echo -e -n "${DEFAULT_STYLE}"
}

msgPrintln()
{
    if [ $# == 1 ]; then
        echo $1
    elif [ $# == 2 ]; then
        echo -e "$1 $2"
    elif [ $# == 3 ]; then
        echo -e "$1 $2" $3
    elif [ $# == 4 ]; then
        echo -e "$1 $2 $3" $4
    fi

    echo -e -n "${DEFAULT_STYLE}"
}

# --------------------------
# $1 : 显示的提示信息
# $2 : 默认值(直接回车传递的参数)： Y/y N/n 空
# return : Y/y 返回0；N/n 返回1
# --------------------------
kit_yes_no_prompt()
{
	printf "\n$1 "
	read userInput
	
	case "${userInput}" in
	Y|y)
		return 0
		;;
	N|n)
		return 1
		;;
	*)
		if [ -n "${userInput}" ] ; then
			kit_yes_no_prompt "$1" "$2"
		else
			case "$2" in
			Y|y)
				return 0
				;;
			N|n)
				return 1
				;;
			*)
				kit_yes_no_prompt "$1" "$2"
				;;
			esac
		fi
		;;
	esac
}


# --------------------------
# 检查手机链接状态。
# return：
# 	0： 有一台手机链接
# 	1： 没有手机链接，或链接的手机超过1台 
# --------------------------
kit_check_phone_state()
{
	# adb devices 命令在未链接手机时会输出两行数据，最后一行为空行
	# 该函数通过判断 adb devices 命令输出的数据行数，判断链接了几台手机
	
	setStyle "${FG_COLOR_YELLOW}"
	printf ">>> 检查手机连接状态...\n"
	setStyle
	
	local temp="NULL"
	local let count=0
	
	adb devices > .adb_devices.temp
	
	while [ "$temp" ]
	do
		read temp
		let count+=1
	done < .adb_devices.temp

	rm .adb_devices.temp
	
	if [ $count -eq 3 ] ; then	# 有一台手机成功连接
		setStyle "${FG_COLOR_GREEN}"
		printf ">>>SUCCESS!一台手机成功连接...\n"
		setStyle
		return 0
	elif [ $count -lt 3 ] ; then
		setStyle "${FG_COLOR_RED}"
		echo FAIL!!! 未找到手机 。。。
		setStyle
		return 1
	else 
		setStyle "${FG_COLOR_RED}"
		echo FAIL!!! 只能连接一台手机 。。。
		setStyle
		return 1
	fi
}

# 判断当前是否处于 fastboot 模式
kit_is_fastboot_mode()
{
    local temp;
    temp = `fastboot devices`

    if [ "$temp" ]; then
        return 0
    else
        return 1
    fi
}

# --------------------------
# 检查手机链接状态。该函数会检查手机的链接状态
# return：
# 	0： 成功启动 fastboot 模式
# 	1： 启动 fastboot 模式失败
# --------------------------
kit_open_fastboot_mode()
{
    if kit_is_fastboot_mode ; then
        msgPrintln ${FG_COLOR_YELLOW} "已经处于 Fastboot 模式"
        return 0
    fi

	if kit_check_phone_state ; then
		
		setStyle "${FG_COLOR_YELLOW}"
		printf ">>> 启动手机到 FASTBOOT 模式..."
		setStyle
		
		adb root
		adb remount
		adb reboot bootloader
		
		return 0
	else
		return 1
	fi
}

# --------------------------
# $1 : 分区名
# $2 : 镜像目录路径
# $3 : 文件名
# --------------------------
kit_flash()
{
	setStyle "${FG_COLOR_LIGHT_BLUE}"
	printf ">>> 写 $3 到 $1 分区...\n"
	setStyle
	
	fastboot flash "$1" "$2/$3"
}

kit_factory_reset()
{
	setStyle "${FG_COLOR_LIGHT_RED}"
	printf ">>> 正在恢复出厂设置...\n"
	setStyle
	
	fastboot format userdata
	fastboot format cache
}

# --------------------------
# $1 : 要格式化的分区名
# --------------------------
kit_formate()
{
	setStyle "${FG_COLOR_YELLOW}"
	printf ">>> 格式化 $1 分区...\n"
	setStyle
	
	fastboot format $1
}

kit_fastboot_to_android()
{
	setStyle "${FG_COLOR_YELLOW}"
	printf ">>> 重新启动到android系统...\n"
	setStyle
	
	fastboot reboot
}













































