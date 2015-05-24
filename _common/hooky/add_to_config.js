/*
node add_to_config.js -c /tmp/hooky.json -r /var/www/hope -b master -t GITHUBAUTHTOKEN -p 9998

Remove from config:
node add_to_config.js -c /tmp/hooky.json -r /Users/ahulce/Dropbox/Beachmint/hope

node add_to_config.js -c /tmp/hooky.json -r /Users/ahulce/Dropbox/Beachmint/hope -b master -t GITHUBAUTHTOKEN -p 9998
node add_to_config.js -c /tmp/hooky.json -r /Users/ahulce/Dropbox/Beachmint/ace -b master -t GITHUBAUTHTOKEN2 -p 9997
node add_to_config.js -c /tmp/hooky.json -r /Users/ahulce/Dropbox/Beachmint/hope

blocking so we can use in bash script
*/

var fs = require('fs')
,path = require('path')
,argv = require('optimist').argv
;

var configFile = argv.c
,repo = path.resolve(argv.r)
,branch = argv.b
,githubAuthToken = argv.t
,port = argv.p // one per auth token
,postScript = argv.s && typeof argv.s == 'string' ? argv.s : null
,removeFromConfig = false
,o = {repo:repo, branch:branch, githubAuthToken:githubAuthToken, port:port, postScript:postScript }
,configs, replaced
;

if (!(configFile && repo && branch && githubAuthToken && port)) {
	if (configFile && repo) {
		removeFromConfig = true;
		console.log('config file and repo given, but missing other arguments. removing from config...');
	} else {
		console.log('missing arguments');
		process.exit(1);
	}
}

try {
	configs = JSON.parse(fs.readFileSync(configFile));
} catch (e) {
	if (e.code != 'ENOENT')
		throw e;
	configs = [];
}

for (var i=0;i<configs.length;++i) {
	if (configs[i].repo == repo) {
		removeFromConfig ? configs.splice(i,1) : (configs[i] = o);
		replaced = true;
		break;
	}
}
if (!replaced && !removeFromConfig)
	configs.push(o);

configs = JSON.stringify(configs);
fs.writeFileSync(configFile, configs);

console.log('new configs:\n'+configs);
