var nrf = require('nrf')
var radio = nrf.connect("/dev/spidev0.0", 18)
var mqtt    = require('mqtt');
var mqclient  = mqtt.connect();
var redis = require("redis"),
redisclient = redis.createClient();
require('buffertools').extend();

radio.channel(0,function(err){
	if(err)console.log(err)
})
radio.dataRate('250kbps')
radio.autoRetransmit({count:0}) 
radio.crcBytes(1)

radio.begin(function () {
   console.log("radio ready, begin receiwing")
    var rx = radio.openPipe('rx',0x6161616161,{size:5,autoAck:false})
    rx.on('data', function(chunk) {
	chunk.reverse()
	//console.log(chunk)
	var asHex = chunk.toString('hex')
	redisclient.publish('radiodata',asHex)
	mqclient.publish('radio/data',asHex)
    	console.log(asHex+":"+new Date())
    });
});

/*
setInterval(function(){
	radio.printDetails();
}, 20000)
*/