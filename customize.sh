# shellcheck disable=SC2148
# shellcheck disable=SC2034
SKIPUNZIP=1
FIIO_MODEL=$(getprop ro.product.model)


RM_RF() {
rm "${MODPATH}/fiioat.log" 2>/dev/null
rm "${MODPATH}/error.log" 2>/dev/null
rm "${MODPATH}/info.log" 2>/dev/null
rm "${MODPATH}/LICENSE" 2>/dev/null
rm "${MODPATH}/README.md" 2>/dev/null
}

MOD_PRINT() {
ui_print "- FiiO Android Tweaker"
ui_print "- Installing on $FIIO_MODEL"
ui_print "- Executed on $(date)"
}

MOD_EXTRACT() {
ui_print "- Extracting Module Files"
unzip -o "$ZIPFILE" FiiOat.sh -d "$MODPATH" >&2
ui_print "- Main script extracted"
unzip -o "$ZIPFILE" service.sh -d "$MODPATH" >&2
ui_print "- Service script extracted"
unzip -o "$ZIPFILE" module.prop -d "$MODPATH" >&2
ui_print "- Module properties extracted"
}

SET_PERMISSION() {
ui_print "- Setting Permissions"
set_perm_recursive "$MODPATH" 0 0 0755 0644
ui_print "- Setting ${MODPATH} Permissions"
set_perm_recursive "${MODPATH}/FiiOat.sh" 0 0 0755 0700
ui_print "- Setting /sys/devices/system/cpu/ Permissions"
set_parm_recursive "/sys/devices/system/cpu/cpufreq" 0 0 0755 0644
ui_print "- Setting /sys/module/workqueue/ Permissions"
set_parm_recursive "/sys/module/workqueue/parameters" 0 0 0755 0644
}

ui_print "- Ready to begin real work"
set -x
ui_print "- Setting scripts as executable"
RM_RF
ui_print "- Old files removed"
MOD_PRINT
MOD_EXTRACT
ui_print "- All files extracted"
SET_PERMISSION
ui_print "- All permissions successfully set"
ui_print "-"
ui_print "- Script execution completed"
ui_print "- FiiO Android Tweak module is installed"
ui_print "- Please REBOOT/RESTART the device to take effect"
ui_print ""
ui_print "- WARNING:"
ui_print "- While every effort has been made to assure your"
ui_print "- device safety, use at your own risk."
ui_print ""