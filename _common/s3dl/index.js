var http = require('http');
var argv = require('optimist').argv;
var url = require('url');
var fetch = require('./s3fetch');
var watch = require('./s3watch');
var path = require('path');
var mime = require('mime');
var fs = require('fs');
var deleter = require('./s3deleter');
var fs = require('fs');
var cp = require('child_process');

var localDir = argv.d || argv.dir;
var bucket = argv.b || argv.bucket;
var webDir = argv.w || argv.webdir;
var deleteLocal = argv.l || argv.localdel;
var portConfig = getPortConfig(argv.p,9991);

if(!localDir || !webDir || !bucket)  throw "both dir and webdir and bucket are required!";

console.log(new Date,'watch',localDir,bucket,deleteLocal,portConfig);
watch(localDir,bucket,deleteLocal);


var server;
function createServer(port){
	portConfig.attempting = port;
	server = http.createServer(function(req,res){
	  var inWebDir = false;
	  if (req.url.indexOf(webDir) == 0) {
	    inWebDir = true;
	    req.url = req.url.replace(webDir,'');
	  }

	  var parsed = url.parse(req.url,true);
	  var targetFile = parsed.path;


	  fetch(localDir,bucket,parsed.path,function(err,name){

	    var o = {};
	    if(err) o.error = err+'';
	    o.data = name;

	    if (inWebDir) {
	      if (err) {
	        res.writeHead(404,{
	          //'xerr': err+' '+localDir+' '+bucket+' '+req.url
	          'xerr': err
	        });
	        return res.end('');
	      }

	      res.setHeader('xyay',1);

	      var qs = parsed.query||{};
	      if(req.url.indexOf(".php") == req.url.length-4) {
	        qs.path = true;// for php files never return file contents.  
	      }

	      if(qs.path) {
	        // send data.
	        res.end(JSON.stringify(o)+"\n");
	      } else {

	        res.setHeader('Content-Type',mime.lookup(req.url));
	        fs.createReadStream(name).pipe(res).on('finish',function(){
	          if (!deleteLocal)
	            return;
	          // wait until we're sure we read the whole file
	          console.log('deleter()',name,'s3://'+path.join(bucket,req.url));
	          deleter(name, 's3://'+path.join(bucket,req.url));
	        });
	      }
	    } else {
	      res.end(JSON.stringify(o)+"\n");
	    }

	  });
	}).listen(port,'127.0.0.1',function(){// only listen on localhost
	  console.log("s3dl running on ",server.address(),new Date);
	});
	server.on('listening',function(){
		if (!portConfig.nginxCnf)
			return console.log('nginxCnf not passed',portConfig);
		var cnf = fs.readFileSync(portConfig.nginxCnf);
		console.log(cnf);
		var re = new RegExp('proxy_pass http://localhost:'+portConfig.target+';','g');
		var newCnf = cnf.replace(re, 'proxy_pass http://localhost:'+portConfig.attempting+';');
		console.log(newCnf);
		fs.writeFileSync(portConfig.nginxCnf, newCnf);
		cp.spawn('/etc/init.d/nginx','reload');
	});
}
createServer(portConfig.target);
process.on('uncaughtException',function(err){
	if (!(err.syscall == 'listen' && err.code == 'EADDRINUSE' && portConfig.altPorts))
		throw err;
	if (portConfig.attempted && ++portConfig.numAttempted >= portConfig.numAttemptable)
		throw new Error('alt ports depleted; '+JSON.stringify(portConfig));
	var nextPort = portConfig.attempting+1;
	if (!portConfig.attempted) {
		portConfig.attempted = {};
		portConfig.numAttemptable = portConfig.altPorts[1]-portConfig.altPorts[0];
		if (portConfig.numAttemptable <= 0)
			throw err;
		if (portConfig.target < portConfig.altPorts[0] || portConfig.target > portConfig.altPorts[1])
			++portConfig.numAttemptable;
		portConfig.numAttempted = 1;
		if ((nextPort = portConfig.altPorts[0]+Math.round(Math.random()*portConfig.numAttemptable)) == portConfig.altPorts[0])
			++nextPort;
	}
	if (nextPort == portConfig.target || nextPort > portConfig.altPorts[1])
		nextPort = portConfig.altPorts[0];
	console.log('EADDRINUSE','nextPort',nextPort,'portConfig',JSON.stringify(portConfig));
	createServer(nextPort);
});

fetch.tmpdir(localDir);



function getPortConfig(arg, defaultPort){
	if (!arg)
		return {target:defaultPort};
	if (typeof arg != 'string' || arg.indexOf(',') == -1)
		return {target:+arg};
	var m = arg.match(/([0-9]+),([0-9]+)-([0-9]+),(.+)/);
	if (!m && m[4])
		return {target:defaultPort};
	return {
		target: +m[1]
		,altPorts: [+m[2], +m[3]]
		,nginxCnf: m[4]
	}
}


