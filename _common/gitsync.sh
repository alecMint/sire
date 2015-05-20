
sig=`echo "$@" | sed -n 's/ /./gp'`
lockFile="/tmp/gitsync.$sig.lock"
if [ -f "$lockFile" ]; then
	echo "lock file found, exiting"
	exit
fi
date >> "$lockFile"


dir=$1
branch=$2

cd $dir
git fetch
git reset --hard HEAD
git checkout -f $branch
git pull origin $branch
git submodule update

if [ -f "$dir/package.json" ]; then
	npm install
fi

if [ -f "$dir/post-gitsync.sh" ]; then
	$dir/post-gitsync.sh "$dir" "$branch"
fi


rm "$lockFile"
