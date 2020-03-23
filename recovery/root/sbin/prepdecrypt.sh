#!/sbin/sh

finish() {
    umount /s

    setprop crypto.ready 1

    exit 0
}

suffix=$(getprop ro.boot.slot_suffix)
if [ -z "$suffix" ]; then
    suf=$(getprop ro.boot.slot)
    suffix="_$suf"
fi

syspath="/dev/block/bootdevice/by-name/system$suffix"
mkdir /s
mount -t ext4 -o ro "$syspath" /s

is_fastboot_twrp=$(getprop ro.boot.fastboot)
if [ ! -z "$is_fastboot_twrp" ]; then
    setprop ro.build.version.release "$(getprop ro.build.version.release_orig)"
    setprop ro.build.version.security_patch "$(getprop ro.build.version.security_patch_orig)"
    finish
fi

if [ -f /s/system/build.prop ]; then
    setprop ro.build.version.release "$(grep -i 'ro.build.version.release' /s/system/build.prop | cut -f2 -d'=')"
    setprop ro.build.version.security_patch "$(grep -i 'ro.build.version.security_patch' /s/system/build.prop  | cut -f2 -d'=')"
    finish
fi

setprop ro.build.version.release "$(getprop ro.build.version.release_orig)"
setprop ro.build.version.security_patch "$(getprop ro.build.version.security_patch_orig)"
finish
