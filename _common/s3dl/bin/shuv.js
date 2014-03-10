#!/usr/bin/env node

var fs = require('graceful-fs')
,argv = require('optimist').argv
;

var localDir = argv.d || argv.dir
,bucket = argv.b || argv.bucket
if(!localDir || !bucket)  throw "both dir and bucket are required!";

readdirR(localDir,function(err,files){
  if (err)
    return console.log('err',err);
  console.log('success',files);
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
            files.push(file);
        }
      });
    });
  });
  function error(err){
    cb(err);
    cb = function(){};
  }
}
