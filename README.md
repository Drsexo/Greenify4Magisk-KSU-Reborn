<h1 align="center">Greenify4Magisk/KSU Reborn</h1>
<p align="center">
  <img src="https://play-lh.googleusercontent.com/w261De9ZkHSxBGYcdFXG9BySiK2ugwMb7ReGh_AfN7UUSefB3ja_wPVtP91aewaKoKO0" alt="Greenify Icon" width="100"/>
</p>

> [!NOTE]
> **Fully working with KernelSU and Magisk and APatch.**

<div align="center">

  ![Total downloads](https://img.shields.io/github/downloads/Drsexo/Greenify4Magisk-KSU-Reborn/total)

</div>


## 📦 What this module does

This module integrates Greenify as a **privileged system app** to enable **Boost Mode**, enhancing hibernation performance without modifying the ROM.  
It injects Greenify into `/system/priv-app`, allowing it to function natively as a system app — if the app shows "Privileged" in its settings, everything is working.

The module features an integrated bulk hibernation manager. To use it: install the module, reboot, open Greenify once, then tap the Action button in your Magisk/KSU/APatch manager to bulk add apps to the hibernation list, with the option to:

- Add user apps only, system apps only, or all apps
- Automatically exclude critical system components to prevent instability
- Support multiple user profiles



⚠️ If Greenify doesn’t open after reboot on KSU, try:
- Disabling "Umount modules by default" in KSU settings  
- Installing Greenify APK manually

## ⚙️ Requirements 

- Android 9.0 - 15.0
- Magisk v20.4+
- KernelSU v0.6.6+
- APatch

## 🙌 Credits

- [Oasis Feng](https://play.google.com/store/apps/details?id=com.oasisfeng.greenify) — Greenify developer  
- [Topjohnwu](https://github.com/topjohnwu) — Magisk developer
- [abacate123](https://forum.xda-developers.com/m/abacate123.6439974/) — Original Magisk integration  
- [AzyrRuthless](https://github.com/AzyrRuthless/Greenify4Magisk-KSU) — Original KSU fork