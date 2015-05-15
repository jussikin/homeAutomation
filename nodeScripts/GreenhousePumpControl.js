var config = require('config')
var redis = require('redis')
var debug = require('debug')('greenhousePump')
var util = require('util')
var mqtt    = require('mqtt');

var redisConfig = config.get('redis')
var mqttConfig = config.get('mqtt')
var client  = mqtt.connect(mqttConfig.address);

function setShutdown(){
    setTimeout(function(){
        console.log("Stopping now!");
        process.exit(0);
    },20000);
}

client.on("error", function (err) {
        console.log("Error " + err);
});

var client2 = redis.createClient(redisConfig.port,redisConfig.host);
client.on("error", function (err) {
        console.log("Error " + err);
});


var preflight = true;
var turnedON = false;
var disabled = false;

client.on("message", function (channel, message) {
     if(preflight){
       if(message=="HIGH"){
         console.log('container allready full, exiting now');
         process.exit(1);
       }
       preflight = false;
     }
     if(disabled) return;

     if(!turnedON){
         if(message == "LOW"){
             turnedON=true;
             client2.publish('tellduscmd','4:ON');
             console.log('turn water on untill switch or timeout!!');
             setTimeout(function (){
                 disabled = true;
                 turnedON = false;
                 client2.publish('tellduscmd','4:OFF');
                 console.log('turned off by timeout');
                 client2.publish('tellduscmd','4:OFF');
                 setShutdown();
             },180000 );
         }
     }
     if(turnedON && message == "HIGH"){
         disabled = true;
         turnedON = false;
         client2.publish('tellduscmd','4:OFF');
         console.log('turned off by sensing owerflow');
         client2.publish('tellduscmd','4:OFF');
         setShutdown();
     }
 });

client.subscribe('data/waterlevel');
