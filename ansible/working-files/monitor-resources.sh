#!/bin/bash

MON_LOG=/root/monitor.log
touch $MON_LOG

while true
do
  echo -n "[`date`]: Open files: " >> $MON_LOG
  echo `/sbin/sysctl fs.file-nr` >> $MON_LOG
  echo -n "[`date`]: Processes: " >> $MON_LOG
  echo `ps -A --no-headers | wc -l` >> $MON_LOG

  echo -n "[`date`]: centos su test: " >> $MON_LOG
  echo `su - centos -c "hostname"` >> $MON_LOG

  sleep 300
done
