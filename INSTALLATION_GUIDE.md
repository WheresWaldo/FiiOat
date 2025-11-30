# Installation and Testing Guide - FiiOat_v17_r40

## ⚠️ IMPORTANT: Stable Version

This version (v17_r40) has been **tested and is stable**. Ready for production use.

## Prerequisites

- FiiO JM21 with firmware 1.0.8 or M21 (or previous version for compatibility)
- Magisk v20.4 or higher installed
- Working root access
- Internet connection to download the module

## Step 1: Download the Module

### Option A: Download from GitHub (Recommended)

1. Go to: https://github.com/WheresWaldo/FiiOat/releases
2. Download the latest release: `FiiOat_v17_r40.zip`

### Option B: Clone the Repository (For Developers)

```bash
git clone https://github.com/WheresWaldo/FiiOat.git
cd FiiOat
git checkout v17_r40
```

## Step 2: Prepare the Module for Installation

### Option A: Use the Build Script (Recommended)

If you cloned the repository or have access to the source files:

1. Open a terminal in the module folder
2. Run the build script:
   ```bash
   chmod +x build_module.sh
   ./build_module.sh
   ```
3. The script will automatically create the ZIP with the correct name: `FiiOat_v17_r40.zip`

### Option B: Create ZIP Manually

If you downloaded the source code and need to create the ZIP manually:

1. Open a terminal in the module folder
2. Use `zip`, `7z` or `python3`:

   **With zip:**
   ```bash
   zip -r FiiOat_v17_r40.zip META-INF/ FiiOat.sh service.sh module.prop customize.sh
   ```

   **With 7z:**
   ```bash
   7z a -tzip FiiOat_v17_r40.zip META-INF/ FiiOat.sh service.sh module.prop customize.sh
   ```

   **With Python3:**
   ```python
   import zipfile
   import os
   
   with zipfile.ZipFile('FiiOat_v17_r40.zip', 'w') as zipf:
       for root, dirs, files in os.walk('META-INF'):
           for file in files:
               zipf.write(os.path.join(root, file))
       for file in ['FiiOat.sh', 'service.sh', 'module.prop', 'customize.sh']:
           if os.path.exists(file):
               zipf.write(file)
   ```

### ZIP Structure (for reference):

```
FiiOat.zip
├── META-INF/
│   └── com/
│       └── google/
│           └── android/
│               ├── update-binary
│               └── updater-script
├── FiiOat.sh
├── service.sh
├── module.prop
└── customize.sh
```

## Step 3: Transfer Module to Device

1. Connect your FiiO JM21/M21 to the computer via USB
2. Transfer the `FiiOat_v17_r40.zip` file to the device's internal storage
3. Or transfer via ADB:
   ```bash
   adb push FiiOat_v17_r40.zip /sdcard/Download/
   ```

## Step 4: Install Module in Magisk

### Method 1: From Magisk App (Recommended)

1. Open the **Magisk** app on your device
2. Go to the **"Modules"** tab
3. Tap **"Install from storage"** button
4. Navigate to where you saved the ZIP (usually `/sdcard/Download/`)
5. Select `FiiOat_v17_r40.zip`
6. Tap **"Install"**
7. Wait for installation to complete
8. **IMPORTANT**: Tap **"Reboot"** to apply changes

### Method 2: From ADB (For Advanced Users)

```bash
# Connect device via ADB
adb shell

# Elevate to root
su

# Install module
magisk --install-module /sdcard/Download/FiiOat_v17_r40.zip

# Reboot
reboot
```

## Step 5: Verify Installation

### After Reboot:

1. Open the **Magisk** app
2. Go to **"Modules"**
3. Verify that **"FiiO Android Tweaker"** appears in the list and is enabled
4. You should see version `v17_r40`

### Check Logs:

1. Connect device via ADB or use a root file explorer
2. Navigate to: `/data/adb/modules/fiioat/`
3. Check files:
   - `info.log` - Informative logs
   - `error.log` - Errors (if any)

#### View logs from ADB:

```bash
adb shell
su
cat /data/adb/modules/fiioat/info.log
cat /data/adb/modules/fiioat/error.log
```

## Step 6: Test the Module

### Basic Tests:

1. **Play Music**:
   - Open your favorite music app
   - Play a song
   - Verify there are no cuts or audio issues

2. **Check Performance**:
   - Open several apps
   - Verify the system responds well
   - There should be no excessive lag

3. **Verify Disabled Apps**:
   ```bash
   adb shell
   su
   pm list packages -d | grep -i fiio
   ```
   This will show disabled packages related to FiiO

4. **Verify CPU Optimizations**:
   ```bash
   adb shell
   su
   cat /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
   cat /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
   ```
   Should show `300000` (300 MHz)

5. **Verify ZRAM is disabled**:
   ```bash
   adb shell
   su
   cat /proc/swaps
   ```
   Should not show zram devices

### Advanced Tests:

1. **Verify UCLAMP Settings**:
   ```bash
   adb shell
   su
   cat /dev/cpuset/top-app/uclamp.max
   cat /dev/cpuset/top-app/uclamp.min
   ```

2. **Verify Firmware Detection**:
   ```bash
   adb shell
   su
   grep "1.0.8" /data/adb/modules/fiioat/info.log
   ```

## Step 7: Report Results

### If Module Works Correctly:

1. Verify there are no critical errors in `error.log`
2. Verify all optimizations were applied (check `info.log`)
3. Test music playback for at least 30 minutes
4. Verify system is stable

### If You Find Problems:

1. **Capture complete logs**:
   ```bash
   adb pull /data/adb/modules/fiioat/info.log
   adb pull /data/adb/modules/fiioat/error.log
   ```

2. **Document the problem**:
   - What were you doing when it occurred?
   - What specific error did you see?
   - Did the device reboot?
   - Are there apps that don't work?

3. **Create an Issue on GitHub** with:
   - Firmware version
   - Device model (JM21 or M21)
   - Complete logs
   - Detailed problem description

## Step 8: Uninstall (If Necessary)

### To uninstall the module:

1. Open **Magisk**
2. Go to **"Modules"**
3. Tap on **"FiiO Android Tweaker"**
4. Tap **"Uninstall"**
5. Reboot device

### Or from ADB:

```bash
adb shell
su
rm -rf /data/adb/modules/fiioat
reboot
```

## Testing Checklist

Before reporting that it works, verify:

- [ ] Module appears in Magisk as installed
- [ ] No critical errors in `error.log`
- [ ] `info.log` shows "All optimizations completed"
- [ ] Music plays without problems
- [ ] System is stable (does not reboot)
- [ ] Apps work normally
- [ ] Firmware 1.0.8 detection works (if applicable)
- [ ] Packages are disabled correctly
- [ ] CPU optimizations are applied

## Support

- **GitHub Issues**: https://github.com/WheresWaldo/FiiOat/issues
- **Version**: v17_r40 (Stable)

---

**Thank you for using FiiOat!** Your feedback is essential to improve the module.

