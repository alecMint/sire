#!/usr/bin/env node
// node /root/sire/_common/s3dl/bin/shuv.js -d /var/www/hope/web/wp-content/uploads -b sire-hope/wp-content/uploads

var fs = require('graceful-fs')
,path = require('path')
,s3cmd = require('../s3cmd')
,argv = require('optimist').argv
;

var localDir = argv.d || argv.dir
,bucket = argv.b || argv.bucket
if(!localDir || !bucket)  throw "both dir and bucket are required!";

readdirR(localDir,function(err,files){
  if (err)
    return console.log(err);
  files.forEach(function(file){
    var remotePath = 's3://'+path.join(bucket,file.replace(localDir,''));
    return console.log(remotePath);
    s3cmd(['put',file,remotePath],function(err){
      console.log(err?'ERROR':'SUCCESS',remotePath,err);
    });
  });
});

function readdirR(dir,cb){
  var files = [];
  fs.readdir(dir,function(err,list){
    if (err)
      return error(err);
    if (!list.length)
      return cb(false,[]);
    var scanning = 0;
    list.forEach(function(file){
      ++scanning;
      file = dir+'/'+file;
      fs.stat(file,function(err,stat){
        if (err)
          return error(err);
        if (stat.isDirectory()) {
          readdirR(file,function(err,res){
            if (err)
              return error(err);
            files.push.apply(files,res);
            if (!--scanning)
              cb(false,files);
          });
        } else {
          files.push(file);
          if (!--scanning)
            cb(false,files);
        }
      });
    });
  });
  function error(err){
    cb(err);
    cb = function(){};
  }
}
