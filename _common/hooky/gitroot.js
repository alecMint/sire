var fs = require('fs');
var parents = require('parents');
var path = require('path');

module.exports = function(dir,cb){
  todo = parents(fs.realpathSync(dir));
  if(!todo || !todo.length) return setImmediate(function(){
    cb(false,false);
  });

  var check = function fn(r){

    fs.exists(path.join(r,'.git'),function(exists){
      if(exists) return cb(false,r);
      
      if(todo.length) fn(todo.shift()); 
      else cb(false,false);
    });
  };

  check(todo.shift());
}




