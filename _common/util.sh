#misc crontab functions
#
# 05/08/2015 - changed /usr/local/bin/forever to forever. was hanging on lucky servers. installing it globally in forever.sh anyway
# 05/24/2015 - changed forever back to /usr/local/bin/forever. not in crontab's path
#

crontab_add(){
	search=$1
	line=$2
	if [ ! "$line" ]; then
		line=$search
	fi

	echo "installing crontab: $line"
	tmp=`mktemp`
	crontab -l | grep -v "$search" > $tmp
	echo "$line" >> $tmp
	crontab < $tmp 
	rm $tmp
}

crontab_remove(){
	search=$1
	tmp=`mktemp`
	crontab -l | grep -v "$search" > $tmp
	crontab < $tmp
	rm $tmp
}

crontab_clear(){
	tmp=`mktemp`
	crontab -l > $tmp
	mv $tmp $tmp"_cron";
	echo "" | crontab
	echo "crontab cleared tmp in "$tmp"_cron"
}

remote_config_add(){
	serverName=$1
	file=$2
	key=$3
	val=$4
	search=`ssh ubuntu@$serverName "sudo cat $file 2>/dev/null | grep $key | head -n1"`
	if [ "$search" == "" ]; then
		ssh ubuntu@$serverName "echo 'export $key=\"$val\"' | sudo tee -a $file >> /dev/null"
	fi
}

localhost_add_cname(){
	cname=$1
	check=`cat /etc/hosts | grep "$cname" | head -n1`
	if [ "$check" == "" ]; then
		echo "127.0.0.1	 $cname" >> /etc/hosts
	fi
}

gen_add_line_to_file(){
	file=$1
	search=$2
	line=$3
	perms=$4
	if [ ! "$line" ]; then
		line=$search
	fi
	if [ ! -f "$file" ]; then
		touch $file
		if [ "$perms" != "" ]; then
			chmod "$perms" $file
		fi
	fi
	tmp=`mktemp`
	cat "$file" | grep -v "$search" > $tmp
	echo "$line" >> $tmp
	#"$file" < $tmp # perms issue??
	cat $tmp > "$file"
	rm $tmp
}

forever_is_running(){
	/usr/local/bin/forever list | grep "$1"
}

forever_run(){
	torun1=`everything_but $1`
	file=`first_arg $1`
	script=`/usr/bin/realpath $file`
	torun=$script
	if [ "$torun1" != "" ]; then # necessary check to prevent extra space if no $torun
		torun=$script" "$torun1
	fi

	echo "forever_run sireDir: $sireDir"
	crontab_add "$torun" "* * * * * $sireDir/bin/angel.sh \"$torun\" >> /var/log/angel.log 2>&1"
	echo "forever_run calling forever_stop '$torun'"
	forever_stop "$torun" # needs to be super unique

	echo `date`
	echo "torun1: $torun1"
	echo "file: $file"
	echo "script: $script"
	echo "torun: $torun"
	echo "dir: $sireDir"
	/usr/local/bin/forever start --spinSleepTime 1000 --minUptime 500 $torun
}

forever_stop(){
	#index=`forever_uid '$1'` # was using forever_index before, but had issues when stopping index 0
	index=`/usr/local/bin/forever list | grep "$1" | awk '{print $3}' | sed -e 's/\[\|\]//g' | head -n1` # for some reason the above isnt working, dont have time to figure out why atm
	if [ "$index" == "" ]; then
		echo "forever stop> $1 not running"
	else
		echo "forever_stop, index: $index"
		/usr/local/bin/forever list
		/usr/local/bin/forever stop $index
	fi
}

forever_uid(){
	/usr/local/bin/forever list | grep "$1" | awk '{print $3}' | sed -e 's/\[\|\]//g' | head -n1
}

forever_index(){
	/usr/local/bin/forever list | grep "$1" | awk '{print $2}' | sed -e 's/\[\|\]//g' | head -n1
}

forever_logfile(){
	search=$1
	/usr/local/bin/forever --plain list | grep $search | grep -oP '\/root[^ ]+'
}

first_arg(){
	echo $1 
}

everything_but(){
	out=""
	a=0
	for arg in $@;
	do
		if [ "$a" == "0" ]; then
			a=1
		else
			out=$out" "$arg
		fi
	done
	echo $out
}

public_ip(){
	curl http://169.254.169.254/latest/meta-data/public-ipv4
}

configure_hooky(){
	echo "configure_hooky() $@"
	dir=$1
	branch=$2
	githubHookAuthToken=$3
	port=$4
	postScript=$5
	if [ "$port" == "" ]; then port=9998; fi
	hookyConfig=/root/hooky.json
	IP=`public_ip`
	startpwd=`pwd`
	cd $sireDir/_common/hooky
	npmi
	/usr/local/bin/node ./add_to_config.js -c "$hookyConfig" -r "$dir" -b $branch -t "$githubHookAuthToken" -p $port -s "$postScript"
	forever_run "./index.js -a $IP -c $hookyConfig"
	cd $startpwd
	# remove gitsync cron...
	gitsync_remove_cron "$1" "$2"
}

gitsync_cron(){
	dir=$1
	branch=$2
	if [ "$branch" == "" ]; then branch='master'; fi
	key="gitsync_cron $dir $branch"
	cron="$sireDir/_common/gitsync.sh '$dir' '$branch'; sleep 15;"
	crontab_add "$key" "* * * * * echo '$key'; $cron $cron $cron $cron"
	# remove from hooky...
	/usr/local/bin/node ./add_to_config.js -c "$hookyConfig" -r "$dir"
}

gitsync_remove_cron(){
	dir=$1
	branch=$2
	if [ "$branch" == "" ]; then branch='master'; fi
	key="gitsync_cron $dir $branch"
	crontab_remove "$key"
}

install_repo(){
	dir=$1
	repo=$2
	branch=$3
	if [ "$branch" == "" ]; then
		branch='master'
	fi
	if [ ! -d "$dir" ]; then
		mkdir -p "$dir"
		git clone $repo "$dir"
	fi
	$sireDir/_common/gitsync.sh "$dir" "$branch"
}

accessLogLocation(){
	key_=$1
	grep access_log /etc/nginx/sites-enabled/$key_ | head -n1 | awk '{print $2}' | tr -d ';'
	unset key_
}

errorLogLocation(){
	key_=$1
	grep error_log /etc/nginx/sites-enabled/$key_ | head -n1 | awk '{print $2}' | tr -d ';'
	unset key_
}

rotate_logs(){
	# rotate_logs uniqueId -t '0 3 * * *' -m 8 -o /var/log/self_output.log /var/log/log1.log /var/log/log2.log
	echo
	#when_='0 0 * * *'
	when_='@daily'
	maxBaks_=10
	for arg in "$@"; do
		if [ "$arg" == "-o" ]; then
			nextInputIsOutput_=1
		elif [ "$nextInputIsOutput_" == "1" ]; then
			outputLog_=$arg
			nextInputIsOutput_=0
		elif [ "$arg" == "-m" ]; then
			nextInputIsMaxBaks_=1
		elif [ "$nextInputIsMaxBaks_" == "1" ]; then
			maxBaks_=$arg
			nextInputIsMaxBaks_=0
		elif [ "$arg" == "-t" ]; then
			nextInputIsWhen_=1
		elif [ "$nextInputIsWhen_" == "1" ]; then
			when_=$arg
			nextInputIsWhen_=0
		elif [ "$id_" == "" ]; then
			id_=$arg
		else
			logFiles_=$logFiles_" '$arg'"
		fi
	done
	if [ "$id_" == "" ] || [ "$when_" == "" ] || [ "$logFiles_" == "" ]; then
		error_="missing input"
	fi
	id_=$id_"_rotateLogs"
	echo "id_: $id_"
	echo "when_: $when_"
	echo "maxBaks_: $maxBaks_"
	echo "outputLog_: $outputLog_"
	echo "logFiles_: $logFiles_"
	if [ ! -d $sireDir/bin/node_modules/shlog-rotate ]; then
		if [ "`which npm`" == "" ]; then
			error_="npm not installed"
		else
			echo "shlog-rotate not installed. installing in $sireDir..."
			mkdir -p $sireDir/bin/node_modules
			npm install --prefix $sireDir/bin shlog-rotate
		fi
	fi
	shlogScript=$sireDir/bin/node_modules/shlog-rotate/index.sh
	if [ ! -f $shlogScript ]; then
		error_=$error_"; shlog-rotate main not found"
	fi
	cron_="$when_ /bin/bash $shlogScript $maxBaks_ $logFiles_"
	if [ "$outputLog_" != "" ]; then
		cron_=$cron_" >> '$outputLog_' 2>&1"
	fi
	cron_=$cron_" #$id_"
	if [ "$error_" == "" ]; then
		echo "rotate_logs() crontab_add \"#$id_\" \"$cron_\""
		crontab_add "#$id_" "$cron_"
	else
		echo "rotate_logs() failed: $error_"
	fi
	echo
	unset id_
	unset nextInputIsWhen_
	unset when_
	unset nextInputIsMaxBaks_
	unset maxBaks_
	unset nextInputIsOutput_
	unset outputLog_
	unset logFiles_
	unset error_
	unset cron_
}
