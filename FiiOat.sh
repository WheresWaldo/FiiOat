#!/system/bin/sh
# Author: @WheresWaldo (Github)
# ×××××××××××××××××××××××××××××××××××× #

# Get parent directory
MODDIR=${0%/*}

# We need to wait until the system is completely booted
until [ "$(getprop sys.boot_completed)" = 1 ]
   do
   sleep 1
   done
sleep 3

# Identify the filenames for logs
INFO_LOG="${MODDIR}/info.log"
ERROR_LOG="${MODDIR}/error.log"

# Create and empty logs if not already done
:> "$INFO_LOG"
:> "$ERROR_LOG"

RELEASE="v17_r39(test)"

# Function to append a message to the specified log file
log_message() {
    local log_file="$1"
    local message="$2"
    echo "[$(date "+%H:%M:%S")] $message" >> "$log_file"
}

# Function to log info messages
log_info() {
    log_message "$INFO_LOG" "$1"
}

# Function to log error messages
log_error() {
    log_message "$ERROR_LOG" "$1"
}

# Function to write a value to a specified file and
# log an error if write fails
write_value() {
    local file_path="$1"
    local value="$2"

    # Check if the file exists
    if [ ! -f "$file_path" ]; then
        log_error "Error: File $file_path does not exist."
        return 1
    fi

    # Make the file writable
    chmod a+w "$file_path" 2>/dev/null

    # Write new value, log error if it fails
    if ! echo "$value" >"$file_path" 2>/dev/null; then
        log_error "Error: Failed to write to $file_path."
        return 1
    else
        return 0
    fi
}

# Variables
ANDROID_VERSION=$(getprop ro.build.version.release)
FIIO_MODEL=$(getprop ro.product.model)
FIIO_FIRMWARE=$(getprop ro.product.version)
APP_PATH="/system/app"
BIN_PATH="/system/bin"
CPUFREQ_PATH="/sys/devices/system/cpu/cpufreq"
CPUSET_PATH="/dev/cpuset"
IPV4_PATH="/proc/sys/net/ipv4"
KERNEL_PATH="/proc/sys/kernel"
MEMORY_PATH="/proc/sys/vm"
MGLRU_PATH="/sys/kernel/mm/lru_gen"
MODULE_PATH="/sys/module"
PRIVAPP_PATH="/system/priv-app"
SCHEDUTIL_PATH="/sys/devices/system/cpu/"
TOTAL_RAM=$(grep -i "MemTotal" /proc/meminfo | awk '{print $2}')
UCLAMP_PATH="/dev/stune/top-app/uclamp.max"
SWAP_TOTAL=$(grep -i "SwapTotal" /proc/meminfo | tr -d [:alpha:]:" ")
ZRAM_PATH="/dev/block/zram0"

# Log starting information
log_info "Starting FiiOat $RELEASE"
log_info "Build Date: 11/25/2025"
log_info "Author: @WheresWaldo (Github/Head-Fi)"
log_info "Device: $FIIO_MODEL"
log_info "Firmware: $FIIO_FIRMWARE"
log_info "Kernel: $(uname -r)"
log_info "ROM Build: $(getprop ro.system.build.id)"
log_info "Android Version: $ANDROID_VERSION"

# Schedutil rate-limits tweak
log_info "Applying CPU schedutil governor rate-limits..."
write_value "$SCHEDUTIL_PATH/cpu0/cpufreq/schedutil/rate_limit_us" 10000
write_value "$SCHEDUTIL_PATH/cpu4/cpufreq/schedutil/rate_limit_us" 10000
log_info "Done."

# Setting CPU core minimum frequencies
log_info "Applying minimum cpu E-core frequency..."
write_value "$CPUFREQ_PATH/policy0/scaling_min_freq" 300000
log_info "Done."
log_info "Applying minimum cpu P-core frequency..."
write_value "$CPUFREQ_PATH/policy4/scaling_min_freq" 300000
log_info "Done." 

# Enable CRF by default
log_info "Enabling child_runs_first..."
write_value "$KERNEL_PATH/sched_child_runs_first" 1
log_info "Done."

# This should be the simplest way to disable ZRAM
# First turn off, then reset to zero, finally disable
log_info "Initial total swap space = $SWAP_TOTAL kb"
"${BIN_PATH}/swapoff /dev/block/zram0">/dev/null
write_value "/sys/block/zram0/reset" 1
write_value "/sys/class/zram-control/hot_remove" 0
SWAP_TOTAL=$(grep -i SwapTotal /proc/meminfo | tr -d [:alpha:]:" ")
log_info "Final total swap space = $SWAP_TOTAL kb"

# Apply RAM/SWAP tweaks
# The stat_interval reduces jitter (Credits to kdrag0n)
# Credits to RedHat for dirty_ratio
log_info "Applying appropriate RAM Tweaks..."
write_value "$MEMORY_PATH/vfs_cache_pressure" 50
write_value "$MEMORY_PATH/stat_interval" 30
write_value "$MEMORY_PATH/compaction_proactiveness" 0
write_value "$MEMORY_PATH/page-cluster" 0
log_info "Applying appropriate SWAP tweaks..."
write_value "$MEMORY_PATH/swappiness" 60
write_value "$MEMORY_PATH/dirty_ratio" 60
log_info "Done."

# MGLRU tweaks
# Credits to Arter97
log_info "Checking if your kernel has MGLRU support..."
if [ -d "$MGLRU_PATH" ]; then
    log_info "MGLRU support found."
    log_info "Tweaking MGLRU settings..."
    write_value "$MGLRU_PATH/min_ttl_ms" 5000
    log_info "Done."
else
    log_info "MGLRU support not found."
    log_info "Aborting MGLRU tweaks..."
fi

# Set kernel.perf_cpu_time_max_percent to 10
log_info "Setting perf_cpu_time_max_percent..."
write_value "$KERNEL_PATH/perf_cpu_time_max_percent" 10
log_info "Done."

# Disable certain scheduler logs/stats
# Also iostats & reduce latency
# Credits to tytydraco
log_info "Disabling some scheduler logs/stats..."
if [ -e "$KERNEL_PATH/sched_schedstats" ]; then
    write_value "$KERNEL_PATH/sched_schedstats" 0
fi
write_value "$KERNEL_PATH/printk" "0        0 0 0"
write_value "$KERNEL_PATH/printk_devkmsg" "off"
for queue in /sys/block/*/queue; do
    write_value "$queue/iostats" 0
done
log_info "Done."

# Disable Timer migration
log_info "Disabling Timer Migration..."
write_value "$KERNEL_PATH/timer_migration" 0
log_info "Done."

# Cgroup tweak for UCLAMP scheduler
if [ -e "$UCLAMP_PATH" ]; then
    # Uclamp tweaks
    # Credits to @darkhz
    log_info "UCLAMP scheduler detected, applying tweaks..."
    top_app="${CPUSET_PATH}/top-app"
    write_value "$top_app/uclamp.max" max
    write_value "$top_app/uclamp.min" 10
    write_value "$top_app/uclamp.boosted" 1
    write_value "$top_app/uclamp.latency_sensitive" 1
    log_info "Top app scheduler tweaks set"
	foreground="${CPUSET_PATH}/foreground"
    write_value "$foreground/uclamp.max" 50
    write_value "$foreground/uclamp.min" 0
    write_value "$foreground/uclamp.boosted" 0
    write_value "$foreground/uclamp.latency_sensitive" 0
    log_info "Foreground apps scheduler tweaks set"
    background="${CPUSET_PATH}/background"
    write_value "$background/uclamp.max" max
    write_value "$background/uclamp.min" 20
    write_value "$background/uclamp.boosted" 0
    write_value "$background/uclamp.latency_sensitive" 0
    log_info "Background apps scheduler tweaks set"
    sys_bg="${CPUSET_PATH}/system-background"
    write_value "$sys_bg/uclamp.min" 0
    write_value "$sys_bg/uclamp.max" 40
    write_value "$sys_bg/uclamp.boosted" 0
    write_value "$sys_bg/uclamp.latency_sensitive" 0
    sysctl -w kernel.sched_util_clamp_min_rt_default=0
    sysctl -w kernel.sched_util_clamp_min=128
    log_info "System apps scheduler tweaks set"
    log_info "Done."
fi

# Disable SPI CRC if supported
if [ -d "$MODULE_PATH/mmc_core" ]; then
    log_info "Disabling SPI CRC..."
    write_value "$MODULE_PATH/mmc_core/parameters/use_spi_crc" 0
    log_info "Done."
fi

# Disable TCP timestamps for reduced overhead
log_info "Disabling TCP timestamps..."
write_value "$IPV4_PATH/tcp_timestamps" 0
log_info "Done."

# Enable TCP low latency mode
log_info "Enabling TCP low latency mode..."
write_value "$IPV4_PATH/tcp_low_latency" 1
log_info "Done."

# Proceed with Firmware debloating
# pm disable-user --user 0 <package_name>
log_info "Disabling unnecessary applications..."
pm disable-user --user 0 "com.alex.debugtool_player"
pm disable-user --user 0 "com.android.carrierconfig"
pm disable-user --user 0 "com.android.carrierconfig.overlay.common"
pm disable-user --user 0 "com.android.cellbroadcastreceiver.module"
pm disable-user --user 0 "com.android.cellbroadcastreceiver.overlay.common"
pm disable-user --user 0 "com.android.cellbroadcastservice"
pm disable-user --user 0 "com.android.companiondevicemanager"
pm disable-user --user 0 "com.android.cts.ctsshim"
pm disable-user --user 0 "com.android.cts.priv.ctsshim"
pm disable-user --user 0 "com.android.dreams.basic"
pm disable-user --user 0 "com.android.inputmethod.latin"
pm disable-user --user 0 "com.android.internal.display.cutout.emulation.corner"
pm disable-user --user 0 "com.android.internal.display.cutout.emulation.double"
pm disable-user --user 0 "com.android.internal.display.cutout.emulation.hole"
pm disable-user --user 0 "com.android.internal.display.cutout.emulation.tall"
pm disable-user --user 0 "com.android.internal.display.cutout.emulation.waterfall"
pm disable-user --user 0 "com.android.internal.systemui.navbar.twobutton"
pm disable-user --user 0 "com.android.managedprovisioning"
pm disable-user --user 0 "com.android.providers.blockednumber"
pm disable-user --user 0 "com.android.traceur"
pm disable-user --user 0 "com.example.fiiotestappliction"
pm disable-user --user 0 "com.fiio.market"
pm disable-user --user 0 "com.google.android.syncadapters.calendar"
pm disable-user --user 0 "com.google.android.syncadapters.contacts"
pm disable-user --user 0 "com.kk.xx.analyzer"
pm disable-user --user 0 "com.nextdoordeveloper.miperf.miperf"
pm disable-user --user 0 "com.opda.checkoutdevice"
pm disable-user --user 0 "com.qti.qualcomm.mstatssystemservice"
pm disable-user --user 0 "com.qualcomm.qti.devicestatisticsservice"
pm disable-user --user 0 "com.qualcomm.qti.xrcb"
pm disable-user --user 0 "com.qualcomm.qti.xrvd.service"
pm disable-user --user 0 "hcfactory.test"
pm disable-user --user 0 "vendor.qti.qesdk.sysservice"
pm disable-user --user 0 "com.android.server.telecom.overlay.common"
pm disable-user --user 0 "com.android.smspush"
pm disable-user --user 0 "vendor.qti.hardware.cacert.server"
log_info "Done."

# Proceed with forcing secondary apps into the background
# am force-stop <package_name>
log_info "Stopping secondary applications..."
am force-stop com.android.aboutfiio
am force-stop com.fiio.devicevendor
am force-stop com.fiio.entersleep
am force-stop com.fiio.market
am force-stop com.fiio.scrcpy
am force-stop com.fiio.tape
log_info "Done."

# Force background operation on secondary applications
# cmd appops set <package_name> RUN_ANY_IN_BACKGROUND ignore
log_info "Setting background process permisssions..."
cmd appops set android RUN_ANY_IN_BACKGROUND ignore
cmd appops set android.ext.services RUN_ANY_IN_BACKGROUND ignore
cmd appops set android.ext.shared RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.amazon.mp3 RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.certinstaller RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.chrome RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.connectivity.resources RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.documentsui RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.internal.systemui.navbar.threebutton RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.keychain RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.launcher3 RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.localtransport RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.location.fused RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.modulemetadata RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.networkstack RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.networkstack.tethering RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.pacprocessor RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.permissioncontroller RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.remoteprovisioner RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.sdksandbox RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.systemui RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.systemui RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.vending RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.android.wifi.resources RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.fiio.devicevendor RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.fiio.entersleep RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.fiio.fiioeq RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.fiio.scrcpy RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.fiio.tape RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.google.android.ext.shared RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.google.android.gms RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.google.android.gsf RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.google.android.gsf RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.google.android.packageinstaller RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.google.android.webview RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.qti.pasrservice RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.qti.snapdragon.qdcm_ff RUN_ANY_IN_BACKGROUND ignore
cmd appops set com.qualcomm.qti.workloadclassifier RUN_ANY_IN_BACKGROUND ignore
log_info "Done."

# Set Music Apps to use unrestricted mode when DAP on Battery power
# dumpsys deviceidle whitelist +<package_name>
log_info "Whitelisting common music applications..."
dumpsys deviceidle whitelist +com.amazon.mp3
dumpsys deviceidle whitelist +com.android.fiio.scrcpy
dumpsys deviceidle whitelist +com.android.fiioroon
dumpsys deviceidle whitelist +com.android.fiioupdate
dumpsys deviceidle whitelist +com.apple.android.music
dumpsys deviceidle whitelist +com.apple.android.music.classical
dumpsys deviceidle whitelist +com.aspiro.tidal
dumpsys deviceidle whitelist +com.bandcamp.android
dumpsys deviceidle whitelist +com.cca.app_noble
dumpsys deviceidle whitelist +com.extreamsd.usbaudioplayerpro
dumpsys deviceidle whitelist +com.fiio.android
dumpsys deviceidle whitelist +com.fiio.entersleep
dumpsys deviceidle whitelist +com.fiio.fiioeq
dumpsys deviceidle whitelist +com.fiio.music
dumpsys deviceidle whitelist +com.fiio.scrcpy
dumpsys deviceidle whitelist +com.fiio.tape
dumpsys deviceidle whitelist +com.foobar2000.foobar2000
dumpsys deviceidle whitelist +com.google.android.apps.youtube.music
dumpsys deviceidle whitelist +com.google.android.youtube
dumpsys deviceidle whitelist +com.hiby.music
dumpsys deviceidle whitelist +com.hiby.music.n6
dumpsys deviceidle whitelist +com.hiby.roon.cayin
dumpsys deviceidle whitelist +com.neutroncode.mp
dumpsys deviceidle whitelist +com.pandora.android
dumpsys deviceidle whitelist +com.qobuz.music
dumpsys deviceidle whitelist +com.roon.mobile
dumpsys deviceidle whitelist +com.roon.onthego
dumpsys deviceidle whitelist +com.soundcloud.android
dumpsys deviceidle whitelist +com.spotify.music
dumpsys deviceidle whitelist +com.topjohnwu.magisk
log_info "Done."

# System application Optimizations
# Log each setting
log_info "Applying SYSTEM Optimizations..."
settings put global accessibility_reduce_transparency 1
log_info "Transparency reduction set"
settings put global activity_starts_logging_enabled 0
log_info "Activity logging disabled"
settings put global disable_window_blurs 1
resetprop -n persist.sys.background_blur_supported false
log_info "Android window blur disabled"
settings put global animator_duration_scale 0
settings put global transition_animation_scale 0
settings put global window_animation_scale 0
log_info "Android system animations disabled"
settings put secure send_action_app_error 0
settings put system send_security_reports 0
log_info "Android system reporting disabled"
log_info "All optimizations completed."


# And -- We're done!
su -lp 2000 -c "cmd notification post -S bigtext -t 'FiiO Android Tweaker' 'Tag' 'FiiO Android Tweaker $RELEASE successfully installed.'">/dev/null 2>&1
log_info "FiiO Android Tweaker $RELEASE successfully installed."
