#!/bin/sh

LOG_OUTPUT=/var/log/watch-php-fpm.log
ROLLING_LOGS=""
THRESHOLD=15

echo [$(date)] Started $0 >> $LOG_OUTPUT

while [ 1 ]
do
    STALE_PIDS=$(top -b -n 1 | grep " D " | grep "php-fpm: pool" | sed 's/^\s*//' | cut -d " " -f 1 | tr '\n' ',')
    ROLLING_LOGS=$(echo -e "$ROLLING_LOGS\n$STALE_PIDS" | tail -$THRESHOLD)
    STAT=$(echo "$ROLLING_LOGS" | tr ',' '\n' | sed '/^$/d' | sort | uniq -c | sed 's/^\s*//')
    BAD_PIDS=$(echo "$STAT" | grep "$THRESHOLD " | cut -d ' ' -f 2)

    if [ $(echo "$BAD_PIDS" | wc -l) -gt 1 ]; then
        echo [$(date)] Killing $BAD_PIDS >> $LOG_OUTPUT
        kill -9 $BAD_PIDS
    fi

    sleep 1s
done
