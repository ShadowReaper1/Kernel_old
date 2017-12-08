#!/bin/bash

### Taken From Ruthless Kernel
### HelpMeRuth (jukeboxruthger1@gmail.com)
### Made universal for everyone. Make sure you run with sudo or su

set -e

KERNEL_DIR=$PWD
TOOLCHAINDIR=~/tc
KERNEL_TOOLCHAIN=$TOOLCHAINDIR/bin/aarch64-linaro-linux-android-
ZFM_CONFIG=zc550kl-custom_defconfig
DTBTOOL=$KERNEL_DIR/tools/
BUILDS=../zip
BUILD_DIR=$KERNEL_DIR/zip
ANY_KERNEL2_DIR=$KERNEL_DIR/zip/base_files
STRIP=$TOOLCHAINDIR/bin/aarch64-linux-android-strip
MODULES=$ANY_KERNEL2_DIR/modules

# The MAIN Part
echo "**** Processing ****"
echo " "
export ARCH=arm64
export SUBARCH=arm64
export CROSS_COMPILE=$KERNEL_TOOLCHAIN
echo "**** Do you wanna clean the build(y/n)? ****"
read answer
if echo "$answer" | grep -iq "^y" ;then
    echo -e "${bldgrn} Cleaning the old build ${txtrst}"
make mrproper
rm -rf $KERNEL_DIR/arch/arm64/boot/dtb
rm -rf $KERNEL_DIR/arch/arm64/boot/Image
rm -rf $KERNEL_DIR/arch/arm64/boot/Image.gz
rm -rf $KERNEL_DIR/arch/arm64/boot/Image.gz-dtb
rm -rf $KERNEL_DIR/arch/arm64/boot/dts/*.dtb
fi
clear
echo "**** Re-generating Kernel config ****"
echo "**** Please enter the device name you wanna build for. ****"
make $ZFM_CONFIG
clear
echo -n "Do you wanna make changes in the defconfig (y/n)?"
read answer
if echo "$answer" | grep -iq "^y" ;then
    echo -e " Building Defconfig GUI ${txtrst}"
make menuconfig
fi

time make -j4

# Time for dtb
echo "**** Generating DTB ****"
$DTBTOOL/dtbToolCM -2 -o $KERNEL_DIR/arch/arm64/boot/dtb -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm64/boot/dts/

echo "**** Verify zImage,dtb ****"
ls $KERNEL_DIR/arch/arm64/boot/Image
ls $KERNEL_DIR/arch/arm64/boot/dtb
cd $KERNEL_DIR

#Anykernel 2 time!!
echo "**** Verifying Build Directory ****"
ls $ANY_KERNEL2_DIR
echo "**** Removing leftovers ****"
rm -rf $ANY_KERNEL2_DIR/dtb
rm -rf $ANY_KERNEL2_DIR/zImage
rm -rf $ANY_KERNEL2_DIR/*.zip
### just get rid of every zip, who wants a zip in a zip?

echo "**** Copying zImage ****"
cp $KERNEL_DIR/arch/arm64/boot/Image $ANY_KERNEL2_DIR/zImage
echo "**** Copying dtb ****"
cp $KERNEL_DIR/arch/arm64/boot/dtb $ANY_KERNEL2_DIR/

## Set build number
echo "**** Setting Build Number ****"
NUMBER=0
INCREMENT=$(expr $NUMBER + 1)
FINAL_KERNEL_ZIP=Reaper-Reborn-V$INCREMENT.0.zip

echo "**** Time to zip up! ****"
cd $ANY_KERNEL2_DIR/
zip -r9 $FINAL_KERNEL_ZIP * -x README $FINAL_KERNEL_ZIP
cd ..
cd ..
echo $FINAL_KERNEL_ZIP

echo "**** Good Bye!! ****"
cd $KERNEL_DIR
