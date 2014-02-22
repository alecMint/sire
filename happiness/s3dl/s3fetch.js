var cp = require('child_process').spawn;
var lru = require('lru-cache');
var ts = require('monotonic-timestamp')
var path = require('path');
var mkdirp = require('mkdirp');
var fs = require('fs');

var cache = lru({max:100});
var pending = {};
var max = 5;
var q = [];

module.exports = function(localDir,bucket,p,cb){
  var targetPath = path.join(localDir,p);
  fs.realpath(targetPath,function(err,fullPath){
    if(fullPath) return cb(false,fullPath)
    fetch(localDir,bucket,targetPath,p,function(err,data){
      if(err) cb(err);
      fs.realpath(targetPath,function(err,fullPath){
        cb(err,fullPath); 
      });
    });
  });
}

module.exports.created = function(targetPath){
  return cache.get(targetPath) || 0;
}

function fetch(localDir,bucket,targetPath,p,cb){
  
  if(pending[targetPath]) return pending[targetPath].push(cb) 
  if(Object.keys(pending).length >= max) return q.push(arguments);

  pending[targetPath] = [cb];
  var tmp = tmpDir(localDir)+'/s3fetch_'+ts().toString(32);
  
  var reallyDone = function(err,data){
    if(q.length) {
      var args = q.shift();
      fetch(args[0],args[1],args[2],args[3]);
    }

    var cbs = pending[targetPath];
    delete pending[targetPath];
    while(cbs.length) cbs.shift()(err,data);
  },done = function(){
    if(--c) return;

    if(code) return reallyDone(code+' '+err);
    moveTmpFile(tmp,targetPath,function(err,stat){
      if (err) return reallyDone(err);
      reallyDone(false,'success '+out,stat);
    });   
  },c = 3,err,out,code = -1;

  var args = ["get","s3://"+path.join(bucket,p),tmp];
  console.log('s3 get> ',args);

  var proc = cp('s3cmd',args).on('exit',function(_code){
    code = _code;
    done();
  });

  var errs = [], outs = [];

  proc.stderr.on('data',function(data){
    errs.push(data);
  }).on('end',function(){
    if(errs.length) err = Buffer.concat(errs);
    done();
  });

  proc.stdout.on('data',function(data){
    outs.push(data);
  }).on('end',function(){
    if(outs.length) out = Buffer.concat(outs);
    done();
  })
}

module.exports.tmpdir = ensureTmpDir;

function tmpDir(local){
  var dir = path.dirname(local), base = path.basename(local);
  var tmpdir = path.join(dir,'tmp_'+base); 
  return tmpdir;
}


function ensureTmpDir(local){
  var tmpdir = tmpDir(local);
  if(fs.existsSync(tmpdir)) return;
  fs.mkdirSync(tmpdir);
}

function moveTmpFile(tmp,targetPath,cb){
  fs.stat(tmp,function(err,stat){
    if (err) return cb(err);
    mkdirp(path.dirname(targetPath),function(err){
      if (err) return cb(err);
      fs.rename(tmp,targetPath,function(err){
        if (err) return cb(err);
        cb(false,stat);
      });
    });
  });
}
