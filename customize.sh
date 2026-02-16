#!/system/bin/sh
# Greenify Systemizer


SKIPMOUNT=false
DEBUG=false

COLS=$(stty size 2>/dev/null | awk '{print $2}')
case "$COLS" in ''|*[!0-9]*) COLS=40 ;; esac
[ "$COLS" -gt 54 ] && COLS=54
[ "$COLS" -lt 20 ] && COLS=40

_iw=$((COLS - 4))
LINE="" _i=0
while [ $_i -lt $_iw ]; do
  LINE="${LINE}─"
  _i=$((_i + 1))
done
BOX_TOP="  ${LINE}"
BOX_BOT="  ${LINE}"
unset _i _iw

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

set_permissions() {
  set_perm_recursive "$MODPATH/system/priv-app" 0 0 0755 0644 u:object_r:system_file:s0
  set_perm_recursive "$MODPATH/system/etc/permissions" 0 0 0755 0644 u:object_r:system_file:s0
  set_perm "$MODPATH/service.sh" 0 0 0755
}

"$DEBUG" && set -x
"$BOOTMODE" || abort "! Install from Magisk/KSU/APatch app only"

print_banner

ui_print "- Extracting files..."
unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2

"$SKIPMOUNT" && touch "$MODPATH/skip_mount"

sleep 0.5

ui_print "- Setting permissions..."
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_permissions

rm -rf "$MODPATH/customize.sh" "$MODPATH/LICENSE" "$MODPATH/CHANGELOG.md" "$MODPATH/update.json" "$MODPATH/README.md" "$MODPATH"/.git*

ui_print ""
ui_print "$BOX_TOP"
ui_print "  Please reboot your device manually"
ui_print "  to complete the installation."
ui_print ""
ui_print "  After reboot, open Greenify once,"
ui_print "  then use the Action button in your"
ui_print "  Magisk/KSU/APatch manager app to"
ui_print "  bulk add apps to hibernation list."
ui_print "$BOX_BOT"
ui_print ""