
# How to upgrade your $9 C.H.I.P. computer and install Docker 1.12.1

## Overview on the necessary steps

1. Flash the latest available firmware
2. Connect to the C.H.I.P. via USB or UART console cable
3. Configure WiFi connection
4. Configure SSH access to the C.H.I.P.
5. Upgrade the Linux kernel to the HypriotOS version
6. Check if the new kernel is Docker optimised
7. Install fix so you can run the official Docker install.sh
8. Install Docker from get.docker.com
9. optional: Install fix for Docker Engine 1.12.1 & Docker Machine 1.8.0
10. optional: Provision the Docker Engine from a Mac via Docker Machine
11. bonus track: Build a Docker SwarmMode Cluster with C.H.I.P.'s


## 1. Flash the latest available firmware

Use a Chrome browser and flash the latest firmware and OS on your C.H.I.P. computer. For detailled instructions go to the appropriate web site at http://flash.getchip.com/. To run Docker on the C.H.I.P. you should use the OS image for `Debian Headless 4.4`.


## 2. Connect to the C.H.I.P. via USB or UART console cable

Once the C.H.I.P. is successfully flashed you can connect it directly with USB cable to a Mac or Linux machine. The C.H.I.P. is getting power over the USB cable and connects via an USB serial console driver, so you can easily connect to.

Let's find the booted C.H.I.P. on the USB wire:
```
ls -al /dev/cu.usb*
```
```
sudo screen /dev/cu.usb14333
```

Alternatively you can attach a UART console cable (e.g. from AdaFruit) which is typically a device on the mac, like `ls -al /dev/cu.usbserial`.
```
sudo screen /dev/cu.usbserial 115200
```

Once you get to the login message, you can use username `root` and password `chip` to login:
```
Debian GNU/Linux 8 chip ttyS0

chip login: root
Password:
Linux chip 4.4.11-ntc #1 SMP Sat May 28 00:27:07 UTC 2016 armv7l

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
root@chip:~#
```


# 3. Configure WiFi connection

Following the instruction here http://docs.getchip.com/chip.html#wifi-connection you can list all the available WiFi networks and then connect the C.H.I.P. to your prefered network.
```
nmcli device wifi list
*  SSID         MODE   CHAN  RATE       SIGNAL  BARS  SECURITY
   HITRON-FEE0  Infra  11    54 Mbit/s  70      ▂▄▆_  WPA2
   WLAN-R46VFR  Infra  1     54 Mbit/s  65      ▂▄▆_  WPA2
   WLAN-718297  Infra  1     54 Mbit/s  59      ▂▄▆_  WPA2
   WLAN-MCQYPS  Infra  11    54 Mbit/s  40      ▂▄__  WPA2

*  SSID  MODE  CHAN  RATE  SIGNAL  BARS  SECURITY
```

Connect to the WiFi station:
```
nmcli device wifi connect 'mySSID' password 'myPASSWORD' ifname wlan0

nmcli device wifi connect 'WLAN-R46VFR' password '*****' ifname wlan0

```

Once you are connected you can see the '*' in front of your connected WiFi network:
```
nmcli device wifi list
*  SSID         MODE   CHAN  RATE       SIGNAL  BARS  SECURITY
   HITRON-FEE0  Infra  11    54 Mbit/s  70      ▂▄▆_  WPA2
   WLAN-718297  Infra  1     54 Mbit/s  59      ▂▄▆_  WPA2
   WLAN-MCQYPS  Infra  11    54 Mbit/s  40      ▂▄__  WPA2
*  WLAN-R46VFR  Infra  1     54 Mbit/s  100     ▂▄▆█  WPA2

*  SSID  MODE  CHAN  RATE  SIGNAL  BARS  SECURITY
```

And the C.H.I.P. should have got a IP address from the DHCP server:
```
ifconfig wlan0
wlan0     Link encap:Ethernet  HWaddr 7c:c7:09:3d:f2:0e
          inet addr:192.168.2.104  Bcast:192.168.2.255  Mask:255.255.255.0
          inet6 addr: fe80::7ec7:9ff:fe3d:f20e/64 Scope:Link
          inet6 addr: 2003:86:8c18:1a37:7ec7:9ff:fe3d:f20e/64 Scope:Global
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:172 errors:0 dropped:0 overruns:0 frame:0
          TX packets:127 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:33530 (32.7 KiB)  TX bytes:19765 (19.3 KiB)
```

Now we're connected to the network and can access the internet and the C.H.I.P. can be connected from our Mac or Linux machine.


## 4. Configure SSH access to the C.H.I.P.

```
ssh-add
ssh-keygen -R 192.168.2.104
ssh-copy-id root@192.168.2.104
ssh root@192.168.2.104

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Thu Jan  1 00:01:17 1970
-bash: warning: setlocale: LC_ALL: cannot change locale (en_US.UTF-8)
root@chip:~#
```
```


## 5. Upgrade the Linux kernel to the HypriotOS version

From the Mac we copy the new kernel tarball to the C.H.I.P.
```
scp 4.4.11+.tar.bz2 root@192.168.2.104:
```

Login to the C.H.I.P. and install the new kernel package:
```
ssh root@192.168.2.104
tar xvf 4.4.11+.tar.bz2 -C /
```

We don't have to make a backup of the original kernel files, because there is still a backup version of the important files at `/boot`.
```
ls -al /boot/
total 36736
drwxr-xr-x  3 root root    1200 Aug 28 11:39 .
drwxr-xr-x 20 root root    1312 Aug 28 11:39 ..
-rw-r--r--  1 root root 3418466 Aug 28 11:39 System.map-4.4.11+
-rw-r--r--  1 root root 3373213 May 28 00:27 System.map-4.4.11-ntc
-rw-r--r--  1 root root  165048 Aug 28 11:39 config-4.4.11+
-rw-r--r--  1 root root  158830 May 28 00:27 config-4.4.11-ntc
lrwxrwxrwx  1 root root      33 Jun  1 05:33 dtb -> dtbs/4.4.11-ntc/sun5i-r8-chip.dtb
lrwxrwxrwx  1 root root      33 Jun  1 05:33 dtb-4.4.11-ntc -> dtbs/4.4.11-ntc/sun5i-r8-chip.dtb
drwxr-xr-x  3 root root     232 Jun  1 05:32 dtbs
-rw-r--r--  1 root root 2444478 Jun  1 05:33 initrd.img-4.4.11-ntc
-rw-r--r--  1 root root   39076 Aug 28 11:39 sun5i-r8-chip.dtb
-rw-r--r--  1 root root   39076 Jun  1 05:32 sun5i-r8-chip.dtb.bak
-rwxr-xr-x  1 root root 7069480 Aug 28 11:39 vmlinuz-4.4.11+
-rwxr-xr-x  1 root root 6912856 May 28 00:27 vmlinuz-4.4.11-ntc
-rwxr-xr-x  1 root root 7069480 Aug 28 11:39 zImage
-rwxr-xr-x  1 root root 6912856 Jun  1 05:32 zImage.bak
```

The new kernel 4.4.11+ consists of the files `/boot/zImage` and `/boot/sun5i-r8-chip.dtb` and the kernel modules at `/lib/modules/4.4.11+/`.

Now reboot the system in order to load the new kernel.
```
reboot
```

Log into the C.H.I.P. via the USB or UART console line, because WiFi is turned off again due to the kernel modules are not available on this boot.

Check the kernel version:
```
uname -a
Linux chip 4.4.11+ #1 SMP Sun Aug 28 11:38:25 UTC 2016 armv7l GNU/Linux
```

And check the kernel modules directory:
```
ls -al /lib/modules/4.4.11+/
total 40
drwxr-xr-x 4 root root   432 Aug 28 11:39 .
drwxr-xr-x 4 root root   296 Aug 28 11:38 ..
drwxr-xr-x 2 root root   232 Aug 28 11:39 extra
drwxr-xr-x 9 root root   608 Aug 28 11:38 kernel
-rw-r--r-- 1 root root 22651 Aug 28 11:38 modules.builtin
-rw-r--r-- 1 root root 14107 Aug 28 11:38 modules.order
```

Here there are some files missing, that's the reason the WiFi kernel module didn't get loaded on boot. But we can easily generate the files:
```
depmod -a
```

Success, all the necessary files are here. 
```
ls -al /lib/modules/4.4.11+/
total 564
drwxr-xr-x 4 root root   1104 Aug 28 16:33 .
drwxr-xr-x 4 root root    296 Aug 28 11:38 ..
drwxr-xr-x 2 root root    232 Aug 28 11:39 extra
drwxr-xr-x 9 root root    608 Aug 28 11:38 kernel
-rw-r--r-- 1 root root  94529 Aug 28 16:33 modules.alias
-rw-r--r-- 1 root root 101508 Aug 28 16:33 modules.alias.bin
-rw-r--r-- 1 root root  22651 Aug 28 11:38 modules.builtin
-rw-r--r-- 1 root root  25619 Aug 28 16:33 modules.builtin.bin
-rw-r--r-- 1 root root  35925 Aug 28 16:33 modules.dep
-rw-r--r-- 1 root root  53783 Aug 28 16:33 modules.dep.bin
-rw-r--r-- 1 root root    183 Aug 28 16:33 modules.devname
-rw-r--r-- 1 root root  14107 Aug 28 11:38 modules.order
-rw-r--r-- 1 root root     55 Aug 28 16:33 modules.softdep
-rw-r--r-- 1 root root  92466 Aug 28 16:33 modules.symbols
-rw-r--r-- 1 root root 109208 Aug 28 16:33 modules.symbols.bin
```

Now, let's reboot the system and the C.H.I.P. should be accessible via the WiFi network again.
```
reboot
```


## 6. Check if the new kernel is Docker optimised

Before we go ahead we should check if the newly installed kernel is fully optimised and prepared to run Docker. For this purpose we download a check script directly from the Docker GitHub repo and run it locally.

```
wget https://github.com/docker/docker/raw/master/contrib/check-config.sh
chmod +x check-config.sh
```

From the detailled output of the check script we can see, that all mandatory kernel settings and almost all of the optional kernel settings for running Docker are applied:
(Note: in your output there are a lot of LOCAL warnings, which I just removed)
```
./check-config.sh
warning: /proc/config.gz does not exist, searching other paths for kernel config ...
info: reading kernel config from /boot/config-4.4.11+ ...

Generally Necessary:
- cgroup hierarchy: properly mounted [/sys/fs/cgroup]
- CONFIG_NAMESPACES: enabled
- CONFIG_NET_NS: enabled
- CONFIG_PID_NS: enabled
- CONFIG_IPC_NS: enabled
- CONFIG_UTS_NS: enabled
- CONFIG_DEVPTS_MULTIPLE_INSTANCES: enabled
- CONFIG_CGROUPS: enabled
- CONFIG_CGROUP_CPUACCT: enabled
- CONFIG_CGROUP_DEVICE: enabled
- CONFIG_CGROUP_FREEZER: enabled
- CONFIG_CGROUP_SCHED: enabled
- CONFIG_CPUSETS: enabled
- CONFIG_MEMCG: enabled
- CONFIG_KEYS: enabled
- CONFIG_VETH: enabled (as module)
- CONFIG_BRIDGE: enabled (as module)
- CONFIG_BRIDGE_NETFILTER: enabled (as module)
- CONFIG_NF_NAT_IPV4: enabled (as module)
- CONFIG_IP_NF_FILTER: enabled
- CONFIG_IP_NF_TARGET_MASQUERADE: enabled (as module)
- CONFIG_NETFILTER_XT_MATCH_ADDRTYPE: enabled (as module)
- CONFIG_NETFILTER_XT_MATCH_CONNTRACK: enabled (as module)
- CONFIG_NF_NAT: enabled (as module)
- CONFIG_NF_NAT_NEEDED: enabled
- CONFIG_POSIX_MQUEUE: enabled

Optional Features:
- CONFIG_USER_NS: enabled
- CONFIG_SECCOMP: enabled
- CONFIG_CGROUP_PIDS: enabled
- CONFIG_MEMCG_SWAP: enabled
- CONFIG_MEMCG_SWAP_ENABLED: enabled
- CONFIG_MEMCG_KMEM: enabled
- CONFIG_BLK_CGROUP: enabled
- CONFIG_BLK_DEV_THROTTLING: enabled
- CONFIG_IOSCHED_CFQ: enabled
- CONFIG_CFQ_GROUP_IOSCHED: enabled
- CONFIG_CGROUP_PERF: enabled
- CONFIG_CGROUP_HUGETLB: missing
- CONFIG_NET_CLS_CGROUP: enabled (as module)
- CONFIG_CGROUP_NET_PRIO: enabled
- CONFIG_CFS_BANDWIDTH: enabled
- CONFIG_FAIR_GROUP_SCHED: enabled
- CONFIG_RT_GROUP_SCHED: enabled
- CONFIG_IP_VS: enabled (as module)
- CONFIG_EXT3_FS: enabled
- CONFIG_EXT3_FS_XATTR: missing
- CONFIG_EXT3_FS_POSIX_ACL: enabled
- CONFIG_EXT3_FS_SECURITY: enabled
    (enable these ext3 configs if you are using ext3 as backing filesystem)
- CONFIG_EXT4_FS: enabled
- CONFIG_EXT4_FS_POSIX_ACL: enabled
- CONFIG_EXT4_FS_SECURITY: enabled
- Network Drivers:
  - "overlay":
    - CONFIG_VXLAN: enabled (as module)
    Optional (for secure networks):
    - CONFIG_XFRM_ALGO: enabled (as module)
    - CONFIG_XFRM_USER: enabled (as module)
  - "ipvlan":
    - CONFIG_IPVLAN: enabled (as module)
  - "macvlan":
    - CONFIG_MACVLAN: enabled (as module)
    - CONFIG_DUMMY: enabled (as module)
- Storage Drivers:
  - "aufs":
    - CONFIG_AUFS_FS: missing
  - "btrfs":
    - CONFIG_BTRFS_FS: enabled (as module)
    - CONFIG_BTRFS_FS_POSIX_ACL: enabled
  - "devicemapper":
    - CONFIG_BLK_DEV_DM: enabled (as module)
    - CONFIG_DM_THIN_PROVISIONING: enabled (as module)
  - "overlay":
    - CONFIG_OVERLAY_FS: enabled (as module)
  - "zfs":
    - /dev/zfs: missing
    - zfs command: missing
    - zpool command: missing

Limits:
- /proc/sys/kernel/keys/root_maxkeys: 1000000
```

Here is the check-config.sh output from the standard kernel, as you can see there are pretty much kernel modules missing:
```
root@chip:~# uname -a
Linux chip 4.4.11-ntc #1 SMP Sat May 28 00:27:07 UTC 2016 armv7l GNU/Linux

root@chip:~# ./check-config.sh 2>/dev/null | grep enabled
- CONFIG_CGROUPS: enabled
- CONFIG_KEYS: enabled
- CONFIG_IP_NF_FILTER: enabled
- CONFIG_IOSCHED_CFQ: enabled
- CONFIG_EXT4_FS: enabled
    - CONFIG_XFRM_ALGO: enabled (as module)
root@chip:~# ./check-config.sh 2>/dev/null | grep missing
- CONFIG_NAMESPACES: missing
- CONFIG_NET_NS: missing
- CONFIG_PID_NS: missing
- CONFIG_IPC_NS: missing
- CONFIG_UTS_NS: missing
- CONFIG_DEVPTS_MULTIPLE_INSTANCES: missing
- CONFIG_CGROUP_CPUACCT: missing
- CONFIG_CGROUP_DEVICE: missing
- CONFIG_CGROUP_FREEZER: missing
- CONFIG_CGROUP_SCHED: missing
- CONFIG_CPUSETS: missing
- CONFIG_MEMCG: missing
- CONFIG_VETH: missing
- CONFIG_BRIDGE: missing
- CONFIG_BRIDGE_NETFILTER: missing
- CONFIG_NF_NAT_IPV4: missing
- CONFIG_IP_NF_TARGET_MASQUERADE: missing
- CONFIG_NETFILTER_XT_MATCH_ADDRTYPE: missing
- CONFIG_NETFILTER_XT_MATCH_CONNTRACK: missing
- CONFIG_NF_NAT: missing
- CONFIG_NF_NAT_NEEDED: missing
- CONFIG_POSIX_MQUEUE: missing
- CONFIG_USER_NS: missing
- CONFIG_SECCOMP: missing
- CONFIG_CGROUP_PIDS: missing
- CONFIG_MEMCG_SWAP: missing
- CONFIG_MEMCG_SWAP_ENABLED: missing
- CONFIG_MEMCG_KMEM: missing
- CONFIG_BLK_CGROUP: missing
- CONFIG_BLK_DEV_THROTTLING: missing
- CONFIG_CFQ_GROUP_IOSCHED: missing
- CONFIG_CGROUP_PERF: missing
- CONFIG_CGROUP_HUGETLB: missing
- CONFIG_NET_CLS_CGROUP: missing
- CONFIG_CGROUP_NET_PRIO: missing
- CONFIG_CFS_BANDWIDTH: missing
- CONFIG_FAIR_GROUP_SCHED: missing
- CONFIG_RT_GROUP_SCHED: missing
- CONFIG_IP_VS: missing
- CONFIG_EXT3_FS: missing
- CONFIG_EXT3_FS_XATTR: missing
- CONFIG_EXT3_FS_POSIX_ACL: missing
- CONFIG_EXT3_FS_SECURITY: missing
- CONFIG_EXT4_FS_POSIX_ACL: missing
- CONFIG_EXT4_FS_SECURITY: missing
    - CONFIG_VXLAN: missing
    - CONFIG_XFRM_USER: missing
    - CONFIG_IPVLAN: missing
    - CONFIG_MACVLAN: missing
    - CONFIG_DUMMY: missing
    - CONFIG_AUFS_FS: missing
    - CONFIG_BTRFS_FS: missing
    - CONFIG_BTRFS_FS_POSIX_ACL: missing
    - CONFIG_BLK_DEV_DM: missing
    - CONFIG_DM_THIN_PROVISIONING: missing
    - CONFIG_OVERLAY_FS: missing
    - /dev/zfs: missing
    - zfs command: missing
    - zpool command: missing
```


## 7. Install fix so you can run the official Docker install.sh

```
cat /usr/local/bin/lsb_release
#!/bin/bash
# Hypriot:
#   this is a fake script to get Docker https://github.com/docker/docker/hack/install.sh working correctly for Debian/Jessie on the C.H.I.P. computer

if [[ "$1" == "-a" ]]; then
  exit 1
fi

###. /etc/os-release
ID=Raspbian
echo $ID
```


## 8. Install Docker from get.docker.com
```
curl -sSL get.docker.com | sh
```


## 9. optional: Install fix for Docker Engine 1.12.1 & Docker Machine 1.8.0
## 10. optional: Provision the Docker Engine from a Mac via Docker Machine
## 11. bonus track: Build a Docker SwarmMode Cluster with C.H.I.P.'s