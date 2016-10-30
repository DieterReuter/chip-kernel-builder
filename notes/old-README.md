
https://bbs.nextthing.co/t/has-anyone-docker-ized-chip-yet/5744

http://www.chip-community.org/index.php/HOW-TO_compile_Chip%27s_Linux_kernel_and_modules_on_Chip_itself

http://www.raspibo.org/wiki/index.php/Compile_the_Linux_kernel_for_Chip:_my_personal_HOWTO

https://bbs.nextthing.co/t/could-nat-be-added-to-kernel-networking-config/8732

wget https://gist.github.com/tdack/5b87a20225d239a6240e8f3964b8d290/raw/10660620e198374da831ecccec66b549a8eef9bd/build_kernel.sh

```
docker build -t chip .

docker run -ti chip bash
time ./build_kernel.sh
real	7m50.569s
user	0m0.188s
sys	0m0.291s

docker cp abf3ab514845:/workdir/CHIP-linux/.config config-new
docker cp abf3ab514845:/workdir/4.4.11-hypriotos.tar.bz2 .
```



```
=> printenv bootcmd
bootcmd=gpio set PB2; if test -n ${fel_booted} && test -n ${scriptaddr}; then echo (FEL boot); source ${scriptaddr}; fi; mtdparts; ubi part UBI; ubifsmount ubi0:rootfs; ubifsload $fdt_addr_r /boot/sun5i-r8-chip.dtb; ubifsload $kernel_addr_r /boot/zImage; setenv bootargs $bootargs $kernelarg_video; bootz $kernel_addr_r - $fdt_addr_r
```

```
setenv bootcmd 'bootcmd=gpio set PB2; if test -n ${fel_booted} && test -n ${scriptaddr}; then echo (FEL boot); source ${scriptaddr}; fi; mtdparts; ubi part UBI; ubifsmount ubi0:rootfs; ubifsload $fdt_addr_r /boot/dtbs/4.4.11+/sun5i-r8-chip.dtb; ubifsload $kernel_addr_r /boot/zImage; setenv bootargs $bootargs $kernelarg_video; bootz $kernel_addr_r - $fdt_addr_r'
```

## Minimum kernel files to boot
```
root@chip:~# ls -al /boot/
total 13740
drwxr-xr-x  2 root root     536 Jan  1 00:05 .
drwxr-xr-x 20 root root    1312 Mar 29  2016 ..
-rw-r--r--  1 root root  158830 May 28  2016 config-4.4.11-ntc
-rw-r--r--  1 root root   39076 Jun  1  2016 sun5i-r8-chip.dtb
-rw-r--r--  1 root root   39076 Jun  1  2016 sun5i-r8-chip.dtb.bak
-rwxr-xr-x  1 root root 6912856 Jun  1  2016 zImage
-rwxr-xr-x  1 root root 6912856 Jun  1  2016 zImage.bak

root@chip:~# ls -al /lib/modules/
total 0
drwxr-xr-x  3 root root  232 Jun  1  2016 .
drwxr-xr-x 15 root root 1984 Jun  1  2016 ..
drwxr-xr-x  4 root root 1104 Jun  1  2016 4.4.11-ntc
```


## Create your own defconfig file
see: http://stackoverflow.com/questions/27899104/creating-defconfig-file-from-config

```
make savedefconfig
scripts/kconfig/conf  --savedefconfig=defconfig Kconfig

ls -al defconfig
-rw-r--r-- 1 root root 12414 Aug 27 23:25 defconfig

cp defconfig arch/arm/configs/chip_defconfig

MAKE="make -j 4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-"
$MAKE chip_defconfig

```

## Demo Docker on C.H.I.P.
(see: https://asciinema.org/a/3s3n5qv1ke4k9t1vt3vzw48jp)
```
asciinema rec -t "Docker 1.12.1 running on $9 C.H.I.P. computer" -w 1 docker-on-chip.asciinema

MAC:
ssh root@chip.local

cat /etc/os-release

uname -a
Linux chip 4.4.11-hypriotos #1 SMP Mon Aug 29 19:18:49 UTC 2016 armv7l GNU/Linux

./check-config.sh | more

docker -v

docker version

docker swarm init

docker info | more

docker node ls

docker node inspect ad18isolc3ed00ljn43rgusep | more

exit

```