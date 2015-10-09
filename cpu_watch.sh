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

#echo $cpu_limit
#echo $processes
#echo $notifier

sendNotif() {

    subtitle=$1
    cpu=$2

    #remove everything behind ',' (French) or '.'
    cpu_int=$(echo $cpu | cut -d. -f1 | cut -d, -f1)


    #if cpu > cpu_limit
    if [ $cpu_int -ge $cpu_limit ]; then
        #echo $subtitle $cpu $cpu_int $cpu_limit
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
        path=$(echo "$prefix"/"$subtitle" | tr -d '[[:space:]]')
        #echo $cpu
        #echo $path

        #if file exists and is older than 10min, remove it and send nofif
        if [ -e "$path" ] && test $(find "$path" -mmin +"$interval"); then
            sendNotif "$subtitle" $cpu
            rm "$path"
        fi

        #if no file
        if [ ! -e "$path" ]; then
            #create a file in order to not fire a notif every 30sec
            touch "$path"

            sendNotif "$subtitle" $cpu
        fi
    done
fi

