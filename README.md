Android 刷机脚本 - flashKit.sh  V2.0.0  2015-11-09

1. 环境配置
	1）将 SDK 的 platform-tools 目录加入到环境变量，因为脚本会用到该目录下的 adb 和 fastboot 两个工具
	2) 将 “bin”目录拷贝到任意位置，最好不要放到项目工程目录。如放在“/home/chongyanghu/Scripts”目录下
	3）刷机脚本会用到bin目录下的kit-common.sh，有两种方式配置该脚本（选其一即可）：
		a）将bin目录路径加入到环境变量
		b）用 gedit 打开 flashKit.sh 脚本，修改 “SCRIPT_BIN_DIR” 的值为bin目录的路径。如 SCRIPT_BIN_DIR="/home/chongyanghu/Scripts/bin/"
	4) 将 kit-common.sh 和 flashKit.sh 都改为“可执行”
	5) 将flashKit.sh 拷贝到工程根目录执行
	

2. 工具菜单：

	[1] 制作刷机包 				---> 在工程根目录创建文件夹，并将刷机文件拷贝到其中。若将flashKit.sh 脚本的"COMPRESS_ROM_PACKAGE"值改为true，会自动压缩刷机包
	[2] 刷机 
		[1] 一键刷机 	---> 将目前能够通过 fastboot 模式刷写的文件全部刷入手机(具体刷写哪些文件，见flashKit.sh "ONE_KEY_FLASH_ROM"数组)。
		[2] 写 system.img 
		[3] 写 boot.img 
		[4] 写 uboot 
		[5] 写 recovery.img 
		[B] 返回 				---> 返回到主菜单
		[Q] 退出					---> 退出脚本
	[3] 恢复出厂设置 				---> 回复出厂设置
	[4] 恢复命令行主题颜色 			---> 脚本中某些提示文本设置了颜色，若脚本异常退出，可能会使命令行显示的文字颜色不是默认的颜色，执行该菜单项可恢复
	[Q] 退出						---> 退出脚本
	

3. 刷机脚本 flashKit.sh 需要修改脚本的 "COMPILE_PROJECT" 值为当前工程名，即 out/target/product/ 的子目录名。
	
    如， COMPILE_PROJECT="msm8610"
    
	一般情况下，修改该值可以支持任何工程的刷写。但是 不同平台(MTK、高通等)、编译的不同工程，可能需要刷写的文件会有不同，要刷写的分区也可能不同（如MTK平台，4.x的system.img写到android分区，而其他的却要写到system分区）。
	(分区名与镜像文件的对应关系，见flashKit.sh ---> "ONE_KEY_FLASH_ROM"数组)
	
	
	无论那个工程，必须将 bootloader 锁关闭之后，才能使用该脚本刷机，因为只有关闭 bootloader 锁之后，才能使用 fastboot。
    如果使用 fastboot 刷机时，提示权限问题，则 bootloader 被锁。

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
