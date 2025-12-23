# FiiOat v17_r41 - Release Notes

## 🎉 Stable Release - Tested and Working

**Release Date**: 12-23-2025  
**Version**: v17_r41  
# **Status**: ✅ **STABLE AND TESTED**

---

## 📋 Summary

This version includes improvements for future firmware compatibility and better system package handling.
Tested as new install and overwriting existing pervious install on JM21 v1.1.0 and M21 v1.0.7.

## ✨ New Features

### New firmware support
- Automatic firmware detection
- Current firmware version logged 
- Backward compatibility with previous versions

### Improved Helper Functions
- **Detailed Logging**: Clear information about what is processed and what is skipped

### Code Improvements
- Reusable functions for better maintainability
- Better error handling
- Cleaner and more organized code
- Typo fixes

## 🔧 Technical Changes

### Applied Optimizations (all versions)
- ✅ CPU Schedutil Rate-Limits
- ✅ Minimum CPU Frequencies (E-core and P-core at 300MHz)
- ✅ Child Runs First (CRF)
- ✅ Memory Management (RAM Tweaks)
- ✅ MGLRU Tweaks (if available)
- ✅ UCLAMP Scheduler Tweaks
- ✅ ZRAM/ZSWAP Disabling
- ✅ Network Optimizations (TCP)
- ✅ Unnecessary Apps Debloating
- ✅ Background Apps Control
- ✅ Music Apps Whitelist
- ✅ Wavelet Enhanced session detection support

### New Functions
- `package_exists()` - Checks if a package is installed
- `disable_pkg()` - Disables packages only if they exist
- `force_stop_pkg()` - Stops packages only if they exist
- `set_appops_background()` - Sets permissions only if package exists
- `whitelist_pkg()` - Adds to whitelist only if package exists

## 🐛 Fixes

- Fixed various typos
- Moved wait for `sys.boot_completed` to service.sh

## 📊 Test Environment #1

**Test Device**: FiiO JM21  
**Android Verion**: TKQ1.230110.001 (Android 13)
**Firmware**: 1.1.0  
**Kernel**: 5.15.41-android13-8-gd319db77ec17-dirty

### Results Environment #1
- ✅ **Execution**: #Complete without errors
- ✅ **Error Log**: #Empty (no errors)
- ✅ **Optimizations**: #All applied correctly
- ✅ **Processed Packages**: #142 detected, 31 disabled

## 📊 Test Environment #2

**Test Device**: FiiO M21  
**Android Verion**: TKQ1.230110.001 (Android 13)
**Firmware**: 1.0.7  
**Kernel**: 5.15.41-android13-8-gd319db77ec17-dirty

### Results Environment #2
- ✅ **Execution**: #Complete without errors
- ✅ **Error Log**: #Empty (no errors)
- ✅ **Optimizations**: #All applied correctly
- ✅ **Processed Packages**: #146 detected, 31 disabled

## 📦 Installation

### Quick Method:
1. Download `FiiOat_v17_r41.zip` from this release
2. Open Magisk Manager
3. Go to Modules → Install from storage
4. Select the downloaded ZIP
5. Reboot device when prompted

### From Source Code:
```bash
git clone https://github.com/WheresWaldo/FiiOat.git
cd FiiOat
git checkout release
chmod +x build_module.sh
./build_module.sh
```

## 📚 Documentation

- **Installation Guide**: [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)

## 🔍 Verification

After installing, check the logs:

```bash
adb shell
su
cat /data/adb/modules/fiioat/info.log
cat /data/adb/modules/fiioat/error.log
```

You should see "All optimizations completed" in `info.log` and no errors in `error.log`.

## ⚠️ Important Notes

- This module is specifically designed for FiiO JM21 and M21
- Compatible with Android 13
- Requires Magisk v20.4 or higher
- Changes are systemless (can be reverted by uninstalling)
- **Does NOT modify sound directly**, only optimizes the system

## 🙏 Credits

- **Original Author**: @WheresWaldo (GitHub/Head-Fi)
- **Based on**: YAKT by NotZeetea
- **Contributions**: MattClark18 and other Head-Fi.org members
- **Additional code**: kuiporro (GitHub)

## 📝 Full Changelog

### v17_r41 (2025-12-23)
- Added support for Wavelet. (Please note that Wavelet AutoEQ and headphone
  detection does not function as intended. Neither FiiO nor FiiO Android Tweaker
  can resolve these specific issues with Wavelet app.) 

### Compared to v17_r37:
- Better compatibility with all firmware versions
- Fewer errors when packages don't exist
- More detailed and useful logging
- More maintainable code

---

**Thank you for using FiiOat!** 🎵

To report issues or suggestions, open an Issue at: https://github.com/WheresWaldo/FiiOat/issues