
if [ "`ssh ubuntu@$serverName 'echo "ok"'`" != "ok" ]; then
  echo "failed to ssh"
  exit 1
else
  echo "can ssh"
fi

if [ "`ssh ubuntu@$serverName 'git --version'`" == "" ]; then
  echo "git not installed"
  exit 1
else
  echo "git installed"
fi

if [ "`ssh ubuntu@$serverName "sudo cat /root/sire/.git/config | grep -oP "${sireRepo}$""`" != $sireRepo ]; then
  echo "sire repo missing"
  exit 1
else
  echo "sire deployed"
fi