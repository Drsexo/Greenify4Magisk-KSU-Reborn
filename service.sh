#!/system/bin/sh

MODDIR="${0%/*}"
GREENIFY_PKG="com.oasisfeng.greenify"


while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 5
done

sleep 10

# Grant runtime permissions
pm grant "$GREENIFY_PKG" android.permission.POST_NOTIFICATIONS 2>/dev/null
pm grant "$GREENIFY_PKG" android.permission.SYSTEM_ALERT_WINDOW 2>/dev/null
pm grant "$GREENIFY_PKG" android.permission.GET_ACCOUNTS 2>/dev/null

# Grant special permissions via appops
appops set "$GREENIFY_PKG" android:get_usage_stats allow 2>/dev/null

# Self delete
rm -f "$MODDIR/service.sh"