#!/system/bin/sh
# =========================================
# Greenify Systemizer
# A Magisk/KSU/APatch module to systemize
# Greenify and manage hibernation list
# =========================================

##############
# Config Vars
##############

SKIPMOUNT=false
DEBUG=false
GREENIFY_PKG="com.oasisfeng.greenify"

##############
# Functions
##############

print_banner() {
  ui_print ""
  ui_print "   __________  _____________   ______________  __ "
  ui_print "  / ____/ __ \/ ____/ ____/ | / /  _/ ____/\ \/ /"
  ui_print " / / __/ /_/ / __/ / __/ /  |/ // // /_     \  /"
  ui_print "/ /_/ / _, _/ /___/ /___/ /|  // // __/     / /"
  ui_print "\____/_/ |_/_____/_____/_/ |_/___/_/       /_/"
  ui_print ""
  ui_print "          𝗠𝗮𝗴𝗶𝘀𝗸 / 𝗞𝗦𝗨 / 𝗔𝗣𝗮𝘁𝗰𝗵"
  ui_print ""
}

is_user_app() {
  pm path "$1" 2>/dev/null | grep -q "^package:/data/app/"
}

uninstall_user_greenify() {
  ui_print "- Checking for user-installed Greenify..."
  if is_user_app "$GREENIFY_PKG"; then
    pm uninstall "$GREENIFY_PKG" >/dev/null 2>&1
    ui_print "  Removed user app"
  else
    ui_print "  Not found"
  fi
}

set_permissions() {
  set_perm_recursive "$MODPATH/system/priv-app" 0 0 0755 0644 u:object_r:system_file:s0
  set_perm_recursive "$MODPATH/system/etc/permissions" 0 0 0755 0644 u:object_r:system_file:s0
}

#######
# Main
#######

"$DEBUG" && set -x
"$BOOTMODE" || abort "! Install from Magisk/KSU/APatch app only"

print_banner

ui_print "- Extracting files..."
unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2

uninstall_user_greenify

"$SKIPMOUNT" && touch "$MODPATH/skip_mount"

sleep 0.5

ui_print "- Setting permissions..."
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_permissions

# Cleanup (keep action.sh!)
rm -rf "$MODPATH/customize.sh" "$MODPATH/LICENSE" "$MODPATH/CHANGELOG.md" "$MODPATH/update.json" "$MODPATH/README.md" "$MODPATH"/.git*

ui_print ""
ui_print "- Done! Reboot to apply."
ui_print ""
ui_print "==========================================="
ui_print ""
ui_print "  !                                      !"
ui_print "  !  After reboot, open Greenify once,   !"
ui_print "  !  then use the Action button in your  !"
ui_print "  !  Magisk/KSU/APatch manager app to    !"
ui_print "  !  bulk add apps to hibernation list.  !"
ui_print "  !                                      !"
ui_print ""
ui_print "==========================================="
ui_print ""