# Changelog
All notable changes to this project will be documented in this file.  

## [5.1.1.2] - 2026-01-01

- Added smart automatic app list generator accessible via the Action button in your root manager. Supports multi-user profiles and automatic backup of existing app lists.
- Unified permissions for a more robust functionality with recent Android versions.
- Minor changes and fixes.

## [5.1.1.1] - 2025‑07‑30
- Fixed a crash caused by `FirebaseCrashlytics component is not present` if the base apk is systemized.
- Minor tweaks and updated banner.

## [5.1.1] - 2025‑07‑29
- Added the critical `RECEIVE_USER_PRESENT` permission to enable reliable screen lock/unlock detection and proper app hibernation.
- Migrated to the [**MMT Reborn**](https://github.com/iamlooper/MMT-Reborn) template for improved future compatibility with Magisk and KernelSU, plus enhanced module reliability and maintainability.