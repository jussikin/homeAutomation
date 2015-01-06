var config = require('config');
var redis = require("redis")
var debug = require('debug')('concentrator')
var util = require('util')
var _=require('lodash')
var Client = require("owfs").Client;
var CronJob = require('cron').CronJob;
var Promise = require('bluebird')
var redisConfig = config.get('redis')

var TYPE_MOVEMENT =    1<<7
var TYPE_1_WIRE_TEMP = 1<<6
var TYPE_UDP_SEND =   1<<5
var TYPE_RAIN =       1<<4
var TYPE_MSPTEMP =    1<<3
var TYPE_SWITCH =     1<<2
var TYPE_ROBOT  =     1<<1
var TYPE_PREASURE =   1

var owcon = new Client(config.get('ow').host,config.get('ow').port);
Promise.promisifyAll(owcon)
var sensors = require('./config/sensors.json')

function getSensorList(){
  return Promise.resolve(sensors)
}

var redisConfig = config.get('redis')
var senderClient = redis.createClient(redisConfig.port,redisConfig.host);

function getAndSaveData(dir,sensor){
  if(dir.length<3)
      return 1
  return owcon.readAsync(dir+"/temperature")
  .then(function (temp){console.log(temp)
  var stringToInsert = temp+":"+sensor.name+
                       ":"+sensor.type+":"+
                       Math.floor(new Date().getTime()/1000)+
                       ":"+sensor.id
  senderClient.hset('sensor',sensor.id,stringToInsert)
}).catch(function (err){
  console.log("got error in saving data!")
  console.log(err)
  return 1
})
}

var CronJob = require('cron').CronJob;
new CronJob('05 * * * * *', function(){
    var p1 = getSensorList()
    var p2 = owcon.dirAsync("/")
    Promise.all([p1,p2])
    .then(function(results){
      var promises = []
      _.each(results[1],function(dir){
        if(dir==undefined) return
        if(dir.length<5) return
        var sensor = _.find(results[0], function(sensori) {
          if(sensori.url.indexOf(dir)>3)
              return true
          return false
        });
        promises.push(getAndSaveData(dir,sensor))
        debug(dir)
        debug(sensor)
      })
      return Promise.all(promises)
    })
    .catch(function (err){
      console.log("Got Error in cronjob!")
      console.log(err)})
    }, null, true);
