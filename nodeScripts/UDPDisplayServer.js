var config = require('config');
var redis = require("redis")
var debug = require('debug')('udpDisplay')
var util = require('util')
var _=require('lodash')
var CronJob = require('cron').CronJob;
var Promise = require('bluebird')
var dgram = require("dgram");
var printf = require('printf')
var trickle = require('timetrickle');
var redisConfig = config.get('redis')

var client = redis.createClient(redisConfig.port,redisConfig.host);
Promise.promisifyAll(client)
var dclient = dgram.createSocket("udp4");
var port = config.get('udp').port
var host = config.get('udp').ip
 

var limit = trickle(1, 1300);

var CronJob = require('cron').CronJob;
new CronJob('15 * * * * *', function(){
    client.hgetallAsync('sensor')
    .then(function (hash){
    //console.log(util.inspect(hash))
    _.forEach(hash, function(sensor) {
      var splitted = sensor.split(":")
      var packedToSend = "XXXXXXXXXXXXXXXXXXX"
      +printf("%02d",splitted[4])+","
      +splitted[0]
      limit(function (){
        var message = new Buffer(packedToSend);
        dclient.send(message, 0, message.length,port , host, function(err, bytes) {})
      })
    })
    var now = new Date()
    var packedToSend = "XXXXXXXXXXXXXXXXXXX"
    +printf("%02d",0)+","
    +printf("%02d%02d",now.getHours(),now.getMinutes())
    limit(function (){
      var message = new Buffer(packedToSend);
      dclient.send(message, 0, message.length,port , host, function(err, bytes) {});
      console.log("packet:"+packedToSend)
    })

    return 1
    })
    .catch(function (err){
      console.log("Got Error in cronjob!")
      console.log(err)})
    }, null, true);
