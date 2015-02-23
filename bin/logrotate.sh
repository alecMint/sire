#!/bin/bash
# ./bin/logrotate.sh 10 ./out/mylog.log ./out/anotherlog.log 2>&1 >> /var/log/logrotate.log
# note: paths should be absolute, i stopped messing with realpath to keep logic simple
# @todo: fix script so it doesnt try to rotate $preDeletionHook

date

maxFiles=$1

positiveInt='^[1-9][0-9]*$'
if ! [[ "$maxFiles" =~ $positiveInt ]]; then
	echo "invalid maxFiles arg"
	exit 1
fi

if [ "`echo "$2" | grep '.sh'`" != "" ]; then
	preDeletionHook=$2
fi
echo "preDeletionHook: $preDeletionHook"

dropNginxFileHandler=0

rotate(){
	logFile=$1
	maxFiles=$2
	echo $'\n'"rotate() $logFile"
	for ((i=$maxFiles;i>=0;i--)); do
		[ $i == 0 ] && suf='' || suf=".$i"
		[ ! -f "$logFile$suf" ] && continue
		if [ $i == $maxFiles ]; then
			# if a preDeletionHook points to a script for shipping off to s3 or w/e...
			echo "checking preDeletionHook: $preDeletionHook"
			if [ -f "$preDeletionHook" ]; then
				echo "running preDeletionHook..."
				"$preDeletionHook" "$logFile$suf"
			fi
			echo "rm $logFile$suf"
			rm "$logFile$suf"
			continue
		fi
		echo "$logFile$suf > $logFile."$[$i+1]
		mv "$logFile$suf" "$logFile."$[$i+1]
	done

	# if looks like nginx log, make nginx drop its file handler
	if [ "`echo "$logFile" | grep nginx`" != "" ]; then
		dropNginxFileHandler=1
	fi

}

n=0
for arg in "$@"; do
	n=$[n+1]
	[ $n == 1 ] && continue
	rotate "$arg" $maxFiles
done

if [ "$dropNginxFileHandler" == "1" ]; then
	echo "identified at least one nginx log file: $logFile"
	if [ -f /var/run/nginx.pid ]; then
		kill -USR1 `cat /var/run/nginx.pid` && sleep 1 && echo "dropped nginx file handler" || echo "failed to drop nginx file handler :("
	else
		echo "failed to drop nginx file handler: /var/run/nginx.pid is not a file"
	fi
fi

date
