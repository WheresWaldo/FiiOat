# FiiOat v17_r38 - Release Notes

## 🎉 Stable Release - Tested and Working

**Release Date**: 2025-02-07  
**Version**: v17_r38  
**Status**: ✅ **STABLE AND TESTED**

---

## 📋 Summary

This version includes significant improvements for firmware 1.0.8 compatibility and better system package handling. **Successfully tested on FiiO JM21**.

## ✨ New Features

### Firmware 1.0.8 Support
- Automatic firmware 1.0.8 detection
- Optimized specific tweaks for this version
- Backward compatibility with previous versions

### Improved Helper Functions
- **Package Verification**: Prevents errors when packages don't exist
- **Package Cache**: Better performance on firmware 1.0.8
- **Detailed Logging**: Clear information about what is processed and what is skipped

### Code Improvements
- Reusable functions for better maintainability
- Better error handling
- Cleaner and more organized code
- Typo fixes

## 🔧 Technical Changes

### Applied Optimizations
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

### New Functions
- `package_exists()` - Checks if a package is installed
- `disable_pkg()` - Disables packages only if they exist
- `force_stop_pkg()` - Stops packages only if they exist
- `set_appops_background()` - Sets permissions only if package exists
- `whitelist_pkg()` - Adds to whitelist only if package exists

## 🐛 Fixes

- Fixed typo: "frrequency" → "frequency"
- Fixed typo: "permisssions" → "permissions"
- Fixed typo: "spotfy" → "spotify"
- Removed duplicate wait for `sys.boot_completed`

## 📊 Test Results

**Test Device**: FiiO JM21  
**Firmware**: TKQ1.230110.001 (Android 13)  
**Kernel**: 5.15.41-android13-8-gdfab679e3463-dirty

### Results:
- ✅ **Execution**: Complete without errors
- ✅ **Error Log**: Empty (no errors)
- ✅ **Optimizations**: All applied correctly
- ✅ **Processed Packages**: 146 detected, 30+ disabled
- ✅ **Compatibility**: Works on non-1.0.8 firmware as well

## 📦 Installation

### Quick Method:
1. Download `FiiOat-v17_r38-main.zip` from this release
2. Open Magisk Manager
3. Go to Modules → Install from storage
4. Select the downloaded ZIP
5. Reboot device

### From Source Code:
```bash
git clone https://github.com/kuiporro/FiiOat.git
cd FiiOat
git checkout v17_r38
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

- **Original Author**: @WheresWaldo (Github/Head-Fi)
- **Based on**: YAKT by NotZeetea
- **Contributions**: MattClark18 and other Head-Fi.org members

## 📝 Full Changelog

### v17_r38 (2025-02-07)
- ✅ Updated to v17_r38
- ✅ Firmware 1.0.8 support
- ✅ Helper functions for package verification
- ✅ Installed packages list cache
- ✅ Logging improvements
- ✅ Typo fixes
- ✅ Duplicate code removal
- ✅ Automated build script

### Compared to v17_r37:
- Better compatibility with different firmware versions
- Fewer errors when packages don't exist
- More detailed and useful logging
- More maintainable code

---

**Thank you for using FiiOat!** 🎵

To report issues or suggestions, open an Issue at: https://github.com/kuiporro/FiiOat/issues
