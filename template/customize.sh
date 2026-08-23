rm -rf /data/adb/omk
# shellcheck disable=SC2034
SKIPUNZIP=1
SONAME="Oh My Keymint"
SUPPORTED_ABIS="arm64 arm64-v8a"
MIN_SDK=29
if [ "$BOOTMODE" ] && [ "$KSU" ]; then
  ui_print "- Installing from KernelSU app"
  ui_print "- KernelSU version: $KSU_KERNEL_VER_CODE (kernel) + $KSU_VER_CODE (ksud)"
  if [ "$(which magisk)" ]; then
    ui_print "*********************************************************"
    ui_print "! Multiple root implementation is NOT supported!"
    ui_print "! Please uninstall Magisk before installing Oh My Keymint"
    abort    "*********************************************************"
  fi
elif [ "$BOOTMODE" ] && [ "$MAGISK_VER_CODE" ]; then
  ui_print "- Installing from Magisk app"
else
  ui_print "*********************************************************"
  ui_print "! Install from recovery is not supported"
  ui_print "! Please install from KernelSU or Magisk app"
  abort    "*********************************************************"
fi
VERSION=$(grep_prop version "${TMPDIR}/module.prop")
ui_print "- Installing $SONAME $VERSION"
# check architecture
support=false
for abi in $SUPPORTED_ABIS
do
  if [ "$ARCH" == "$abi" ]; then
    support=true
  fi
done
if [ "$support" == "false" ]; then
  abort "! Unsupported platform: $ARCH"
else
  ui_print "- Device platform: $ARCH"
fi
# check android
if [ "$API" -lt $MIN_SDK ]; then
  ui_print "! Unsupported sdk: $API"
  abort "! Minimal supported sdk is $MIN_SDK"
else
  ui_print "- Device sdk: $API"
fi
ui_print "- Extracting verify.sh"
unzip -o "$ZIPFILE" 'verify.sh' -d "$TMPDIR" >&2
if [ ! -f "$TMPDIR/verify.sh" ]; then
  ui_print "*********************************************************"
  ui_print "! Unable to extract verify.sh!"
  ui_print "! This zip may be corrupted, please try downloading again"
  abort    "*********************************************************"
fi
. "$TMPDIR/verify.sh"
extract "$ZIPFILE" 'customize.sh'  "$TMPDIR/.vunzip"
extract "$ZIPFILE" 'verify.sh'     "$TMPDIR/.vunzip"
ui_print "- Extracting module files"
extract "$ZIPFILE" 'module.prop'     "$MODPATH"
extract "$ZIPFILE" 'post-fs-data.sh' "$MODPATH"
extract "$ZIPFILE" 'service.sh'      "$MODPATH"
extract "$ZIPFILE" 'sepolicy.rule'   "$MODPATH"
extract "$ZIPFILE" 'daemon'          "$MODPATH"
extract "$ZIPFILE" 'daemon-injector' "$MODPATH"
extract "$ZIPFILE" 'injector.toml'   "$MODPATH"
extract "$ZIPFILE" 'keybox.xml'      "$MODPATH"
extract "$ZIPFILE" 'action.sh'      "$MODPATH"
extract "$ZIPFILE" 'webroot/index.html' "$MODPATH"
extract "$ZIPFILE" 'webroot/main.js' "$MODPATH"
extract "$ZIPFILE" 'webroot/script.sh' "$MODPATH"
extract "$ZIPFILE" 'webroot/script2.sh' "$MODPATH"
extract "$ZIPFILE" 'webroot/script3.sh' "$MODPATH"
chmod 755 "$MODPATH/daemon" "$MODPATH/daemon-injector" \
  "$MODPATH/post-fs-data.sh" "$MODPATH/service.sh"
if [ "$ARCH" = "x64" ] || [ "$ARCH" = "x86_64" ]; then
  ui_print "- Using packaged x64 binaries"
  BINDIR="$MODPATH/libs/x86_64"
  extract "$ZIPFILE" 'libs/x86_64/keymint' "$MODPATH"
  extract "$ZIPFILE" 'libs/x86_64/inject'  "$MODPATH"
elif [ "$ARCH" = "arm64" ] || [ "$ARCH" = "arm64-v8a" ]; then
  ui_print "- Using packaged arm64 binaries"
  BINDIR="$MODPATH/libs/arm64-v8a"
  extract "$ZIPFILE" 'libs/arm64-v8a/keymint' "$MODPATH"
  extract "$ZIPFILE" 'libs/arm64-v8a/inject'  "$MODPATH"
else
  abort "! Unsupported platform: $ARCH"
fi
[ -f "$BINDIR/keymint" ] || abort "! Missing $BINDIR/keymint"
[ -f "$BINDIR/inject" ] || abort "! Missing $BINDIR/inject"
chmod 755 "$BINDIR/keymint" "$BINDIR/inject"
CONFIG_DIR=/data/adb/omk
mkdir -p "$CONFIG_DIR"
rm -f "$CONFIG_DIR/restart.keymint" "$CONFIG_DIR/restart.injector" "$CONFIG_DIR/restart.all"
rm -f "$CONFIG_DIR/keymint" "$CONFIG_DIR/inject" "$CONFIG_DIR/injector" # clean up old hot-update binaries
if [ ! -e "$CONFIG_DIR/omkdata" ] && [ ! -L "$CONFIG_DIR/omkdata" ]; then
  ln -s /data/misc/keystore/omk "$CONFIG_DIR/omkdata"
fi
ui_print "- Prepare /data/adb/modules/bl/service.sh"
mkdir -p /data/adb/modules/bl
cat > /data/adb/modules/bl/service.sh <<'EOF'
wait_for_boot() {
  local i=0
  while [ "$i" -lt 60 ]; do
    local boot=$(getprop sys.boot_completed)
    [ "$boot" = "1" ] && break
    i=$((i + 1))
    sleep 1
  done
}
check_reset_prop() {
  local NAME="$1"
  local EXPECTED="$2"
  local VALUE=$(resetprop "$NAME")
  [ -n "$VALUE" ] && [ "$VALUE" != "$EXPECTED" ] && resetprop -n "$NAME" "$EXPECTED"
}
wait_for_boot
settings put global adb_enabled 0 >/dev/null 2>&1
stop adbd >/dev/null 2>&1
setprop ctl.stop adbd >/dev/null 2>&1
check_reset_prop "ro.boot.vbmeta.device_state" "locked"
check_reset_prop "ro.boot.verifiedbootstate" "green"
check_reset_prop "ro.boot.flash.locked" "1"
check_reset_prop "ro.boot.veritymode" "enforcing"
check_reset_prop "ro.secureboot.lockstate" "locked"
check_reset_prop "ro.debuggable" "0"
check_reset_prop "ro.force.debuggable" "0"
check_reset_prop "ro.secure" "1"
check_reset_prop "ro.adb.secure" "1"
check_reset_prop "ro.build.type" "user"
check_reset_prop "ro.build.tags" "release-keys"
check_reset_prop "ro.bootmode" "normal"
EOF
