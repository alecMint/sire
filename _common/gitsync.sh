
dir=$1
branch=$2

cd $dir
git fetch
git reset --hard HEAD
git checkout -f $branch
git pull origin $branch
git submodule update
npm install

if [ -f "$dir/post-gitsync.sh" ]; then
	$dir/post-gitsync.sh "$dir" "$branch"
fi
