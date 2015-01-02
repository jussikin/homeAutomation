var db = require('mysql-promise')();
var config = require('config');
var redis = require("redis")
var debug = require('debug')('concentrator')
var util = require('util')
var _=require('lodash')
var Client = require("owfs").Client;
var CronJob = require('cron').CronJob;
var Promise = require('bluebird')


var TYPE_MOVEMENT =    1<<7
var TYPE_1_WIRE_TEMP = 1<<6
var TYPE_UDP_SEND =   1<<5
var TYPE_RAIN =       1<<4
var TYPE_MSPTEMP =    1<<3
var TYPE_SWITCH =     1<<2
var TYPE_ROBOT  =     1<<1
var TYPE_PREASURE =   1

db.configure(
    config.get('db')
);
var owcon = new Client(config.get('ow').host,config.get('ow').port);

function getSensorList(){
  return db.query('select * from targets')
  .then(function(result){return result[0]})
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

function waitAndActForEventsInRedis(sensorlist){
  client = redis.createClient(redisConfig.port,redisConfig.host);
  var sensolist=sensorlist
  client.on("message", function (channel, message) {
        console.log("client1 channel " + channel + ": " + message);
        var address = parseInt(message.slice(0,2),16)
        var type = parseInt(message.slice(8,10),16)
        console.log("address:"+address)
        console.log("type:"+type)

        if(type & TYPE_1_WIRE_TEMP){
          console.log("sensore is onewire sensor and should be decoded and sent to redis")
          var num1=parseInt(message.slice(2,4))
          var num2=parseInt(message.slice(4,6))
          var temp = num1+(num2/100)
          var sensor = _.find(sensolist, {url:address.toString()});
          var stringToInsert = temp+":"+sensor.name+
                               ":"+sensor.type+":"+
                               Math.floor(new Date().getTime()/1000)+
                               ":"+sensor.id
          senderClient.hset('sensors2',sensor.id,stringToInsert)
          console.log("temp is:"+temp)
          console.log("sensor object is:"+util.inspect(sensor))
          console.log("sensorlist:"+util.inspect(sensolist))
          console.log("string to insert:"+stringToInsert)
        }


  });
    client.on("error", function (err) {
        console.log("Error " + err);
        process.exit(2)
    });



  client.subscribe(redisConfig.radiotopic)
}

function waitAndActForUDPEvents(sensorlist){
  debug('Start waiting for UDP Events:'+util.inspect(sensorlist))

}

getSensorList().then(function (result){
  console.log(result)
  waitAndActForEventsInRedis(result)
  waitAndActForUDPEvents(result)
})
.catch(function (err){
  console.log(err)
  process.exit(1)
})
