var octopie = require('octopie');
var gitconfig = require('gitconfiglocal');
var gitroot = require('./gitroot')
var argv = require('optimist').argv;
var proc = require('child_process');
var fs = require('fs');

//
// node index.js -r "/my/repo /my/other/repo" -ip $publicip
//
// space deilimted path names to git repos.
// git pull origin $(git branch | grep \* | awk '{ print $2 }')
// it its a node module `npm run git-push` will be run after
//

var hookyConfigs = require(argv.c||argv.config);
var publicIp = argv.a||argv.ip||argv.address;
// get a new auth token @ https://github.com/settings/tokens/new

console.log("hooky> startup. ip:",publicIp,", repos:",hookyConfigs);
if(!publicIp || !hookyConfigs.length) {
  console.log('hooky> error both publicIp (-a) and repos required in config');
  process.exit(1);
}

var branches = {}, repos = [];
hookyConfigs.forEach(function(r,i){
  branches[r.repo] = r.branch;
  repos[i] = r.repo;
});
//console.log(repos);console.log(branches);process.exit();

getConfigs(repos,function(errs,configs){
  if(errs) {
    console.log('hooky> error. invalid git repos.',errs);
    process.exit();
  }

  //console.log('\n'+JSON.stringify(configs)+'\n');process.exit();

  var groupedConfigs = groupByAuthToken(hookyConfigs);
  Object.keys(groupedConfigs).forEach(function(githubAuthToken){
  	var hookyConfig = groupedConfigs[githubAuthToken];

  	console.log('new octopie:',publicIp+':'+hookyConfig[0].port);
	  var s = octopie({
	    url:publicIp+':'+hookyConfig[0].port,
	    authToken:githubAuthToken
	  });

	  hookyConfig.forEach(function(repoConfig){
	  	var r = repoConfig.repo;
	    var giturl = configs[r].remote.origin.url;

	    var githubName = giturl.replace(/\.git$/,'');
	    var parts = githubName.split(/[:\/]+/);
	    githubName = parts[parts.length-2]+'/'+parts[parts.length-1];

	    configs[r].github = githubName;
	    console.log('watching ',githubName,'pushes to',branches[r]);
	    s.add(githubName);
	  });

	  s.on('push',function(data){
	    console.log('got a push to ',data.repository.url,' ref ',data.ref);
	    hookyConfig.forEach(function(repoConfig){
	    	var r = repoConfig.repo;
	      var repoPath = '/'+configs[r].github;
	      var url = data.repository.url;

	      if(url.indexOf(repoPath) != url.length-repoPath.length) return;
	      var branch = '/'+branches[r];

	      if(data.ref.indexOf(branch) != data.ref.length-branch.length) return console.log('push to wrong branch.',branch,url,repoPath);

	      console.log('im going to update the code in ',r,branches[r],'!');

	      updateCode(r, branches[r], function(err){
	      	if (err)
	      		return;
	      	if (repoConfig.postScript) {
	      		console.log('running post script...');
	      		proc.exec('/bin/bash '+repoConfig.postScript,function(error,stdout,stderr){
	      			if (error) {
	      				console.log('error running postScript '+repoConfig.postScript);
	      				console.log(stderr);
	      			} else {
	      				console.log('ran postScript '+repoConfig.postScript);
	      				console.log(stdout);
	      			}
	      		});
	      	}
	      });
	    });
	  });

	  s.listen(hookyConfig[0].port,function(err){
	    if(err) {
	      if(err.code || err[0]) {
	        console.log('hooky> error octopie could not listen?',err);
	      }
	    }
	  });

  });


});


function getConfigs(repos,cb){
  var configs = {},errs = false;
  var done = function(err,config,r){
    if(!err) configs[r] = config;
    else {
      if(!errs) errs = {};
      errs[r] = err;
    }
    console.log(c,config);
    if(--c) return;
    cb(errs,configs);
  },c = repos.length;

  repos.forEach(function(r) {
    gitroot(r,function(err,root){
      if(err) return done(err);
      gitconfig(root,function(err,config){
        done(err,config,r);
      });
    });
  });
}


function updateCode(repo, branch, cb){
  //var cmd = "cd "+repo+" && git pull origin $(git branch | grep \\* | awk '{ print $2 }')";
  // @todo: dont npm stuff if no package.json
  //var cmd = "cd "+repo+" && git checkout -f "+branch+" && git pull origin "+branch+" && npm install && npm rebuild";
  var cmd = "cd "+repo+" && git checkout -f "+branch+" && git pull origin "+branch;
  console.log('updating code in ',repo);
  console.log('cmd: ',cmd);

  proc.exec(cmd,function(error, stdout, stderr){
    if(error) {
      console.log('error pulling code');
      console.log(stderr);
    } else {
      console.log('pulled code');
      console.log(stdout);
    }
    if (cb) cb(error);

    var tasks = [
      function(){
        fs.exists(repo+'/package.json',function(exists){
          if(!exists) return console.log('not a node module.');

          var cmd = "cd "+repo+" && npm run git-push";
          console.log('change happened in a node module. attempting to run-script git-push');
          console.log('cmd: ',cmd);

          proc.exec(cmd,function(error,stdout,stderr){
            console.log('ran npm script git-push');
            console.log(stdout);
            console.log(stderr);
            return cb(false,true);
          });
        });
      },
      function(){

      }
    ];

    
  });

}


function groupByAuthToken(configs){
	var grouped = {};
	configs.forEach(function(config){
		if (!grouped[config.githubAuthToken])
			grouped[config.githubAuthToken] = [];
		grouped[config.githubAuthToken].push(config);
	});
	return grouped;
}


