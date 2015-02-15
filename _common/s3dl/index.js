var http = require('http');
var argv = require('optimist').argv;
var url = require('url');
var fetch = require('./s3fetch');
var watch = require('./s3watch');
var path = require('path');
var mime = require('mime');
var fs = require('fs');
var deleter = require('./s3deleter');

var localDir = argv.d || argv.dir;
var bucket = argv.b || argv.bucket;
var webDir = argv.w || argv.webdir;
var deleteLocal = argv.l || argv.localdel;
var port = argv.p || 9991;

if(!localDir || !webDir || !bucket)  throw "both dir and webdir and bucket are required!";

watch(localDir,bucket,deleteLocal);


var server;
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
  console.log("s3dl running on ",server.address());
});

fetch.tmpdir(localDir);

