#!/sbin/sh

SCRIPTNAME="PatchLevel"
LOGFILE=/tmp/recovery.log
TEMPSYS=/s
BUILDPROP=system/build.prop
DEFAULTPROP=prop.default
syspath="/dev/block/by-name/system$(getprop ro.boot.slot_suffix)"
venbin="vendor/bin"
SETFINGERPRINT=true

log_info() {
    echo "I:$SCRIPTNAME:$1" >> "$LOGFILE"
}

log_error() {
    echo "E:$SCRIPTNAME:$1" >> "$LOGFILE"
}

temp_mount() {
    mkdir "$1"
    if [ -d "$1" ]; then
        log_info "Temporary $2 folder created at $1."
    else
        log_error "Unable to create temporary $2 folder."
        finish_error
    fi
    mount -t ext4 -o ro "$3" "$1"
    if [ -n "$(ls -A "$1" 2>/dev/null)" ]; then
        log_info "$2 mounted at $1."
    else
        log_error "Unable to mount $2 to temporary folder."
        finish_error
    fi
}

relink() {
    log_info "Looking for $1 to update linker path..."
    if [ -f "$1" ]; then
        fname=$(basename "$1")
        target="/sbin/$fname"
        log_info "File found! Relinking $1 to $target..."
        sed 's|/system/bin/linker|///////sbin/linker|' "$1" > "$target"
        chmod 755 "$target"
    else
        log_info "File not found. Proceeding without relinking..."
    fi
}

finish() {
    umount "$TEMPSYS"
    rmdir "$TEMPSYS"
    touch /sbin/patchlevel_set
    log_info "Script complete. Device ready for decryption."
    exit 0
}

finish_error() {
    umount "$TEMPSYS"
    rmdir "$TEMPSYS"
    log_error "Script run incomplete. Device not ready for decryption."
    exit 0
}

osver_orig=$(getprop ro.build.version.release_orig)
patchlevel_orig=$(getprop ro.build.version.security_patch_orig)
osver=$(getprop ro.build.version.release)
patchlevel=$(getprop ro.build.version.security_patch)
device=$(getprop ro.product.device)
fingerprint=$(getprop ro.build.fingerprint)
product=$(getprop ro.build.product)

log_info "Running patchlevel pre-decrypt script for TWRP..."
for file in $(find $venbin -type f); do
  relink "$file"
done

temp_mount "$TEMPSYS" "system" "$syspath"
if [ -f "$TEMPSYS/$BUILDPROP" ]; then
    log_info "Current system is Oreo or above. Proceed with setting OS version and security patch level..."
    log_info "Build.prop exists! Setting system properties from build.prop"
    log_info "Current OS version: $osver"
    osver=$(grep -i 'ro.build.version.release' "$TEMPSYS/$BUILDPROP"  | cut -f2 -d'=' -s)
    if [ -n "$osver" ]; then
        resetprop ro.build.version.release "$osver"
        sed -i "s/ro.build.version.release=.*/ro.build.version.release=""$osver""/g" "/$DEFAULTPROP" ;
        log_info "New OS Version: $osver"
    fi
    log_info "Current security patch level: $patchlevel"
    patchlevel=$(grep -i 'ro.build.version.security_patch' "$TEMPSYS/$BUILDPROP"  | cut -f2 -d'=' -s)
    if [ -n "$patchlevel" ]; then
        resetprop ro.build.version.security_patch "$patchlevel"
        sed -i "s/ro.build.version.security_patch=.*/ro.build.version.security_patch=""$patchlevel""/g" "/$DEFAULTPROP" ;
        log_info "New security patch level: $patchlevel"
    fi
    # Only needed for some devices (for stock OTA capability), so set "SETFINGERPRINT" variable to "false" if your device isn't one of them
    if [ "$SETFINGERPRINT" = "true" ]; then
        log_info "Current fingerprint: $fingerprint"
        fingerprint=$(grep -i 'ro.build.fingerprint' "$TEMPSYS/$BUILDPROP"  | cut -f2 -d'=' -s)
        if [ -n "$fingerprint" ]; then
            resetprop ro.build.fingerprint "$fingerprint"
            sed -i "s/ro.build.fingerprint=.*/ro.build.fingerprint=""$fingerprint""/g" "/$DEFAULTPROP" ;
            log_info "New fingerprint: $fingerprint"
        fi
    fi
else
    if [ -n "$osver_orig" ]; then
        log_info "Original OS version: $osver_orig"
        log_info "Current OS version: $osver"
        log_info "Setting OS Version to $osver_orig"
        osver=$osver_orig
        resetprop ro.build.version.release "$osver"
        sed -i "s/ro.build.version.release=.*/ro.build.version.release=""$osver""/g" "/$DEFAULTPROP" ;
    else
        log_info "No Original OS Version found. Proceeding with existing value."
        log_info "Current OS version: $osver"
    fi
    if [ -n "$patchlevel_orig" ]; then
        log_info "Original security patch level: $patchlevel_orig"
        log_info "Current security patch level: $patchlevel"
        log_info "Setting security patch level to $patchlevel_orig"
        patchlevel=$patchlevel_orig
        resetprop ro.build.version.security_patch "$patchlevel"
        sed -i "s/ro.build.version.security_patch=.*/ro.build.version.security_patch=""$patchlevel""/g" "/$DEFAULTPROP" ;
    else
        log_info "No Original security patch level found. Proceeding with existing value."
        log_info "Current security patch level: $patchlevel"
    fi
fi
finish
