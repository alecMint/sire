#misc crontab functions

crontab_add(){
	search=$1
	line=$2
	if [ ! "$line" ]; then
		line=$search
	fi

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
	search=`ssh ubuntu@$serverName "sudo cat $file 2>&1 /dev/null | grep $key | head -n1"`
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

gitsync_cron(){
	dir=$1
	branch=$2
	if [ "$branch" == "" ]; then
		branch='master'
	fi
	key="gitsync_cron $dir $branch"
	cron="$sireDir/_common/gitsync.sh '$dir' '$branch'; sleep 15;"
	crontab_add "$key" "* * * * * echo '$key'; $cron $cron $cron $cron"
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

rotate_logs(){
	for arg in "$@"; do
		echo "arg: $arg"
		if [ "$when" == "" ]; then
			when=$arg
		else
			logfiles=$logfiles" '$arg'"
		fi
	done
	echo "when: $when"
	echo "logfiles: $logfiles"
}
