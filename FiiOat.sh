#!/system/bin/sh
# FIIOAT v17_r38
# Author: @WheresWaldo (Github)
# ×××××××××××××××××××××××××× #

# We need to wait until the system is completely booted
until [ "$(getprop sys.boot_completed)" = 1 ]
   do
   sleep 1
   done
sleep 3

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

# Function to write a value to a specified file
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

MODDIR=${0%/*} # Get parent directory

# Modify the filenames for logs
INFO_LOG="${MODDIR}/info.log"
ERROR_LOG="${MODDIR}/error.log"

# Prepare log files
:> "$INFO_LOG"
:> "$ERROR_LOG"

# Variables
ANDROID_VERSION=$(getprop ro.build.version.release)
FIIO_MODEL=$(getprop ro.product.model)
APP_PATH="/system/app"
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
ZRAM_PATH="/dev/zram0"
FIRMWARE_VERSION=$(getprop ro.build.display.id)

# Cache installed package list for quicker lookups on 1.0.8 where system apps shifted
INSTALLED_PACKAGES="$(pm list packages 2>/dev/null)"
log_info "Paquetes detectados para debloat/control: $(echo "$INSTALLED_PACKAGES" | wc -l)"

# Function to check if a package exists
package_exists() {
    echo "$INSTALLED_PACKAGES" | grep -q "^package:$1$"
}

# Function to disable a package if it exists
disable_pkg() {
    local pkg="$1"
    if package_exists "$pkg"; then
        pm disable-user --user 0 "$pkg" 2>/dev/null && log_info "Disabled: $pkg" || log_error "Failed to disable: $pkg"
    else
        log_info "Skipping disable for $pkg (not installed)"
    fi
}

# Function to force stop a package if it exists
force_stop_pkg() {
    local pkg="$1"
    if package_exists "$pkg"; then
        am force-stop "$pkg" 2>/dev/null && log_info "Force-stopped: $pkg" || log_error "Failed to force-stop: $pkg"
    else
        log_info "Skipping force-stop for $pkg (not installed)"
    fi
}

# Function to set appops background permission if package exists
set_appops_background() {
    local pkg="$1"
    if package_exists "$pkg"; then
        cmd appops set "$pkg" RUN_ANY_IN_BACKGROUND ignore 2>/dev/null && log_info "Set appops background for: $pkg" || log_error "Failed to set appops for: $pkg"
    else
        log_info "Skipping appops for $pkg (not installed)"
    fi
}

# Function to whitelist a package if it exists
whitelist_pkg() {
    local pkg="$1"
    if package_exists "$pkg"; then
        dumpsys deviceidle whitelist +"$pkg" 2>/dev/null && log_info "Whitelisted: $pkg" || log_error "Failed to whitelist: $pkg"
    else
        log_info "Skipping whitelist for $pkg (not installed)"
    fi
}

# Log starting information
log_info "Starting FiiOat v17_r38"
log_info "Build Date: 02/07/2025"
log_info "Author: @WheresWaldo (Github/Head-Fi)"
log_info "Device: $(getprop ro.product.system.model)"
log_info "Brand: $(getprop ro.product.system.brand)"
log_info "Kernel: $(uname -r)"
log_info "ROM Build Type: $(getprop ro.system.build.type)"
log_info "Android Version: $ANDROID_VERSION"
log_info "Firmware Version: $FIRMWARE_VERSION"

if echo "$FIRMWARE_VERSION" | grep -q "1\.0\.8"; then
    log_info "FiiO firmware 1.0.8 detected; applying tuned tweaks."
else
    log_info "Non-1.0.8 firmware detected; continuing with best-effort tweaks."
fi

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

# Here is the section ripped from SWAP_TORPEDO
# I would like to refactor this so that the variables match the
# rest of the script
alias SWAPT='grep -i SwapTotal /proc/meminfo | tr -d [:alpha:]:" "'
TL=60
Step=3
k=0
while [ $(SWAPT) -eq 0  ]
do
    k=$(( $k + $Step ))
    if [ $k -gt $TL  ] ; then
        exit 0
    fi
    sleep $Step
done
SR="\/dev\/"
PS="/proc/swap*"
if [ -f /system/bin/swapoff ] ; then
    SO="/system/bin/swapoff"
else
    SO="swapoff"
fi
DIE=$(awk -v SBD="$SR" ' $0 ~ SBD {
      for ( i=1;i<=NF;i++ )
        {
          if ( $i ~ ( "^" SBD ) )
           {
              printf "%s;", $i
              break
           }
        }
      }' $PS)
saveifs=$IFS
IFS=';'
for i in $DIE
do
    case $i in
        *zram*)
              j=$(echo $i | sed 's/.*zram//')
              ( ( 
                 echo $j > /sys/class/zram-control/hot_remove
                 echo 1 > /sys/block/zram${j}/reset
                 $SO $i
              ) & )
              ;;
        *)
              if [ -n $i ]; then
                  ( ( $SO $i ) & ) 
              fi
              ;;
    esac
done
IFS=$saveifs

# Apply RAM tweaks
# The stat_interval reduces jitter (Credits to kdrag0n)
# Credits to RedHat for dirty_ratio
log_info "Applying RAM Tweaks..."
write_value "$MEMORY_PATH/vfs_cache_pressure" 50
write_value "$MEMORY_PATH/stat_interval" 30
write_value "$MEMORY_PATH/compaction_proactiveness" 0
write_value "$MEMORY_PATH/page-cluster" 0
log_info "Applying appropriate tweaks..."
write_value "$MEMORY_PATH/swappiness" 60
write_value "$MEMORY_PATH/dirty_ratio" 60
log_info "Done."

# Mglru tweaks
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
log_info "Setting perf_cpu_time_max_percent to 10"
write_value "$KERNEL_PATH/perf_cpu_time_max_percent" 10
log_info "Done."

# Disable certain scheduler logs/stats
# Also iostats & reduce latency
# Credits to tytydraco
log_info "Disabling some scheduler logs/stats"
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
log_info "Disabling Timer Migration"
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
    foreground="${CPUSET_PATH}/foreground"
    write_value "$foreground/uclamp.max" 50
    write_value "$foreground/uclamp.min" 0
    write_value "$foreground/uclamp.boosted" 0
    write_value "$foreground/uclamp.latency_sensitive" 0
    background="${CPUSET_PATH}/background"
    write_value "$background/uclamp.max" max
    write_value "$background/uclamp.min" 20
    write_value "$background/uclamp.boosted" 0
    write_value "$background/uclamp.latency_sensitive" 0
    sys_bg="${CPUSET_PATH}/system-background"
    write_value "$sys_bg/uclamp.min" 0
    write_value "$sys_bg/uclamp.max" 40
    write_value "$sys_bg/uclamp.boosted" 0
    write_value "$sys_bg/uclamp.latency_sensitive" 0
    sysctl -w kernel.sched_util_clamp_min_rt_default=0
    sysctl -w kernel.sched_util_clamp_min=128
    log_info "Done."
fi

# Disable SPI CRC if supported
if [ -d "$MODULE_PATH/mmc_core" ]; then
    log_info "Disabling SPI CRC"
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
log_info "Disabling unnecessary applications..."
disable_pkg "com.alex.debugtool_player"
disable_pkg "com.android.carrierconfig"
disable_pkg "com.android.carrierconfig.overlay.common"
disable_pkg "com.android.cellbroadcastreceiver.module"
disable_pkg "com.android.cellbroadcastreceiver.overlay.common"
disable_pkg "com.android.cellbroadcastservice"
disable_pkg "com.android.companiondevicemanager"
disable_pkg "com.android.cts.ctsshim"
disable_pkg "com.android.cts.priv.ctsshim"
disable_pkg "com.android.dreams.basic"
disable_pkg "com.android.inputmethod.latin"
disable_pkg "com.android.internal.display.cutout.emulation.corner"
disable_pkg "com.android.internal.display.cutout.emulation.double"
disable_pkg "com.android.internal.display.cutout.emulation.hole"
disable_pkg "com.android.internal.display.cutout.emulation.tall"
disable_pkg "com.android.internal.display.cutout.emulation.waterfall"
disable_pkg "com.android.internal.systemui.navbar.twobutton"
disable_pkg "com.android.managedprovisioning"
disable_pkg "com.android.providers.blockednumber"
disable_pkg "com.android.traceur"
disable_pkg "com.example.fiiotestappliction"
disable_pkg "com.fiio.market"
disable_pkg "com.google.android.apps.nbu.files"
disable_pkg "com.google.android.syncadapters.calendar"
disable_pkg "com.google.android.syncadapters.contacts"
disable_pkg "com.kk.xx.analyzer"
disable_pkg "com.nextdoordeveloper.miperf.miperf"
disable_pkg "com.opda.checkoutdevice"
disable_pkg "com.qti.qualcomm.mstatssystemservice"
disable_pkg "com.qualcomm.qti.devicestatisticsservice"
disable_pkg "com.qualcomm.qti.xrcb"
disable_pkg "com.qualcomm.qti.xrvd.service"
disable_pkg "hcfactory.test"
disable_pkg "vendor.qti.qesdk.sysservice"
disable_pkg "com.android.server.telecom.overlay.common"
disable_pkg "com.android.smspush"
disable_pkg "vendor.qti.hardware.cacert.server"
log_info "Done."

# Proceed with forcing secondary apps into the background
log_info "Stopping secondary applications..."
force_stop_pkg "com.android.aboutfiio"
force_stop_pkg "com.fiio.devicevendor"
force_stop_pkg "com.fiio.entersleep"
force_stop_pkg "com.fiio.market"
force_stop_pkg "com.fiio.scrcpy"
force_stop_pkg "com.fiio.tape"
log_info "Done."

# Force background operation on secondary applications
log_info "Setting run in background permissions..."
set_appops_background "android"
set_appops_background "android.ext.services"
set_appops_background "android.ext.shared"
set_appops_background "com.amazon.mp3"
set_appops_background "com.android.certinstaller"
set_appops_background "com.android.chrome"
set_appops_background "com.android.connectivity.resources"
set_appops_background "com.android.documentsui"
set_appops_background "com.android.internal.systemui.navbar.threebutton"
set_appops_background "com.android.keychain"
set_appops_background "com.android.launcher3"
set_appops_background "com.android.localtransport"
set_appops_background "com.android.location.fused"
set_appops_background "com.android.modulemetadata"
set_appops_background "com.android.networkstack"
set_appops_background "com.android.networkstack.tethering"
set_appops_background "com.android.pacprocessor"
set_appops_background "com.android.permissioncontroller"
set_appops_background "com.android.remoteprovisioner"
set_appops_background "com.android.sdksandbox"
set_appops_background "com.android.systemui"
set_appops_background "com.android.vending"
set_appops_background "com.android.wifi.resources"
set_appops_background "com.fiio.devicevendor"
set_appops_background "com.fiio.entersleep"
set_appops_background "com.fiio.fiioeq"
set_appops_background "com.fiio.scrcpy"
set_appops_background "com.fiio.tape"
set_appops_background "com.google.android.ext.shared"
set_appops_background "com.google.android.gms"
set_appops_background "com.google.android.gsf"
set_appops_background "com.google.android.packageinstaller"
set_appops_background "com.google.android.webview"
set_appops_background "com.qti.pasrservice"
set_appops_background "com.qti.snapdragon.qdcm_ff"
set_appops_background "com.qualcomm.qti.workloadclassifier"
log_info "Done."

# Set Music Apps to use unrestricted mode when DAP on Battery power
log_info "Whitelisting music applications for unrestricted battery mode..."
whitelist_pkg "com.amazon.mp3"
whitelist_pkg "com.android.fiio.scrcpy"
whitelist_pkg "com.android.fiioroon"
whitelist_pkg "com.android.fiioupdate"
whitelist_pkg "com.apple.android.music"
whitelist_pkg "com.apple.android.music.classical"
whitelist_pkg "com.aspiro.tidal"
whitelist_pkg "com.bandcamp.android"
whitelist_pkg "com.cca.app_noble"
whitelist_pkg "com.extreamsd.usbaudioplayerpro"
whitelist_pkg "com.fiio.android"
whitelist_pkg "com.fiio.entersleep"
whitelist_pkg "com.fiio.fiioeq"
whitelist_pkg "com.fiio.music"
whitelist_pkg "com.fiio.scrcpy"
whitelist_pkg "com.fiio.tape"
whitelist_pkg "com.foobar2000.foobar2000"
whitelist_pkg "com.google.android.apps.youtube.music"
whitelist_pkg "com.google.android.youtube"
whitelist_pkg "com.hiby.music"
whitelist_pkg "com.hiby.music.n6"
whitelist_pkg "com.hiby.roon.cayin"
whitelist_pkg "com.neutroncode.mp"
whitelist_pkg "com.pandora.android"
whitelist_pkg "com.qobuz.music"
whitelist_pkg "com.roon.mobile"
whitelist_pkg "com.roon.onthego"
whitelist_pkg "com.soundcloud.android"
whitelist_pkg "com.spotify.music"
whitelist_pkg "com.topjohnwu.magisk"
log_info "Done."

# System application Optimizations
log_info "Applying SYSTEM Optimizations..."
settings put global accessibility_reduce_transparency 1
settings put global activity_starts_logging_enabled 0
settings put global disable_window_blurs 1
settings put global animator_duration_scale 0
settings put global transition_animation_scale 0
settings put global window_animation_scale 0
settings put secure send_action_app_error 0
settings put system send_security_reports 0
resetprop -n persist.sys.background_blur_supported false
log_info "Done."

# And -- We're done!
log_info "All optimizations completed."
su -lp 2000 -c "cmd notification post -S bigtext -t 'FiiO Android Tweaker' 'Tag' 'Born for Music! FiiO Android Tweaker successfully installed.'" >/dev/null 2>&1