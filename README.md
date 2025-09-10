# FiiOat
** FiiO Andriod Tweaker **. 
A Magisk module to Tweak Kernel parameters, zswap size, and minimal debloater. This module applies at boot.

Since you have found this page you should already have a fundamental knowledge of how Magisk modules work. Other than a version of Magisk newer that v20.4 and a rooted FiiO device there are no other prerequisites. Since this module is a tweak and debloat combination, it is suggested that you do not run any other kernel tweak modules or debloating modules for Android at the same time.

This module is a highly modified version of YAKT by NotZeetea(@github.com) [https://github.com/NotZeetaa/YAKT]. It is not a fork, but rather a standalone 'inspired by' port specifically to support FiiO Android DAPs and there idiosyncratic implementation of Android.
Parts of this module have been sourced from other shell scripts, work done by MattClark18 (@Head-Fi.org) and others.

While this module is specifically designed for the FiiO M21/JM21 DAP it may work on other devices. Note that all the changes made by this module are available in the FiiO kernel (Android 13 devices) and may not be available in DAPs made by other manufacturers, in other word, it might or might not work on other DAPs!

No warranty as to servicablity of this module is either expressed or implied. User assumes all risk by downloading and using this module.

## What this module does:
- Reduces Jitter and Latency
- Optimizes Ram Management
- Disables scheduler logs/stats
- Disables printk logs
- Disables SPI CRC
- Tweaks mglru
- Allows sched boosting on top-app tasks (Thx to tytydraco)
- Tweaks uclamp scheduler (Credits to darkhz for uclamp tweak)
- Sets -20 (highest priority) for the most essential processes
- Uses Google's schedutil rate-limits
- Removes some unnecessary apps from firmware
- Removes zswap (compressed RAM)
- Forces FiiO secondary apps to not autorun
- Small SYSTEM application tweaks
-- Window animations
-- Blur effects
- Provides smooth and balanced running of Music apps


## What the module doesn't:
- Require additional modules for complete implementation
- Require additional applications
- Change the soundstage or any other aspect of the sound!
- Make permanent changes to your device (everything is systemless)
- Change settings that don't need changing


## Notes:
- This is not a perfomance/gaming module!


## How to install:
- Just flash in Magisk and reboot
- And that's it ;)


## How to check logs:
- Check info.log text file in /data/adb/modules/fiioat/ folder
- Check error.log text file in /data/adb/modules/fiioat/ folder
- It should look like this (Not exactly ofc):
<img width="261" height="475" alt="info log" src="https://github.com/user-attachments/assets/884eccbe-c7ca-435b-8b63-ca15f112f3b8" />

## How to Contribute:
- Fork the Repo
- Edit tweaks according to your info/docs
- Commit with proper name and info/docs about what you did
- Test the change you did and check if eveything it's fine
- Then make a pull request
