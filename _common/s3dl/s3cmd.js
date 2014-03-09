
var cp = require('child_process').spawn
,throttle = 5
,running = 0
,cmds = []

module.exports = function(args,cb){
  cmds.push({
    args: args
    ,cb: cb
  });
  next();
}

function next(){
  //console.log( running, throttle, running>=throttle?'throttling':(cmds[0]?'running':'none left to run') );
  if (running >= throttle || !cmds[0])
    return;
  ++running;
  var c = cmds.shift();
  s3cmd(c.args,function(err,out){
    if (c.cb)
      c.cb(err,out);
    --running;
    next();
  });
}

function s3cmd(args,cb){
  var exitCode ,errs = [] ,outs = [] ,c = 3
  ,proc = cp('s3cmd',args).on('exit',function(code){
    exitCode = code;
    done();
  });
  proc.stderr.on('data',function(data){
    errs.push(data);
  }).on('end',done);
  proc.stdout.on('data',function(data){
    outs.push(data);
  }).on('end',done);
  function done(){
    if (--c)
      return;
    var err = errs.length ? Buffer.concat(errs).toString() : false
    ,out = outs.length ? Buffer.concat(outs).toString() : ''
    if (cb)
      cb( exitCode?exitCode+' '+err:false, out );
  }
  //console.log('s3cmd '+args.join(' '));
}