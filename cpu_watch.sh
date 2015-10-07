#!/bin/bash

title="CPU usage" #popup title
notifier_group=cpu_watch #popup group
activity="com.apple.ActivityMonitor" #on click, open Activity Monitor
default_notifier="/usr/local/Cellar/terminal-notifier/1.6.3/bin/terminal-notifier"

cpu_limit=$(($1 + 0))
processes=$2
interval=$3
notifier=$4
if [ "x$notifier" = "x" ]; then
    notifier=$default_notifier
fi

prefix=/var/tmp/cpu_watch
mkdir -p $prefix

echo $cpu_limit
echo $processes
echo $notifier

sendNotif() {

    subtitle=$1
    cpu=$2

    #remove everything behind ',' (French) or '.'
    cpu_int=$(echo $cpu | cut -d. -f1 | cut -d, -f1)


    #if cpu > cpu_limit
    if [ $cpu_int -ge $cpu_limit ]; then
        echo $subtitle $cpu $cpu_int $cpu_limit
        $notifier -title "$title" -subtitle "$subtitle" -message $cpu \
            -group $notifier_group -activate $activity -sender $activity \
            > /dev/null
    fi
}

if ((cpu_limit >= 0)) && [ "x$processes" != "x" ]; then

    #get processes infos
    current=$(ps -erco %cpu,command | grep -E "$processes")

    echo "$current" | while read p; do
        subtitle=$(echo $p | cut -f2- -d\ )
        cpu=$(echo $p | cut -f1 -d\ )\%
        echo $cpu

        #if file exists and is older than 10min, remove it and send nofif
        if [ -e "$prefix/$subtitle" ] && test $(find "$prefix/$subtitle" -mmin +"$interval"); then
            echo "file"

            sendNotif "$subtitle" $cpu
            rm "$prefix/$subtitle"
        fi

        #if no file
        if [ ! -e "$prefix/$subtitle" ]; then
            echo "no file"
            #create a file in order to not fire a notif every 30sec
            touch "$prefix/$subtitle"

            sendNotif "$subtitle" $cpu
        fi
    done
fi

