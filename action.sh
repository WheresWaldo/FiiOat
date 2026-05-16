#!/system/bin/sh
# FiiOat - Button Remap Reconfiguration
# Run from Magisk Manager module action button
# ×××××××××××××××××××××××××××××××××××× #

MODDIR=${0%/*}
BUTTON_CONF="${MODDIR}/button_remap.conf"

# Current config
CURRENT="(none)"
if [ -f "$BUTTON_CONF" ]; then
    CURRENT="$(cat "$BUTTON_CONF" | tr -d '[:space:]')"
    [ "$CURRENT" = "disabled" ] && CURRENT="disabled"
fi

echo "**************************************************"
echo " FiiOat - Button Remap Configuration"
echo "**************************************************"
echo ""
echo "Current setting: $CURRENT"
echo ""
echo "Do you want to remap the multifunction button?"
echo ""
echo "  [Vol+] = YES"
echo "  [Vol-] = NO (disable remap)"
echo ""

# Volume key selection
while true; do
    key_event="$(getevent -lqc 1 2>/dev/null)"
    echo "$key_event" | grep -q 'KEY_VOLUMEUP.*DOWN' && { ENABLE=1; break; }
    echo "$key_event" | grep -q 'KEY_VOLUMEDOWN.*DOWN' && { ENABLE=0; break; }
done

if [ "$ENABLE" -eq 0 ]; then
    echo "disabled" > "$BUTTON_CONF"
    echo ""
    echo "Button remap: DISABLED"
    echo ""
    echo "Reboot is required to apply changes."
    echo ""
    echo "  [Vol+] = Reboot now"
    echo "  [Vol-] = Reboot later"
    echo ""
    while true; do
        key_event="$(getevent -lqc 1 2>/dev/null)"
        if echo "$key_event" | grep -q 'KEY_VOLUMEUP.*DOWN'; then
            echo "Rebooting..."
            sleep 1
            /system/bin/reboot
            break
        elif echo "$key_event" | grep -q 'KEY_VOLUMEDOWN.*DOWN'; then
            echo "OK, remember to reboot manually."
            break
        fi
    done
    exit 0
fi

# Scan launchable apps
echo "WARNING: Remember to disable the native"
echo "multifunction button action in FiiO Settings"
echo "to avoid conflicts with this remap."
echo ""
echo "Scanning installed apps..."

i=0
app_list=""
pkg_list=""

launcher_pkgs="$(pm query-activities -a android.intent.action.MAIN -c android.intent.category.LAUNCHER 2>/dev/null | grep 'packageName=' | sed 's/.*packageName=//' | sort -u)"

if [ -z "$launcher_pkgs" ]; then
    launcher_pkgs="$(pm list packages -3 2>/dev/null | sed 's/package://' | sort -u)"
fi

while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    label="$(dumpsys package "$pkg" 2>/dev/null | grep -m1 'applicationLabel=' | sed 's/.*applicationLabel=//')"
    [ -z "$label" ] && label="$pkg"
    i=$((i + 1))
    app_list="${app_list}${i}. ${label} (${pkg})\n"
    pkg_list="${pkg_list}${pkg}\n"
done <<EOF
$(echo "$launcher_pkgs")
EOF

if [ "$i" -eq 0 ]; then
    echo "No launchable apps found!"
    exit 1
fi

echo ""
echo "Found $i apps"
echo ""
echo "[Vol+] / [Vol-] to scroll"
echo "[Next Song] to confirm"
echo ""

current=1
total=$i

current_line="$(printf '%b' "$app_list" | sed -n "${current}p")"
echo "  >> $current_line"

while true; do
    key_event="$(getevent -lqc 1 2>/dev/null)"

    if echo "$key_event" | grep -q 'KEY_VOLUMEUP.*DOWN'; then
        current=$((current + 1))
        [ "$current" -gt "$total" ] && current=1
        current_line="$(printf '%b' "$app_list" | sed -n "${current}p")"
        echo "  >> $current_line"

    elif echo "$key_event" | grep -q 'KEY_VOLUMEDOWN.*DOWN'; then
        current=$((current - 1))
        [ "$current" -lt 1 ] && current=$total
        current_line="$(printf '%b' "$app_list" | sed -n "${current}p")"
        echo "  >> $current_line"

    elif echo "$key_event" | grep -q 'KEY_NEXTSONG.*DOWN'; then
        selected_pkg="$(printf '%b' "$pkg_list" | sed -n "${current}p")"
        break
    fi
done

echo ""
echo "Selected: $selected_pkg"

echo "$selected_pkg" > "$BUTTON_CONF"
chmod 0644 "$BUTTON_CONF"

echo ""
echo "Configuration saved!"
echo ""
echo "Reboot is required to apply changes."
echo ""
echo "  [Vol+] = Reboot now"
echo "  [Vol-] = Reboot later"
echo ""

while true; do
    key_event="$(getevent -lqc 1 2>/dev/null)"
    if echo "$key_event" | grep -q 'KEY_VOLUMEUP.*DOWN'; then
        echo "Rebooting..."
        sleep 1
        /system/bin/reboot
        break
    elif echo "$key_event" | grep -q 'KEY_VOLUMEDOWN.*DOWN'; then
        echo "OK, remember to reboot manually."
        break
    fi
done
