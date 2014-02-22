
var udid = require('udid');
var knox = require('knox');
var through = require('through');
var ini = require('ini');
var fs = require('fs');
var undef;

module.exports = function(s3key,s3secret,bucket){
  
  var client = knox.createClient({
      key: s3key
    , secret: s3secret
    , bucket: bucket
  });

  var o = {
    id:function(service,host,port){
      return udid(bucket+'!'+service+'!'+host+'!'+port);
    },
    register:function(service,host,port,data,cb){
      if(typeof data === 'function'){
        cb = data;
        data = undef;
      }
      var id = this.id(service,host,port);
      var s = through();
      var buf = new Buffer(JSON.stringify({
        service:service,
        host:host,
        port:port,
        time:Date.now(),
        data:data
      })+"\n");

      var headers = {
        'Content-Length': buf.length
        ,'Content-Type': 'text/plain'
      };

      client.putStream(s,'/'+service+'-'+id+'-'+host+'-'+port,headers,function(err,data){
        cb(err,data);
      });
      s.write(buf);
      s.end();
    },
    list:function(service,cb){
      opts = {};
      if(typeof service == "function"){
        cb = service;
        service = undef;
      }
      if(service) opts.prefix = service;
      client.list(opts,function(err,data){
        // todo list data.
        cb(err,data);
      });
    },
    clean:function(){
      // list and delete service id files where services have not checked in in a while and are not exposed to the world.
    }
  };

  return o;

}



module.exports.s3cfg = function(){
  var cfg = process.env.HOME+'/.s3cfg';
  if(fs.existsSync(cfg)){
    return ini.parse(fs.readFileSync(cfg).toString());
  }
}
