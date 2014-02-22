#!/bin/bash

#todo gzip update to s3
for log in `ls /root/.forever/*.log`
do
  echo "" > $log
done

