#!/system/bin/sh
# Author: @WheresWaldo (Github)
# ×××××××××××××××××××××××××××××××××××× #

# We will wait until the boot process is complete
# within the limits of the OS
until [ "$(getprop sys.boot_completed)" = 1 ]; do
   sleep 1
done

# Module parent directory
MODDIR=${0%/*}

# Load FiiO Android Tweaker
"${MODDIR}/FiiOat.sh" >/dev/null
