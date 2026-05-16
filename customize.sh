# shellcheck disable=SC2148
# shellcheck disable=SC2034
SKIPUNZIP=1
FIIO_MODEL=$(getprop ro.product.model)
FIRMWARE_VERSION=$(getprop ro.product.version)

MOD_PRINT() {
  ui_print "- FiiO Android Tweaker"
  ui_print "- Installing on $FIIO_MODEL" 
  ui_print "- Firmware $FIRMWARE_VERSION"
  ui_print "- Executed on $(date +'%m-%d-%Y')"
  ui_print "- Installed in $MODPATH"
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
  unzip -o "$ZIPFILE" action.sh -d "$MODPATH" >&2
  /system/bin/touch "${MODPATH}/info.log"
  /system/bin/touch "${MODPATH}/error.log"
  ui_print "- New files extracted"
}

SET_PERMISSION() {
  ui_print "- Setting Permissions"
  set_perm_recursive "$MODPATH" 0 0 0755 0644
  set_perm "${MODPATH}/FiiOat.sh" 0 0 0755
  set_perm "${MODPATH}/service.sh" 0 0 0755
  set_perm "${MODPATH}/action.sh" 0 0 0755
  set_perm "${MODPATH}/info.log" 0 0 0666
  set_perm "${MODPATH}/error.log" 0 0 0666
  set_perm "/sys/devices/system/cpu/cpufreq" 0 0 0655
  set_perm "/sys/module/workqueue/parameters" 0 0 0655
  set_perm "/sys/class/zram-control/hot_remove" 0 0 0655
  set_perm "/sys/block/zram0/reset" 0 0 0655
  ui_print "- All permissions successfully set"
}

# ×××××××××××××××××××××××××××××××××××× #
# Volume key selection helper
# Returns 0 for Vol+, 1 for Vol-
# ×××××××××××××××××××××××××××××××××××× #
vol_key_test() {
  while true; do
    local key_event
    key_event="$(getevent -lqc 1 2>/dev/null)"
    echo "$key_event" | grep -q 'KEY_VOLUMEUP.*DOWN' && return 0
    echo "$key_event" | grep -q 'KEY_VOLUMEDOWN.*DOWN' && return 1
  done
}

# Wait for next song button press (confirmation)
wait_confirm_key() {
  while true; do
    local key_event
    key_event="$(getevent -lqc 1 2>/dev/null)"
    echo "$key_event" | grep -q 'KEY_NEXTSONG.*DOWN' && return 0
  done
}

# ×××××××××××××××××××××××××××××××××××× #
# Button remap configuration
# ×××××××××××××××××××××××××××××××××××× #
CONFIGURE_BUTTON_REMAP() {
  ui_print "-"
  ui_print "**************************************************"
  ui_print "- BUTTON REMAP CONFIGURATION"
  ui_print "**************************************************"
  ui_print "-"
  ui_print "- Do you want to remap the multifunction button"
  ui_print "- (KEY_TV) to launch an app?"
  ui_print "-"
  ui_print "  [Vol+] = YES"
  ui_print "  [Vol-] = NO"
  ui_print "-"

  if vol_key_test; then
    ui_print "- Button remap: ENABLED"
    ui_print "-"
    ui_print "- WARNING: Remember to disable the native"
    ui_print "- multifunction button action in FiiO Settings"
    ui_print "- to avoid conflicts with this remap."
    ui_print "-"

    # Detect all launchable apps
    ui_print "- Scanning installed apps..."
    local i=0
    local app_list=""
    local pkg_list=""

    # Get all packages with a launcher intent
    local launcher_pkgs
    launcher_pkgs="$(pm query-activities -a android.intent.action.MAIN -c android.intent.category.LAUNCHER 2>/dev/null | grep 'packageName=' | sed 's/.*packageName=//' | sort -u)"

    # Fallback if pm query-activities doesn't work on this firmware
    if [ -z "$launcher_pkgs" ]; then
      launcher_pkgs="$(pm list packages -3 2>/dev/null | sed 's/package://' | sort -u)"
    fi

    while IFS= read -r pkg; do
      [ -z "$pkg" ] && continue
      # Get a readable label - use the package name as fallback
      local label
      label="$(dumpsys package "$pkg" 2>/dev/null | grep -m1 'applicationLabel=' | sed 's/.*applicationLabel=//')"
      [ -z "$label" ] && label="$pkg"
      i=$((i + 1))
      app_list="${app_list}${i}. ${label} (${pkg})\n"
      pkg_list="${pkg_list}${pkg}\n"
    done <<EOF
$(echo "$launcher_pkgs")
EOF

    if [ "$i" -eq 0 ]; then
      ui_print "- No launchable apps found!"
      ui_print "- Button remap skipped."
      echo "disabled" > "${MODPATH}/button_remap.conf"
      return
    fi

    ui_print "- Found $i launchable apps"
    ui_print "-"
    ui_print "- Use [Vol+] / [Vol-] to scroll"
    ui_print "- Press [Next Song] to confirm"
    ui_print "-"

    local current=1
    local total=$i
    local selected_pkg=""

    # Show first app
    local current_line
    current_line="$(echo -e "$app_list" | sed -n "${current}p")"
    ui_print "  >> $current_line"

    while true; do
      local key_event
      key_event="$(getevent -lqc 1 2>/dev/null)"

      if echo "$key_event" | grep -q 'KEY_VOLUMEUP.*DOWN'; then
        # Next app
        current=$((current + 1))
        [ "$current" -gt "$total" ] && current=1
        current_line="$(echo -e "$app_list" | sed -n "${current}p")"
        ui_print "  >> $current_line"

      elif echo "$key_event" | grep -q 'KEY_VOLUMEDOWN.*DOWN'; then
        # Previous app
        current=$((current - 1))
        [ "$current" -lt 1 ] && current=$total
        current_line="$(echo -e "$app_list" | sed -n "${current}p")"
        ui_print "  >> $current_line"

      elif echo "$key_event" | grep -q 'KEY_NEXTSONG.*DOWN'; then
        # Confirm selection
        selected_pkg="$(echo -e "$pkg_list" | sed -n "${current}p")"
        break
      fi
    done

    ui_print "-"
    ui_print "- Selected: $selected_pkg"
    ui_print "-"

    # Save config
    echo "$selected_pkg" > "${MODPATH}/button_remap.conf"
    set_perm "${MODPATH}/button_remap.conf" 0 0 0644
    ui_print "- Button remap configuration saved!"

  else
    ui_print "- Button remap: DISABLED"
    echo "disabled" > "${MODPATH}/button_remap.conf"
    set_perm "${MODPATH}/button_remap.conf" 0 0 0644
  fi
  ui_print "-"
}

ui_print "-"
ui_print "**************************************************"
ui_print "-"
MOD_PRINT
ui_print "-"
ui_print "**************************************************"
ui_print "-"
RM_RF
MOD_EXTRACT
SET_PERMISSION
CONFIGURE_BUTTON_REMAP
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
