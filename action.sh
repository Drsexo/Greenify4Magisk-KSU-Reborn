#!/system/bin/sh

GREENIFY_PKG="com.oasisfeng.greenify"
TIMEOUT=30


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

if ! command -v timeout >/dev/null 2>&1; then
  timeout() { shift; "$@"; }
fi

print_banner() {
  echo ""
  echo "   __________  _____________   ______________  __ "
  echo "  / ____/ __ \/ ____/ ____/ | / /  _/ ____/\ \/ /"
  echo " / / __/ /_/ / __/ / __/ /  |/ // // /_     \  /"
  echo "/ /_/ / _, _/ /___/ /___/ /|  // // __/     / /"
  echo "\____/_/ |_/_____/_____/_/ |_/___/_/       /_/"
  echo ""
  echo "        Bulk app hibernation manager"
  echo ""
}

vol_key_prompt() {
  local prompt="$1"
  local up_label="$2"
  local down_label="$3"
  local default="$4"

  echo ""
  echo "  $prompt"
  echo "  Vol [+] $up_label  |  Vol [-] $down_label"
  echo ""

  while :; do
    event=$(timeout "$TIMEOUT" getevent -qlc 1 2>/dev/null)
    code=$?

    if [ "$code" -eq 124 ] || [ "$code" -eq 143 ]; then
      if [ "$default" = "UP" ]; then
        return 0
      else
        return 1
      fi
    fi

    if echo "$event" | grep -q "KEY_VOLUMEUP.*DOWN"; then
      return 0
    fi

    if echo "$event" | grep -q "KEY_VOLUMEDOWN.*DOWN"; then
      return 1
    fi
  done
}

vol_key_cycle() {
  local options="$1"
  local count="$2"

  local choice=1
  echo ""
  echo "  Vol [+] Next  |  Vol [-] Confirm"
  echo ""

  local opt
  opt=$(echo "$options" | sed -n "${choice}p")
  echo "  > $opt"

  while :; do
    event=$(timeout "$TIMEOUT" getevent -qlc 1 2>/dev/null)
    code=$?

    if [ "$code" -eq 124 ] || [ "$code" -eq 143 ]; then
      return $choice
    fi

    if echo "$event" | grep -q "KEY_VOLUMEUP.*DOWN"; then
      choice=$((choice + 1))
      [ $choice -gt $count ] && choice=1
      opt=$(echo "$options" | sed -n "${choice}p")
      echo "  > $opt"
    fi

    if echo "$event" | grep -q "KEY_VOLUMEDOWN.*DOWN"; then
      return $choice
    fi
  done
}

check_greenify() {
  echo "- Checking Greenify installation..."
  sleep 0.5

  if ! pm path "$GREENIFY_PKG" >/dev/null 2>&1; then
    echo ""
    echo "  [X] Greenify is not installed!"
    echo "      Please reinstall."
    echo ""
    exit 1
  fi

  echo ""
  echo "  [OK] Greenify found"
  echo ""
  sleep 0.5
}

check_and_stop_greenify() {
  if pgrep -f "$GREENIFY_PKG" >/dev/null 2>&1; then
    echo "- Stopping Greenify..."
    am force-stop "$GREENIFY_PKG" >/dev/null 2>&1
    sleep 1
    if pgrep -f "$GREENIFY_PKG" >/dev/null 2>&1; then
      am force-stop "$GREENIFY_PKG" >/dev/null 2>&1
      sleep 1
    fi
    echo "  Stopped"
    echo ""
  fi
}

get_greenify_uid() {
  local uid
  uid=$(dumpsys package "$GREENIFY_PKG" 2>/dev/null | grep "userId=" | head -1 | sed 's/.*userId=\([0-9]*\).*/\1/')
  [ -z "$uid" ] && uid=$(stat -c %u "/data/data/$GREENIFY_PKG" 2>/dev/null)
  [ -z "$uid" ] && uid="10062"
  echo "$uid"
}

get_greenify_path() {
  USER_ID=$(am get-current-user 2>/dev/null | grep -o '[0-9]*' | head -1)
  [ -z "$USER_ID" ] && USER_ID="0"

  if [ "$USER_ID" = "0" ]; then
    GREENIFY_DIR="/data/data/$GREENIFY_PKG/shared_prefs"
  else
    GREENIFY_DIR="/data/user/$USER_ID/$GREENIFY_PKG/shared_prefs"
  fi

  GREENIFY_UID=$(get_greenify_uid)

  if [ ! -d "$GREENIFY_DIR" ]; then
    echo ""
    echo "  [X] Greenify data not found!"
    echo "      Open Greenify app once, then try again."
    echo ""
    exit 1
  fi

  GREENIFY_XML="$GREENIFY_DIR/greenfied_apps_x.xml"
}

add_package_to_xml() {
  echo "    <set name=\"package:$1\">" >> "$2"
  echo "        <string>label=$1</string>" >> "$2"
  echo "    </set>" >> "$2"
}

get_excluded_apps() {
  # Critical system
  echo "android com.android.systemui com.android.settings com.android.phone com.android.mms"
  echo "com.android.providers.telephony com.android.providers.calendar com.android.providers.contacts"
  echo "com.android.providers.media com.android.providers.downloads com.android.providers.settings"
  echo "com.android.webview com.google.android.webview com.google.android.gms com.google.android.gsf"
  echo "com.android.launcher com.android.keyguard com.android.bluetooth com.android.nfc"
  echo "com.qualcomm.location com.android.location.fused com.oasisfeng.greenify"
  # Keyboard apps
  echo "com.android.inputmethod.latin com.google.android.inputmethod.latin com.samsung.android.honeyboard"
  echo "com.oneplus.keyboard com.miui.keyboard com.huawei.inputmethod com.oppo.keyboard com.vivo.inputmethod ru.yandex.androidkeyboard"
  # Launcher apps
  echo "com.samsung.android.launcher com.oneplus.launcher com.miui.home com.huawei.android.launcher com.android.launcher3"
  echo "com.oppo.launcher com.vivo.launcher com.sec.android.app.launcher com.lge.launcher3"
  # Dialer apps
  echo "com.google.android.dialer com.samsung.android.dialer com.oneplus.dialer com.miui.dialer"
  echo "com.huawei.contacts com.oppo.dialer com.vivo.dialer com.xiaomi.dialer"
  # Clock/Alarm apps
  echo "com.android.deskclock com.google.android.deskclock com.samsung.android.app.clockpack"
  echo "com.oneplus.deskclock com.miui.clock com.huawei.deskclock com.sec.android.app.clockpackage"
  # Camera apps
  echo "com.android.camera com.android.camera2 com.samsung.android.camera com.sec.android.app.camera"
  echo "com.oneplus.camera com.miui.camera com.huawei.camera com.oppo.camera com.google.android.GoogleCamera"
  # Messaging apps
  echo "com.samsung.android.messaging com.google.android.apps.messaging com.oneplus.mms com.miui.mms"
  # Contacts apps
  echo "com.android.contacts com.samsung.android.contacts com.google.android.contacts"
  # Calendar apps
  echo "com.android.calendar com.samsung.android.calendar com.google.android.calendar"
}

generate_xml() {
  local choice=$1

  get_greenify_path
  check_and_stop_greenify

  echo "- Generating app list..."
  sleep 0.5

  if [ -f "$GREENIFY_XML" ]; then
    cp "$GREENIFY_XML" "${GREENIFY_XML}.backup"
    echo "  Existing list backed up"
  fi

  local temp_packages="/data/local/tmp/greenify_packages_$$.tmp"
  local all_excluded=$(get_excluded_apps | tr '\n' ' ')

  case $choice in
    1)
      echo "  Getting user apps..."
      pm list packages -3 2>/dev/null | sed 's/package://' > "$temp_packages"
      ;;
    2)
      echo "  Getting system apps..."
      pm list packages -s 2>/dev/null | sed 's/package://' > "$temp_packages"
      ;;
    3)
      echo "  Getting all apps..."
      pm list packages 2>/dev/null | sed 's/package://' > "$temp_packages"
      ;;
  esac

  echo '<?xml version='\''1.0'\'' encoding='\''utf-8'\'' standalone='\''yes'\'' ?>' > "$GREENIFY_XML"
  echo '<map>' >> "$GREENIFY_XML"

  local count=0
  while IFS= read -r package || [ -n "$package" ]; do
    [ -z "$package" ] && continue

    local skip=false
    for excluded in $all_excluded; do
      [ "$package" = "$excluded" ] && skip=true && break
    done

    if [ "$skip" = "false" ]; then
      add_package_to_xml "$package" "$GREENIFY_XML"
      count=$((count + 1))
    fi
  done < "$temp_packages"

  rm -f "$temp_packages"
  echo '</map>' >> "$GREENIFY_XML"

  if [ ! -f "$GREENIFY_XML" ] || [ ! -s "$GREENIFY_XML" ]; then
    echo ""
    echo "  [X] Failed to create XML file!"
    exit 1
  fi

  chmod 660 "$GREENIFY_XML"
  chown "$GREENIFY_UID:$GREENIFY_UID" "$GREENIFY_XML"
  chcon "u:object_r:app_data_file:s0:c512,c768" "$GREENIFY_XML" 2>/dev/null

  sleep 0.5
  echo ""
  echo "$BOX_TOP"
  echo "  [OK] Added $count apps to Greenify"
  echo "$BOX_BOT"
  echo ""
  echo "  Open Greenify to see and review"
  echo "  the changes."
  echo ""
}

main() {
  print_banner
  check_greenify

  echo "$BOX_TOP"
  echo "  [!] This will OVERWRITE your current"
  echo "  Greenify hibernation list!"
  echo "  (A backup will be saved)"
  echo "$BOX_BOT"

  vol_key_prompt "Add apps to hibernation list?" "Yes" "No" "DOWN"
  local result=$?

  if [ $result -eq 0 ]; then

    OPTIONS="[✓] User apps only
[⚠] System apps only
[⚠] All apps"

    echo ""
    echo "  Select which apps to add:"

    vol_key_cycle "$OPTIONS" 3
    local choice=$?

    echo ""
    case $choice in
      1) echo "  Selected: User apps" ;;
      2) echo "  Selected: System apps" ;;
      3) echo "  Selected: All apps" ;;
    esac

    if [ $choice -eq 2 ] || [ $choice -eq 3 ]; then
      echo ""
      echo "$BOX_TOP"
      echo "  [⚠] WARNING"
      echo ""
      echo "  Greenifying system apps can cause"
      echo "  instability and crashes!"
      echo ""
      echo "  Review the list in Greenify after."
      echo "$BOX_BOT"

      vol_key_prompt "Continue?" "Yes" "No" "DOWN"
      local confirm=$?

      if [ $confirm -ne 0 ]; then
        echo ""
        echo "  Cancelled."
        echo ""
        exit 0
      fi
    fi

    echo ""
    generate_xml $choice

  else
    echo ""
    echo "  Cancelled."
    echo ""
  fi
}

main