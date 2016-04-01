#! /bin/bash

# ******************************************
# Author: Chongyang.Hu
# Create: 2015-01-28
# History: 
#		Owner	Date	Description
# 	    Chongyang.Hu    2015-11-09  Remove flex
#       Chongyang.Hu    2015-11-19  Add Qualcomm flash file
# ******************************************
SCRIPT_VERSION="2.0.1"

# ******************************************
#  		Constans Area	
# ******************************************
SCRIPT_BIN_DIR="./bin"
COMPILE_PROJECT="aosp_arm"

COMPRESS_ROM_PACKAGE=false
SIGN_ROM_SUPPORT=false



PRODUCT_DIR="out/target/product/${COMPILE_PROJECT}"

# ******************************************
#  		Source Area	
# ******************************************
if [ "${SCRIPT_BIN_DIR}" ] ; then
	PATH=${SCRIPT_BIN_DIR}:${PATH}
fi

source kit_common.sh

# ******************************************
#  		Common function Area	
# ******************************************


runScript()
{
    #color_demo

	scriptInfo
	show_main_menu
}

scriptInfo()
{
	printf "\n*********** Script Information ***********"
	printf "
  Script Version: ${SCRIPT_VERSION}
  Company: SimCom
  Department: Application System Department
  Author: Chongyang.Hu
\n"
	echo -e "  ** 刷机脚本 FOR ${TEXT_BOLD}${FG_COLOR_RED}${COMPILE_PROJECT}${DEFAULT_STYLE}"
	printf "******************************************"
	
	msgPrintln ${TEXT_BOLD} ${FG_COLOR_BLUE} "需要解除手机的 bootloader 锁才能使用该脚本刷机"
}

# ------------------------------------------
# $1 : menu id
# ------------------------------------------
send_menu_selected_event()
{
	onMenuSelected $1
}

ONE_KEY_FLASH_ROM=(
# 分区名 镜像文件
"modem NON-HLOS.bin"
"sbl1 sbl1.mbn"
"sdi sdi.mbn"
"aboot emmc_appsboot.mbn"
"rpm rpm.mbn"
"boot boot.img"
"tz tz.mbn"
"system system.img"
"persist persist.img"
"cache cache.img"
"recovery recovery.img"
"splash splash.img"
"usbmsc usbdisk.img"
"scanner scanner.img"
"userdata userdata.img"
"PrimaryGPT gpt_main0.bin"
"BackupGPT gpt_backup0.bin"
)

BOOT_RECORD_ROM=(
"mbr MBR"
"ebr1 EBR1"
"ebr2 EBR2"
)

PARTITION_USERDATA="userdata"
PARTITION_CACHE="cache"
PARTITION_SYSTEM="system"

MAIN_MENU_ITEM=(
"制作刷机包@ID_make_rom"
"刷机@ID_flash_rom"
"恢复出厂设置@ID_factory_reset"
"重启到 android 系统@ID_reboot_android"
"重启到 Fastboot 模式@ID_reboot_fastboot"
#"恢复命令行主题颜色@ID_ter_def-color"
"退出@ID_quit"
)

FLASH_ROM_SUB_MENU_ITEM=(
"一键刷机@ID_sub_oneKey_flash"
#"重写引导分区@ID_sub_flash_boot_recoder"
"写 system.img@ID_sub_system_img"
"写 boot.img@ID_sub_boot_img"
#"写 uboot@ID_sub_flash_uboot"
"写 recovery.img@ID_sub_recovery_img"
"返回@ID_sub_back"
"退出@ID_quit"
)

OPTION_MENU_ITEM=(
"重启到android系统@ID_reboot_android"
"重启到 Fastboot 模式@ID_reboot_fastboot"
"返回到主菜单@ID_go_main_menu"
"返回到刷机菜单@ID_go_flash_menu"
"退出@ID_quit"
)

declare -a MenuStringArray
declare -a MenuIdArray
# ------------------------------------------
# 解析菜单数组，将菜单的字串和ID一次存入
# 		MenuStringArray 和 MenuIdArray
# $1 : 菜单数组。以 "${数组变量名[@]}" 形式传入
# ------------------------------------------
parser_menu_item()
{
	unset MenuStringArray
	unset MenuIdArray
	
	local let index=0
	local let number=1
	while [ "$*" != "" ]
	do
		MenuIdArray[$index]=`echo "$1" | cut -d@ -f2`
		if [ ${MenuIdArray[$index]} = "ID_quit" ] ; then
			MenuStringArray[$index]=`echo "[Q] $1" | cut -d@ -f1`
		elif [ ${MenuIdArray[$index]} = "ID_sub_back" ] ; then
			MenuStringArray[$index]=`echo "[B] $1" | cut -d@ -f1`
		else
			MenuStringArray[$index]=`echo "[$number] $1" | cut -d@ -f1`
			let number+=1
		fi
		
		let index+=1
		shift
	done
}

show_main_menu()
{
	if [ "$1" != "err" ] ; then
		printf "\n\n"
		parser_menu_item "${MAIN_MENU_ITEM[@]}"
		for str in "${MenuStringArray[@]}"
		do
			printf "\t$str \n"
		done
		
		printf "\n"
	fi
	
	printf "选择序号: "
	read userInput
	case "$userInput" in
	[0-9]*)
		let userInput-=1
		if [ ${MenuIdArray[$userInput]} ] ; then
			send_menu_selected_event "${MenuIdArray[$userInput]}"
		else
			show_main_menu "err"
		fi
		;;
	Q|q)
		send_menu_selected_event "ID_quit"
		;;
	*)
		show_main_menu "err"
		;;
	esac
}

show_flash_sub_menu()
{
	if [ "$1" != "err" ] ; then
		printf "\n\n"
		parser_menu_item "${FLASH_ROM_SUB_MENU_ITEM[@]}"
		for str in "${MenuStringArray[@]}"
		do
			printf "\t$str \n"
		done
		
		printf "\n"
	fi
	
	printf "选择序号: "
	read userInput
	case "$userInput" in
	[0-9]*)
		let userInput-=1
		if [ ${MenuIdArray[$userInput]} ] ; then
			send_menu_selected_event "${MenuIdArray[$userInput]}"
		else
			show_flash_sub_menu "err"
		fi
		;;
	B|b)
		clear
		show_main_menu
		;;
	Q|q)
		send_menu_selected_event "ID_quit"
		;;
	*)
		show_flash_sub_menu "err"
		;;
	esac
}

show_option_menu()
{
	if [ "$1" != "err" ] ; then
		printf "\n\n"
		parser_menu_item "${OPTION_MENU_ITEM[@]}"
		for str in "${MenuStringArray[@]}"
		do
			printf "\t$str \n"
		done
		
		printf "\n"
	fi
	
	printf "选择序号: "
	read userInput
	case "$userInput" in
	[0-9]*)
		let userInput-=1
		if [ ${MenuIdArray[$userInput]} ] ; then
			send_menu_selected_event "${MenuIdArray[$userInput]}"
		else
			show_option_menu "err"
		fi
		;;
	Q|q)
		send_menu_selected_event "ID_quit"
		;;
	*)
		show_option_menu "err"
		;;
	esac
}


onMenuSelected()
{
	case "$1" in
	ID_make_rom)
		handle_make_rom
		;;
	ID_flash_rom)
		handle_flash_rom
		;;
	ID_factory_reset)
		handle_factory_reset
		;;
	ID_sub_oneKey_flash)
		handle_one_key_flash
		;;
	ID_sub_flash_boot_recoder)
		handle_flash_boot_rec
		;;
	ID_sub_system_img)
		handle_flash_system_img
		;;
	ID_sub_boot_img)
		handle_flash_boot_img
		;;
	ID_sub_flash_uboot)
		handle_flash_uboot
		;;
	ID_sub_recovery_img)
		handle_flash_recovery
		;;
	ID_sub_back)
		handle_flash_sub_back
		;;
	ID_ter_def-color)
		handle_set_terminate_color
		;;
	ID_reboot_android)
		handle_reboot_android
		;;
	ID_reboot_fastboot)
		handle_reboot_fastboot
		;;
	ID_go_main_menu)
		handle_goto_main_menu
		;;
	ID_go_flash_menu)
		handle_goto_flash_menu
		;;
	ID_quit)
		handle_quit
		;;
	esac
}

make_not_sign_rom()
{
	local imageBinDir
	
	msgPrintln "${FG_COLOR_GREEN}" ">>> 删除旧的刷机包..."

	find . -maxdepth 1 -regextype "sed" -regex ".*${COMPILE_PROJECT}_ImageBin_[0-9]\{8\}" -exec rm -rf {} \;
	find . -maxdepth 1 -regextype "sed" -regex ".*${COMPILE_PROJECT}_ImageBin_[0-9]\{8\}.zip" -exec rm -rf {} \;

	msgPrintln ${FG_COLOR_GREEN} ">>> 创建ImageBin目录..."

	imageBinDir=${COMPILE_PROJECT}_ImageBin_`date +%Y%m%d`
	mkdir ${imageBinDir}

	msgPrintln ${FG_COLOR_GREEN} ">>> 开始拷贝镜像文件..."

	find "${PRODUCT_DIR}" -maxdepth 1 -type f -exec cp -v {} ./${imageBinDir} \;

	if ${COMPRESS_ROM_PACKAGE} ; then
		msgPrintln ${FG_COLOR_GREEN} ">>> 开始制作压缩包..."

		zip -r ${imageBinDir}.zip  ${imageBinDir}
	fi
	
	if ${COMPRESS_ROM_PACKAGE} ; then
	    msgPrintln ${TEXT_BOLD} ${FG_COLOR_YELLOW} ">>> 完成..."
	    msgPrint ${TEXT_BOLD} ${FG_COLOR_YELLOW} ">>>  刷机包目录: "
		msgPrintln ${FG_COLOR_RED} "${imageBinDir}"
		msgPrint ${TEXT_BOLD} ${FG_COLOR_YELLOW} ">>> 压缩包: "
		msgPrintln ${FG_COLOR_RED} "${imageBinDir}.zip${FG_COLOR_YELLOW}"
	else
		msgPrintln ${TEXT_BOLD} ${FG_COLOR_YELLOW} ">>> 完成..."
		msgPrintln ${TEXT_BOLD} ${FG_COLOR_YELLOW} ">>> 刷机包目录: ${FG_COLOR_RED}${imageBinDir}${FG_COLOR_YELLOW}"
	fi

}

make_sign_rom()
{
	echo "*** 暂未支持 ***"
}

handle_make_rom()
{
	if ${SIGN_ROM_SUPPORT} ; then
		make_sign_rom
	else
		make_not_sign_rom
	fi
}

handle_flash_rom()
{
	show_flash_sub_menu
}

handle_factory_reset()
{
	local defVal="Y"
	local msg="该操作会清除所有用户数据，是否继续？(Y/N): [${defVal}] "
	
	setStyle "${FG_COLOR_RED}"
	if kit_yes_no_prompt "${msg}" "${defVal}" ; then
	setStyle
		if kit_open_fastboot_mode ; then
			kit_factory_reset
			kit_fastboot_to_android
		fi
	fi
	setStyle
}

# --------------------------------------------
# $1 是否格式化用户数据
# --------------------------------------------
oneKeyFlash()
{
	local isFormatUserdata=$1
	
	local currPartition
	local currImg
	for romFile in "${ONE_KEY_FLASH_ROM[@]}"
	do
		currPartition=`echo ${romFile} | sed "s:\(.*\) \(.*\):\1:g"`
		currImg=`echo ${romFile} | sed "s:\(.*\) \(.*\):\2:g"`
		
		if [ "${currPartition}" = "${PARTITION_USERDATA}" ] || [ "${currPartition}" = "${PARTITION_CACHE}" ] ; then
			if "${isFormatUserdata}" ; then
				kit_flash "${currPartition}" "${PRODUCT_DIR}" "${currImg}"
			fi
		else
			kit_flash "${currPartition}" "${PRODUCT_DIR}" "${currImg}"
		fi
	done
	
}

handle_one_key_flash()
{
	msgPrintln ${TEXT_BLOB} ${FG_COLOR_BLUE} " ****** 一键刷机 ****** "
	
	local defVal="Y"
	local msg="是否需要恢复出厂设置？(Y/N): [${defVal}] "
	local isFormatUserdata=false
	
	setStyle "${FG_COLOR_RED}"
	if kit_yes_no_prompt "${msg}" "${defVal}" ; then
		isFormatUserdata=true
	fi
	setStyle
	
	if kit_open_fastboot_mode ; then
		oneKeyFlash "${isFormatUserdata}"
		kit_fastboot_to_android
	fi
}

handle_flash_boot_rec()
{
	msgPrintln ${TEXT_BLOB} ${FG_COLOR_BLUE} " ****** 写引导记录 ****** "
	
	if kit_open_fastboot_mode ; then
		
		for br in "${BOOT_RECORD_ROM[@]}"
		do
			currPartition=`echo ${br} | sed "s:\(.*\) \(.*\):\1:g"`
			currImg=`echo ${br} | sed "s:\(.*\) \(.*\):\2:g"`
			
			kit_flash "${currPartition}" "${PRODUCT_DIR}" "${currImg}"
		done
		
		kit_fastboot_to_android
	fi
}

handle_flash_system_img()
{
	msgPrintln ${TEXT_BLOB} ${FG_COLOR_BLUE} " ****** 写 system.img ******"
	
	if kit_open_fastboot_mode ; then
		kit_flash "${PARTITION_SYSTEM}" "${PRODUCT_DIR}" "system.img"
		kit_fastboot_to_android
	fi
}

handle_flash_boot_img()
{
	msgPrintln ${TEXT_BLOB} ${FG_COLOR_BLUE} " ****** 写 boot.img ******"
	
	if kit_open_fastboot_mode ; then
		kit_flash "boot" "${PRODUCT_DIR}" "boot.img"
		kit_fastboot_to_android
	fi
}

handle_flash_uboot()
{
	msgPrintln ${TEXT_BLOB} ${FG_COLOR_BLUE} " ****** 写 uboot ****** "
	
	if kit_open_fastboot_mode ; then
		kit_flash "uboot" "${PRODUCT_DIR}" "lk.bin"
		kit_fastboot_to_android
	fi
}

handle_flash_recovery()
{
	msgPrintln ${TEXT_BLOB} ${FG_COLOR_BLUE} " ****** 写 recovery.img ****** "
	
	if kit_open_fastboot_mode ; then
		kit_flash "recovery" "${PRODUCT_DIR}" "recovery.img"
		kit_fastboot_to_android
	fi
}

handle_flash_sub_back()
{
	clear
	show_main_menu
}

handle_quit()
{
	setStyle
	exit 0
}

handle_set_terminate_color()
{
	setStyle
	printf "已经恢复终端到默认颜色风格\n"
}

handle_reboot_android()
{
	kit_fastboot_to_android
}

handle_reboot_fastboot()
{
	kit_open_fastboot_mode
}

handle_goto_main_menu()
{
	clear
	show_main_menu
}

handle_goto_flash_menu()
{
	show_flash_sub_menu
}




# 执行脚本
runScript $1 $2



