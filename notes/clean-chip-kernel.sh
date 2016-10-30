#!/bin/bash
set -e

# remove unused kernel files
rm -f /boot/System.map-4.4.11-ntc
rm -f /boot/initrd.img-4.4.11-ntc
rm -f /boot/vmlinuz-4.4.11-ntc

rm -fr /boot/dtb
rm -fr /boot/dtbs
rm -fr /boot/dtb-4.4.11-ntc

# install new kernel
scp 4.4.11+.tar.bz2 root@192.168.2.116:
tar xvf /root/4.4.11+.tar.bz2 -C /

# exchange kernel files
mv /boot/dtbs/4.4.11+/sun5i-r8-chip.dtb /boot/
mv /boot/vmlinuz-4.4.11+ /boot/zImage
depmod -a

# remove unused kernel files
rm -f /boot/System.map-4.4.11+
rm -fr /boot/dtbs

# reboot the C.H.I.P.
### reboot
