export NPM_REGS="http://registry.npmjs.org http://registry.nodejitsu.com http://registry.npmjs.eu http://npm.nodejs.org.au:5984"

npmi(){
	for reg in $NPM_REGS; do
		npm install --registry $reg $@
		if [ "$?" -eq "0" ]; then
			echo "install from $reg successful!"	
			break	
		else
			echo "npm install from $reg failed. =("
		fi
	done
}
