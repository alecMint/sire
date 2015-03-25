/*
node add_to_config.js -c /tmp/hooky.json -r /var/www/hope -b master -t GITHUBAUTHTOKEN -p 9998

node add_to_config.js -c /tmp/hooky.json -r /Users/ahulce/Dropbox/Beachmint/hope -b master -t GITHUBAUTHTOKEN -p 9998
node add_to_config.js -c /tmp/hooky.json -r /Users/ahulce/Dropbox/Beachmint/ace -b master -t GITHUBAUTHTOKEN2 -p 9997


blocking so we can use in bash script
*/

var fs = require('fs')
,argv = require('optimist').argv
;

var configFile = argv.c
,repo = argv.r
,branch = argv.b
,githubAuthToken = argv.t
,port = argv.p // one per auth token
,o = {repo:repo, branch:branch, githubAuthToken:githubAuthToken, port: port }
,configs, replaced
;

if (!(configFile && repo && branch && githubAuthToken && port)) {
	console.log('missing arguments');
	process.exit(1);
}

try {
	configs = JSON.parse(fs.readFileSync(configFile));
} catch (e) {
	if (e.code != 'ENOENT')
		throw e;
	configs = [];
}

configs.forEach(function(config, i){
	if (config.repo == repo) {
		configs[i] = o;
		replaced = true;
	}
});
if (!replaced)
	configs.push(o);

configs = JSON.stringify(configs);
fs.writeFileSync(configFile, configs);

console.log('new configs:\n'+configs);
