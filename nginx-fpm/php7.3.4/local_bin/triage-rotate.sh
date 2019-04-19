#!/bin/sh
ps -ef | grep logrotate | grep -v grep
process=`ps -ef | grep logrotate | grep -v grep | wc -l`
echo $process
if [ $process -eq 0 ]; then 
    logrotate /etc/logrotate.conf
fi
