var config = require('config');
var redis = require("redis")
var debug = require('debug')('UDPconcentrator')
var util = require('util')
var _=require('lodash')
var Client = require("owfs").Client;
var CronJob = require('cron').CronJob;
var Promise = require('bluebird')
var dgram = require("dgram");

var TYPE_MOVEMENT =    1<<7
var TYPE_1_WIRE_TEMP = 1<<6
var TYPE_UDP_SEND =   1<<5
var TYPE_RAIN =       1<<4
var TYPE_MSPTEMP =    1<<3
var TYPE_SWITCH =     1<<2
var TYPE_ROBOT  =     1<<1
var TYPE_PREASURE =   1

var sensors = require('./config/sensors.json')
function getSensorList(){
  return Promise.resolve(sensors)
}


var redisConfig = config.get('redis')
var senderClient = redis.createClient(redisConfig.port,redisConfig.host);


function getOWDIR(){
    return new Promise(function (resolve,reject){
      owcon.dir("/",function(err, directories){
      if(err)
        reject(err)
      resolve(directories)
    })
    })
}

function waitAndActForUDPEvents(sensorlist){
  debug('Start waiting for UDP Events:'+util.inspect(sensorlist))
  var server = dgram.createSocket("udp4");

  server.on("error", function (err) {
    console.log("server error:\n" + err.stack);
    server.close();
  });

  server.on("message", function (msg, rinfo) {
    console.log("server got: " + msg + " from " +rinfo.address + ":" + rinfo.port);
    var splitted = msg.toString().split(':')
    var id = splitted[0].trim()
    if(splitted[1]==undefined){
      console.log("cannot interpered msg:"+msg)
      return
    }


    var value = splitted[1].trim()
    getSensorList().then(function (sensorlist){
        var sensor = _.find(sensorlist, function(sensori) {
          if(sensori.url==id)
              return true
          return false
        })
	if(sensor==undefined)
	    sensor = _.find(sensorlist, function(sensori) {
		if(sensori.id==id)
		    return true
		return false
            })

        if(sensor==undefined) return
        console.log('id:'+id)
        console.log('value:'+value)
        console.log('sensor:'+util.inspect(sensor))
        var stringToInsert = value+":"+sensor.name+
                             ":"+sensor.type+":"+
                             Math.floor(new Date().getTime()/1000)+
                             ":"+sensor.id
        senderClient.hset('sensor',sensor.id,stringToInsert)
    })
  });

  server.on("listening", function () {
    var address = server.address();
    console.log("server listening " +
        address.address + ":" + address.port);
  });

  server.bind(config.get('udp').port);
}

getSensorList().then(function (result){
  waitAndActForUDPEvents(result)
})
.catch(function (err){
  process.exit(1)
})
