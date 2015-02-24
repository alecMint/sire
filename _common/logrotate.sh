
# export logrotate=$sireDir/bin/logrotate.sh

if [ !-d $sireDir/bin/node_modules/shlog-rotate ]; then
#	if [ "`which npm`" == "" ]; then
#		echo "logrotate.sh failed: npm not installed"
#		exit 1
#	fi
	mkdir -p $sireDir/bin/node_modules
	npm install --prefix $sireDir/bin shlog-rotate
fi

export logrotate=$sireDir/bin/node_modules/shlog-rotate/index.sh
