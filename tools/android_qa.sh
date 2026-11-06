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
timeout 90s adb install -r "$apk" | tee "$evidence/install.txt"
timeout 10s adb shell am force-stop "$package"
timeout 10s adb logcat -c
timeout 30s adb shell am start -W -n "$package/com.godot.game.GodotApp" | tee "$evidence/launch.txt"
if grep -E 'Error:|Exception' "$evidence/launch.txt"; then
  exit 1
fi
sleep 12
timeout 10s adb shell pidof "$package" | tee "$evidence/pid-start.txt"
timeout 15s adb exec-out screencap -p > "$evidence/arena.png"
test -s "$evidence/arena.png"
sleep 8
timeout 10s adb shell pidof "$package" | tee "$evidence/pid-end.txt"
capture_logs
if grep -Ei 'SCRIPT ERROR|Parse Error|Failed to load script|FATAL EXCEPTION|Fatal signal' "$evidence/logcat.txt"; then
  echo 'Android runtime errors detected' >&2
  exit 1
fi
cat > "$evidence/result.txt" <<EOF
Android emulator smoke: PASS
APK: $apk
Device: Android API 29 x86_64, software GPU
Verified: installation, launch, live process after 12 and 20 seconds, no script or fatal errors.
Screenshot: arena.png (visual review required).
This test does not validate touch gameplay or device performance.
EOF
cat "$evidence/result.txt"
