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

prefix=${TMPDIR}cpu_watch
mkdir -p $prefix

#echo $cpu_limit
#echo $processes
#echo $notifier

if ((cpu_limit >= 0)) && [ "x$processes" != "x" ]; then

    #get processes infos
    current=$(ps -erco %cpu,command | grep -E "$processes")

    echo "$current" | while read p; do
        subtitle=$(echo $p | cut -f2- -d\ )
        cpu=$(echo $p | cut -f1 -d\ )\%

        #if file exists and is older than 10min, remove it
        if [ -e \""$prefix"/"$subtitle"\" ] && test $(find \”"$prefix"/"$subtitle"\" -mmin +"$interval"); then
            rm $prefix/"$subtitle"
        fi

        #if cpu > cpu_limit
        if [ $(echo $cpu | cut -d, -f1) -ge $cpu_limit ]; then
            $notifier -title "$title" -subtitle "$subtitle" -message $cpu \
                -group $notifier_group -activate $activity -sender $activity \
                > /dev/null

            touch "$prefix/$subtitle" #create a file in order to not fire a notif every 30sec
        fi
    done
fi

