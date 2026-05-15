#!/bin/bash

port=${2:-"5556"}
did="emulator-$port"

echo "- Killing Emulator $did..."
adb -s $did emu kill || echo "No emulator running on $did."

echo "- Deleting Emulator $1"
avdmanager delete avd -n $1 || echo "No AVD named $1 to delete."

echo "- Copying emulator template"
cp -r ~/.android/avd/template/$1.* ~/.android/avd/

echo "- Starting emulator on port $port"
emulator -avd $1 -scale .3 -no-boot-anim -no-window -port $port -gpu off -wipe-data &

date1=$(date +"%s")

echo "- Waiting for emulator to boot"

# Wait for the emulator to show up in `adb devices`
while ! adb -s $did wait-for-device; do
  echo "   Waiting for emulator device to connect to ADB..."
  sleep 5
done

# Wait for `sys.boot_completed` to be set to 1
while [[ $(adb -s $did shell getprop sys.boot_completed | tr -d '\r') != "1" ]]; do
  echo "   Waiting for emulator to fully boot (sys.boot_completed)..."
  sleep 5
done

echo "Emulator booted!"

date2=$(date +"%s")
diff=$(($date2 - $date1))
echo ".. Emulator boot took $(($diff / 60)) minutes and $(($diff % 60)) seconds."
