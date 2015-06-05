var config = require('config')
var redis = require('redis');

var multiplier = 0.001;
var lastTick = 0;
var doingFirst = true;

var doingFirstFlow = true;
var lastTickFlow = 0;

var redisConfig = config.get('redis')
var client = redis.createClient(redisConfig.port,redisConfig.host);

client.on("error", function (err) {
        console.log("Error " + err);
});


function doTheStrut(){
  console.log(new Date());
  client.get('rainsensor',function(err,reply){
        var num=reply.toString()
        console.log(num);
         if(doingFirst){
                lastTick=num;
        }
        var diff = num - lastTick;
        if(diff<0){
            diff = 0;
        }
        console.log("difference:"+diff);
        doingFirst=false;
        lastTick=num;
        var millisRain = diff*multiplier;
        console.log("millis of rain in 5 minutes:"+millisRain);
        client.hset("sensor","15",millisRain+":sademaara:384:"+new Date().getTime().toString().replace(/\d\d\d$/,'')+":15");
  });

  client.get('flowamount',function(err,reply){
        var num=reply.toString()
        console.log(num);
         if(doingFirstFlow){
                lastTickFlow=num;
        }
        var diff = num - lastTickFlow;
        if(diff<0){
            diff = 0;
        }
        console.log("difference:"+diff);
        doingFirstFlow=false;
        lastTickFlow=num;
        var millisRain = diff*multiplier;
        console.log("millis of flow in 5 minutes:"+millisRain);
        client.hset("sensor","24",millisRain+":waterflow:384:"+new Date().getTime().toString().replace(/\d\d\d$/,'')+":15");
  });

}

var CronJob = require('cron').CronJob;
new CronJob('0 */5 * * * *', function(){
    doTheStrut();
}, null, true, "America/Los_Angeles");
