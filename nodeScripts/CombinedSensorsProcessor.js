var config = require('config');
var redis = require("redis")
var debug = require('debug')('Comibnator')
var util = require('util')
var _=require('lodash')
var Client = require("owfs").Client;
var CronJob = require('cron').CronJob;
var Promise = require('bluebird')


var sensors = require('./config/sensors.json')
var redisConfig = config.get('redis')
var senderClient = redis.createClient(redisConfig.port,redisConfig.host);
Promise.promisifyAll(senderClient)

var TYPE_AVG = 1<<6
var FRESHNESS = 600


function doEvaluation(sensordata){
  var combinedSensors = {}
  for(var i=0;i<sensors.length;i++){
    var sensor = sensors[i]
    if(sensor.parent==null)
      continue
    var parentSensor = combinedSensors[sensor.parent]
    if(parentSensor==undefined){
      parentSensor = _.cloneDeep(_.find(sensors,
                                {id:sensor.parent}))
      combinedSensors[sensor.parent] = parentSensor
      parentSensor.siblings=[]
    }
    parentSensor.siblings.push(_.cloneDeep(sensor))
  }
  debug(util.inspect(combinedSensors,{depth: null }))
  _.each(combinedSensors,function (parent){
    parent.time=Math.floor(new Date().getTime()/1000)
    parent.value=undefined
    if(parent.type&TYPE_AVG)
      {
       var sum = 0
       var num = 0
       _.each(parent.siblings, function (sibling){
         var datarow=sensordata[sibling.id]
         var siblingTime = Number(datarow.split(":")[3])
         var siblingValue= Number(datarow.split(":")[0])
         if(parent.time-siblingTime<=FRESHNESS){
           sum=sum+siblingValue
           num++
         }
       })
       if(num>0)
         parent.value=sum/num
      }
    else
      {
        _.each(parent.siblings, function (sibling){
          var datarow=sensordata[sibling.id]
          var siblingTime = Number(datarow.split(":")[3])
          var siblingValue= Number(datarow.split(":")[0])
          if(parent.time-siblingTime<=FRESHNESS){
            if(parent.value ==undefined || parent.value>siblingValue)
              parent.value = siblingValue
          }
        })
      }
    if(parent.value!=undefined){
    var stringToInsert = parent.value+":"+parent.name+
                         ":"+parent.type+":"+
                         parent.time+
                         ":"+parent.id
    senderClient.hset('sensor',parent.id,stringToInsert)
    }
  })
}

var CronJob = require('cron').CronJob;
new CronJob('50 */2 * * * *', function(){
  senderClient.hgetallAsync('sensor')
  .then(function (sensordata){
    doEvaluation(sensordata)})
  .catch(function (err){
    console.log(err.stack)
  })
  }, null, true);
