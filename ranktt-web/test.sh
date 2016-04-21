
if [ "`cat ${installDir}/.git/config | grep -oP "${gitRepo}$"`" != $gitRepo ]; then
  echo "repo missing"
  exit 1
else
  echo "repo deployed"
fi
