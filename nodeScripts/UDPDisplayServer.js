var db = require('mysql-promise')();
var config = require('config');
var redis = require("redis")
var debug = require('debug')('udpDisplay')
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

db.configure(
    config.get('db')
);
var redisConfig = config.get('redis')

var client = redis.createClient(redisConfig.port,redisConfig.host);
Promise.promisifyAll(client)


var CronJob = require('cron').CronJob;
new CronJob('15 * * * * *', function(){
    client.hgetallAsync('sensor')
    .then(function (hash){
    console.log(util.inspect(hash))
    return 1
    })
    .catch(function (err){
      console.log("Got Error in cronjob!")
      console.log(err)})
    }, null, true);
