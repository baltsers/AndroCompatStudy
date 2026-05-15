#!/bin/bash

dataset=$1
apiLevel=$2
tmv=${3:-"60"}
avd=$4
port=$5
did="emulator-$port"

tryRun()
{
    cate=$1
    srcdir=cg.instrumented/$cate
    finaldir=$srcdir
    OUTDIR=androZooLogs/$cate-$avd
    mkdir -p $OUTDIR

    k=0
    pidadb1="Not Found"

    # Start the emulator
    bash ./setupEmuSafe.sh $avd $port
    sleep 20

    # Check if emulator is online before proceeding
    adb -s $did wait-for-device
    adb -s $did get-state

    mkdir -p failed-installs/${cate}-${apiLevel} 2>/dev/null

    for fnapk in $finaldir/*.apk; do
        echo "================ RUN INDIVIDUAL APP: ${fnapk##*/} ==========================="



        # Install the APK
        ./apkinstall $fnapk $did > installout-$apiLevel-$port 2>&1
        cat installout-$apiLevel-$port
        n1=$(grep -a -c "Success" installout-$apiLevel-$port)
        if [ $n1 -lt 1 ]; then
            # App installation failed
            cat installout-$apiLevel-$port > failed-installs/${cate}-${apiLevel}/$(basename $fnapk).failure
            continue
        fi

        echo "tracing $fnapk ... on $did, api level $apiLevel"

        # Start logcat
        echo "now start logcat..."
        adb -s $did logcat -v raw -s "hcai-intent-monitor" "hcai-cg-monitor" &>$OUTDIR/${fnapk##*/}.logcat &
        pidadb1=$!

        # Run Monkey
        tgtp=$(./getpackage.sh $fnapk | awk '{print $2}')
        echo "now start Monkey..."
        timeout $tmv adb -s $did shell monkey -p $tgtp --ignore-crashes --ignore-timeouts --ignore-security-exceptions --throttle 200 10000000 &> $OUTDIR/${fnapk##*/}.monkey

        # Uninstall and cleanup
	    sleep 3
        ./apkuninstall $fnapk $did
        adb -s $did shell "rm -rf /sdcard/* /data/app/*" 1>/dev/null 2>&1

        k=$((k + 1))
    done

    # Stop emulator and logcat process
    adb -s $did emu kill
    kill $pidadb1
    echo "totally $k apps in category $cate successfully traced."
}

for cate in "$dataset"; do
    echo "================================="
    echo "try tracing dataset: $cate ..."
    echo "================================="
    tryRun $cate
done

exit 0
