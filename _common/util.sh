#misc crontab functions

auto_dir(){
   `pwd` | sed -e "s/\(node-automation\).*$/\1/"
}

crontab_add(){
  search=$1
  line=$2
  if [ ! "$line" ]; then
    line=$search
  fi

  tmp=`mktemp`
  crontab -l | grep -v $search > $tmp
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
  module=$2
  key=$3
  val=$4
  search=`ssh ubuntu@$serverName "sudo cat $module/config.local.sh | grep $key | head -n1"`
  if [ $search == "" ]; then
    ssh ubuntu@$serverName "echo 'exports key=\"$val\"' | sudo tee $module/config.local.sh >> /dev/null"
  fi
}

localhost_add_cname(){
  cname=$1
  check=`cat /etc/hosts | grep "$cname" | head -n1`
  if [ "$check" == "" ]; then
    echo "127.0.0.1   $cname" >> /etc/hosts
  fi
}

forever_is_running(){
  forever list | grep "$1"
}

forever_run(){
  torun1=`everything_but $1`
  file=`first_arg $1`
  script=`realpath $file`
  torun=$script" "$torun1
  dir=/opt/node-automation

  crontab_add "$script" "*/5 * * * * $dir/bin/angel.sh \"$torun\" >> /var/log/angel.log 2>&1"
  forever_stop "$script"

  echo "torun1: $torun1"
  echo "file: $file"
  echo "script: $script"
  echo "torun: $torun"
  echo "dir: $dir"
  forever start --spinSleepTime 1000 --minUptime 500 $torun
}

forever_stop(){
  index=`forever_index $1`
  if [ "$index" == "" ]; then
    echo "forever stop> $1 not running"
  else 
    forever stop $index
  fi
}

forever_index(){
  forever list | grep $1 | awk '{print $2}' | sed -e 's/\[\|\]//g'
}

forever_logfile(){
  search=$1
  forever --plain list | grep $search | grep -oP '\/root[^ ]+'
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



