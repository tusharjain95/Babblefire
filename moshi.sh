#!/bin/bash
 #
 # Copyright © 2014, Monish Kapadia "assasin.monish" <monishk10@yahoo.com>
 #
 # Custom Build script for ease.
 #
 # This software is licensed under the terms of the GNU General Public
 # License version 2, as published by the Free Software Foundation, and
 # may be copied, distributed, and modified under those terms.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # Please maintain this if you use this script or any part of it
 #

# Bash Color
blink_red='\033[05;31m'
red=$(tput setaf 1) 		  # red
green=$(tput setaf 2)             # green
cyan=$(tput setaf 6) 		  # cyan
txtbld=$(tput bold)               # Bold
bldred=${txtbld}$(tput setaf 1)   # red
bldgrn=${txtbld}$(tput setaf 2)   # green
bldblu=${txtbld}$(tput setaf 4)   # blue
bldcya=${txtbld}$(tput setaf 6)   # cyan
restore=$(tput sgr0)              # Reset
clear

# Resources
THREAD="-j12"
KERNEL="zImage"
DTBIMAGE="dtb"
DEFCONFIG="cancro_user_defconfig"
device="cancro"

# Kernel Details
BASE_MOSHI_VER="moshi"
VER="v3"
MOSHI_VER="$BASE_MOSHI_VER$VER"

# Vars
export CROSS_COMPILE="/home/monish/arm-eabi-5.2/bin/arm-eabi-"
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER="monish"
export KBUILD_BUILD_HOST="beast"
# Paths
#STRIP=/toolchain-path/arm-eabi-strip
STRIP=/home/monish/arm-eabi-5.2/bin/arm-eabi-strip
KERNEL_DIR=`pwd`
REPACK_DIR="$KERNEL_DIR/zip/kernel_zip"
PATCH_DIR="$KERNEL_DIR/zip/kernel_zip/patch"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm/boot"
# Functions

function make_dtb {
		$REPACK_DIR/tools/dtbToolCM -2 -o $REPACK_DIR/$DTBIMAGE -s 2048 -p scripts/dtc/ arch/arm/boot/

}
function clean_all {
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

function make_zip {
		cd $REPACK_DIR
		zip -r9 ~/builds/$MOSHI_F/MOSHI-$MOSHI_F-$(date +%d-%m_%H%M)-$VER.zip *
}

function copy_modules {
		echo "Copying modules"
		find . -name '*.ko' -exec cp {} $REPACK_DIR/modules/ \;
		echo "Stripping modules for size"
		$STRIP --strip-unneeded $REPACK_DIR/modules/*.ko
}

DATE_START=$(date +"%s")

echo -e "${bldred}"; echo -e "${blink_red}"; echo "$AK_VER"; echo -e "${restore}";

echo -e "${bldgrn}"
echo "-----------------"
echo "Making MOSHI Kernel:"
echo "-----------------"
echo -e "${restore}"

case "$1" in
clean|cleanbuild)
clean_all
make_kernel
make_dtb
if [ -e "arch/arm/boot/zImage" ]; then
make_zip
else
echo -e "Error Occurred"
echo -e "zImage not found"
fi
;;
dirty)
make_kernel
make_dtb
if [ -e "arch/arm/boot/zImage" ]; then
make_zip
else
echo -e "Error Occurred"
echo -e "zImage not found"
fi
;;
*)
echo -e "${bldblu}"
while read -p "Which branch (c)? " mchoice
echo -e "${bldred}"
do
case "$mchoice" in
	c|C )
		MOSHI_F="cancro"
		echo
		echo "Named cancro"
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done
echo -e "${bldgrn}"
while read -p "Do you want to clean stuff (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done
echo -e "${restore}"
echo
echo -e "${txtbld}"
while read -p "Do you want to build kernel (y/n)? " dchoice
echo -e "${restore}"
do
case "$dchoice" in
	y|Y)
		make_kernel
		make_dtb
		copy_modules
		if [ -e "arch/arm/boot/zImage" ]; then
		make_zip
		fi
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done
;;
esac
echo -e "${bldgrn}"
echo "MOSHI-$MOSHI_F-$(date +%d-%m_%H%M)-$VER.zip"
echo -e "${bldred}"
echo "################################################################################"
echo -e "${bldgrn}"
echo "------------------------Moshi Kernel Compiled in:-------------------------------"
echo -e "${bldred}"
echo "################################################################################"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo -e "${bldblu}"
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo -e "${restore}"
echo

