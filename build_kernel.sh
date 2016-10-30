#!/bin/bash
set -e
set -x

# Desktop build
MAKE="make -j 4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-"
# C.H.I.P. build
#MAKE="make"
CDIR=$PWD
LINUX=$CDIR/CHIP-linux
WIFI=$CDIR/RTL8723BS

# Clone NTC C.H.I.P. kernel source
if [[ -d $LINUX ]]; then
	cd $LINUX
	git checkout debian/4.4.11-ntc-1
else
	git clone --single-branch --branch debian/4.4.11-ntc-1 --depth 1 https://github.com/NextThingCo/CHIP-linux.git $LINUX
	cd $LINUX
fi

# Get HypriotOS C.H.I.P. kernel config
cp /workdir/config-4.4.11 .config

# Add kernel branding for HypriotOS
sed -i 's/^EXTRAVERSION =.*/EXTRAVERSION = -hypriotos/g' Makefile
export LOCALVERSION="" # suppress '+' sign in 4.4.11+

# Configure the kernel
$MAKE oldconfig
###$MAKE menuconfig

# Break the build if there is a change detected
echo "Diff on kernel .config (to check if something has changed)"
diff /workdir/config-4.4.11 .config

# Build the kernel and modules
$MAKE
$MAKE modules

# Install modules
KR=$($MAKE kernelrelease)
INSTALLDIR=$CDIR/$KR
if [[ -d $INSTALLDIR ]]; then
	rm -fr $INSTALLDIR
	mkdir -p $INSTALLDIR
fi

$MAKE INSTALL_MOD_PATH=$INSTALLDIR modules_install
rm $INSTALLDIR/lib/modules/$KR/{build,source}

# Clone NTC WiFi module
if [[ -d $WIFI ]]; then
	cd $WIFI
	git checkout debian
else
	git clone --single-branch --branch debian https://github.com/NextThingCo/RTL8723BS.git $WIFI
	cd $WIFI
	for f in debian/patches/0*; do echo "Applying ${f}"; patch -p 1 < $f; done
fi

# Build & install NTC WiFi module
$MAKE CONFIG_PLATFORM_ARM_SUNxI=y CONFIG_RTL8723BS=m M=$PWD -C $LINUX
$MAKE CONFIG_PLATFORM_ARM_SUNxI=y CONFIG_RTL8723BS=m M=$PWD -C $LINUX INSTALL_MOD_PATH=$INSTALLDIR modules_install

# Build kernel module dependencies
depmod -a -b $INSTALLDIR $KR

# Install kernel, System.map, config and dtb
mkdir -p $INSTALLDIR/boot
cp $LINUX/arch/arm/boot/zImage $INSTALLDIR/boot/vmlinuz-$KR
cp $LINUX/arch/arm/boot/zImage $INSTALLDIR/boot/zImage
cp $LINUX/System.map $INSTALLDIR/boot/System.map-$KR
cp $LINUX/.config $INSTALLDIR/boot/config-$KR
cp $LINUX/arch/arm/boot/dts/sun5i-r8-chip.dtb $INSTALLDIR/boot/sun5i-r8-chip.dtb-$KR
cp $LINUX/arch/arm/boot/dts/sun5i-r8-chip.dtb $INSTALLDIR/boot/

# Create tar file
tar -cjvf $CDIR/$KR.tar.bz2 -C $INSTALLDIR .