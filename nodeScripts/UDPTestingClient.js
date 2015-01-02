var db = require('mysql-promise')();
var config = require('config');
var redis = require("redis")
var debug = require('debug')('concentrator')
var util = require('util')
var _=require('lodash')
var Client = require("owfs").Client;
var CronJob = require('cron').CronJob;
var Promise = require('bluebird')
var dgram = require("dgram");
var celeri = require("celeri");

var TYPE_MOVEMENT =    1<<7
var TYPE_1_WIRE_TEMP = 1<<6
var TYPE_UDP_SEND =   1<<5
var TYPE_RAIN =       1<<4
var TYPE_MSPTEMP =    1<<3
var TYPE_SWITCH =     1<<2
var TYPE_ROBOT  =     1<<1
var TYPE_PREASURE =   1



var client = dgram.createSocket("udp4");

celeri.option({
    command: 'send :package',
    description: 'Sends udp package to server with package as an payload',
    optional: {
        '--host': 'host to send package to',
        '--port': 'port to send package to'
    }}, function(data) {
   console.log(data)
   var port = config.get('udp').port
   var host = config.get('udp').host
   if(data.host)
    host=data.host
   if(data.port)
     port=data.port
   var message = new Buffer(data.package);
   client.send(message, 0, message.length,port , host, function(err, bytes) {
   client.close();});
});

celeri.parse(process.argv);
