var watch = require('watch');
var fetch = require('./s3fetch');
var cp = require('child_process').spawn;
var path = require('path');
var deleter = require('./s3deleter');

var pending = {};

module.exports = function(localdir,bucket){
  return watch.watchTree(localdir, function (f, curr, prev) {
    if (typeof f == "object" && prev === null && curr === null) {
      // Finished walking the tree
    } else if (prev === null) {
      var lastCreate = fetch.created(f)||0;
      if(Date.now()-lastCreate > 5000) {  
        // f is a new file and i was not just fetched
        // could change this to check md5 5 seconds is a long time and will create inconstsencies 
        // for any opperations which add and remove files at a greater interval
        put(f,localdir,bucket,function(err){
          if(err) console.error('error putting> ',f,err);
        });
      } else {
        console.log('ignore> just downloaded it');
      }
    } else if (curr.nlink === 0) {
      // f was removed
      // i dont know what 
    } else {
      if(f.indexOf('/log/') > -1) return;

      // f was changed and is not a log
      // i better sync it..
      put(f,localdir,bucket,function(err){
        if(err) console.error('error putting changed> ',f,err);
      })      
    }
  });
}


module.exports.put = put;

// s3cmd limit distinct files at a time.
var max = 5;
// if im asked to do more than max.
var q = [];

function put(localfile,localdir,bucket,cb){

  if(pending[localfile]) return pending[localfile].push(cb);
  if(Object.keys(pending).length >= max) return q.push(arguments);

  pending[localfile] = [cb];

  console.log(bucket,localfile,localdir);
  var args = ["put",localfile,'s3://'+path.join(bucket,localfile.replace(localdir,''))];

  var done = function(){
    if(--c) return;
    var cbs = pending[localfile];
    delete pending[localfile]
    if(cbs.length > 1){
      put(localfile,localdir,bucket,cbs.pop());
    } else if(q.length){
      var args = q.shift();
      put(args[0],args[1],args[2],args[3]);
    }
    err = code?'err: ('+code+') '+Buffer.concat(err):false;
    data = out.length?Buffer.concat(out)+'':false;

    if (!err) {
      console.log('deleter()',localfile,'s3://'+path.join(bucket,localfile.replace(localdir,'')));
      deleter(localfile, 's3://'+path.join(bucket,localfile.replace(localdir,'')));
    }

    while(cbs.length) {
      cbs.shift()(err,data);
    }   
  }, c = 3, code = -1;

  console.log('s3 put >',args);
  var p = cp('s3cmd',args).on('exit',function(_code){
    code = _code;
    done()
  });

  var err = [], out = [];
  p.stderr.on('data',function(data){
    err.push(data);
  }).on('end',function(){
    done();
  });
 
  p.stdout.on('data',function(data){
    out.push(data);
  }).on('end',function(){
    done();
  });

}


