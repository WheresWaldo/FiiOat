# shellcheck disable=SC2148
# shellcheck disable=SC2034
SKIPUNZIP=1
RM_RF() {
rm /sdcard/Documents/FiiOat/FiiOat.log 2>/dev/null
rm /sdcard/FiiOat.log 2>/dev/null
rm /sdcard/FiiOat/FiiOat.txt 2>/dev/null
rm "${MODPATH}/FiiOat.log" 2>/dev/null
rm "${MODPATH}/FiiOat-logging-error.log" 2>/dev/null
rm "${MODPATH}/LICENSE" 2>/dev/null
rm "${MODPATH}/README.md" 2>/dev/null
}
SET_PERMISSION() {
ui_print "- Setting Permissions"
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "${MODPATH}/FiiOat.sh" 0 0 0755 0700
}
MOD_EXTRACT() {
ui_print "- Extracting Module Files"
unzip -o "$ZIPFILE" FiiOat.sh -d "$MODPATH" >&2
unzip -o "$ZIPFILE" service.sh -d "$MODPATH" >&2
unzip -o "$ZIPFILE" module.prop -d "$MODPATH" >&2
}
MOD_PRINT() {
ui_print "- FiiO Android Tweaker"
ui_print "- Installing"
}
set -x
RM_RF
MOD_PRINT
MOD_EXTRACT
SET_PERMISSION
