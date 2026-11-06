#!/usr/bin/env bash
# Real emulator smoke test. Screenshots require separate visual review.
set -euo pipefail

evidence=build/android-qa
package=com.battlelegends.prototype
mkdir -p "$evidence"
mapfile -t apks < <(find build -maxdepth 1 -type f -name 'BattleLegends-v*.apk')
if [[ ${#apks[@]} -ne 1 ]]; then
  echo 'Expected exactly one Battle Legends APK' >&2
  exit 1
fi
apk=${apks[0]}
test -s "$apk"

capture_logs() {
  timeout 20s adb logcat -d -v threadtime > "$evidence/logcat.txt" 2>&1 || true
  timeout 10s adb shell dumpsys meminfo "$package" > "$evidence/memory.txt" 2>&1 || true
}
trap capture_logs EXIT

timeout 30s adb wait-for-device
timeout 10s adb shell getprop > "$evidence/device-properties.txt"
timeout 10s adb shell wm size > "$evidence/display.txt"
timeout 10s adb shell settings put system accelerometer_rotation 0
timeout 10s adb shell settings put system user_rotation 1
timeout 10s adb shell settings put secure immersive_mode_confirmations confirmed
timeout 90s adb install -r "$apk" | tee "$evidence/install.txt"
timeout 10s adb shell am force-stop "$package"
timeout 10s adb logcat -c
timeout 30s adb shell am start -W -n "$package/com.godot.game.GodotApp" | tee "$evidence/launch.txt"
if grep -E 'Error:|Exception' "$evidence/launch.txt"; then
  exit 1
fi
sleep 12
timeout 10s adb shell pidof "$package" | tee "$evidence/pid-start.txt"
# AOSP can cache the first-run immersive prompt before the secure setting changes.
# Dismiss only its observed confirmation control, never blindly tap gameplay.
timeout 20s adb shell uiautomator dump /sdcard/battle-ui.xml
timeout 10s adb pull /sdcard/battle-ui.xml "$evidence/ui-before.xml"
python3 - "$evidence/ui-before.xml" > "$evidence/immersive-tap.txt" <<'PY'
import re
import sys
import xml.etree.ElementTree as ET

for node in ET.parse(sys.argv[1]).iter('node'):
    resource = node.get('resource-id', '')
    text = node.get('text', '').strip().upper()
    if resource.endswith('/immersive_cling_confirm') or (
        text == 'GOT IT' and node.get('package') in {'android', 'com.android.systemui'}
    ):
        bounds = [int(v) for v in re.findall(r'\d+', node.get('bounds', ''))]
        if len(bounds) != 4:
            raise SystemExit('Invalid immersive confirmation bounds')
        print((bounds[0] + bounds[2]) // 2, (bounds[1] + bounds[3]) // 2)
        break
PY
if read -r tap_x tap_y < "$evidence/immersive-tap.txt"; then
  timeout 10s adb shell input tap "$tap_x" "$tap_y"
  sleep 2
fi
timeout 20s adb shell uiautomator dump /sdcard/battle-ui.xml
timeout 10s adb pull /sdcard/battle-ui.xml "$evidence/ui-after.xml"
if grep -Ei 'immersive_cling|Viewing full screen' "$evidence/ui-after.xml"; then
  echo 'Immersive confirmation still obscures the game' >&2
  exit 1
fi
timeout 10s adb shell dumpsys activity activities > "$evidence/activities.txt"
grep -E "mResumedActivity.*$package" "$evidence/activities.txt"
timeout 15s adb exec-out screencap -p > "$evidence/arena.png"
test -s "$evidence/arena.png"
sleep 8
timeout 10s adb shell pidof "$package" | tee "$evidence/pid-end.txt"
capture_logs
if grep -Ei 'SCRIPT ERROR|Parse Error|Failed to load script|FATAL EXCEPTION|Fatal signal|[[:space:]]E[[:space:]]+godot[[:space:]]*:.*ERROR:|shader failed to compile|Program linking failed' "$evidence/logcat.txt"; then
  echo 'Android runtime errors detected' >&2
  exit 1
fi
cat > "$evidence/result.txt" <<EOF
Android emulator smoke: PASS
APK: $apk
Device: Android API 29 x86_64, ANGLE + SwiftShader software GPU
Verified: installation, launch, live process checks, unobscured foreground activity, no Godot/script/fatal errors.
Screenshot: arena.png (visual review required).
This test does not validate touch gameplay or device performance.
EOF
cat "$evidence/result.txt"
