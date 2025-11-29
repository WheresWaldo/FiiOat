# shellcheck disable=SC2148
# shellcheck disable=SC2034
SKIPUNZIP=1
FIIO_MODEL=$(getprop ro.product.model)
FIRMWARE_VERSION=$(getprop ro.product.version)

MOD_PRINT() {
  ui_print "**************************************************"
  ui_print "-"
  ui_print "- FiiO Android Tweaker"
  ui_print "- Installing on $FIIO_MODEL" 
  ui_print "- Firmware $FIRMWARE_VERSION"
  ui_print "- Executed on $(date)"
  ui_print "- Installed in $MODPATH"
  ui_print "-"
  ui_print "**************************************************"
}

RM_RF() {
  ui_print "- Removing old files"
  rm /sdcard/Documents/FiiOat/FiiOat.log 2>/dev/null
  rm /sdcard/FiiOat.log 2>/dev/null
  rm /sdcard/FiiOat/FiiOat.txt 2>/dev/null
  rm "${MODPATH}/FiiOat.log" 2>/dev/null
  rm "${MODPATH}/error.log" 2>/dev/null
  rm "${MODPATH}/LICENSE" 2>/dev/null
  rm "${MODPATH}/README.md" 2>/dev/null
  ui_print "- Old files removed"
}

MOD_EXTRACT() {
  ui_print "- Extracting module files"
  unzip -o "$ZIPFILE" FiiOat.sh -d "$MODPATH" >&2
  unzip -o "$ZIPFILE" service.sh -d "$MODPATH" >&2
  unzip -o "$ZIPFILE" module.prop -d "$MODPATH" >&2
  /system/bin/touch "${MODPATH}/info.log"
  /system/bin/touch "${MODPATH}/error.log"
  ui_print "- New files extracted"
}

SET_PERMISSION() {
  ui_print "- Setting Permissions"
  set_perm_recursive "$MODPATH" 0 0 0755 0644
  set_perm "${MODPATH}/FiiOat.sh" 0 0 0755
  set_perm "${MODPATH}/service.sh" 0 0 0755
  set_perm "${MODPATH}/info.log" 0 0 0666
  set_perm "${MODPATH}/error.log" 0 0 0666
  set_perm "/sys/devices/system/cpu/cpufreq" 0 0 0655
  set_perm "/sys/module/workqueue/parameters" 0 0 0655
  set_perm "/sys/class/zram-control/hot_remove" 0 0 0655
  set_perm "/sys/block/zram0/reset" 0 0 0655
  ui_print "- All permissions successfully set"
}

ui_print "-"
MOD_PRINT
RM_RF
MOD_EXTRACT
SET_PERMISSION
ui_print "-"
ui_print "- Script execution completed"
ui_print "- FiiO Android Tweak module is installed"
ui_print "- Please REBOOT/RESTART the Device to take effects"
ui_print "-"
ui_print "**************************************************"
ui_print "-"
ui_print "- WARNING:"
ui_print "- While every effort has been made to assure your"
ui_print "- device safety, use at your own risk."
ui_print "-"
ui_print "**************************************************"
