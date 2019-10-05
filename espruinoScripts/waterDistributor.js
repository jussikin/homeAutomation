
var WIFI_NAME = "name";
var WIFI_OPTIONS = { password : "pw" };
var server = "address";

//Distrubutor solenoids
var BYPASS = B3;
var GREENHOUSE1 = B4;
var GREENHOUSE2 = B6;

//sensors
var G2OWERFLOW = B7;
var state = 'normal';
var STATUS_normal='normal';
var STATUS_greenhouse1='g1';
var STATUS_greenhouse2='g2';
var messageTime = null;
var kicks = 0;

var options = { 
    client_id : "water-automat", 
    keep_alive: 120, 
    port: 1883, 
    clean_session: true, 
    protocol_name: "MQTT", 
    protocol_level: 4,
  };

function setNormalState(){
    state="normal";
    BYPASS.mode('input');
    GREENHOUSE1.mode('input');
    GREENHOUSE2.mode('input');  
}

function setGreenhouse1(){
    state="greenhouse1";
    BYPASS.mode('output');
    BYPASS.write(false);
    GREENHOUSE1.mode('output');
    GREENHOUSE1.write(false);
    GREENHOUSE2.mode('input');  
}

function setGreenhouse2(){
    state="greenhouse2";
    BYPASS.mode('output');
    BYPASS.write(false);
    GREENHOUSE2.mode('output');
    GREENHOUSE2.write(false);
    GREENHOUSE1.mode('input');  
}

var wifi = require("EspruinoWiFi");
var mqtt = require("MQTT").create(server, options);

mqtt.on('connected', function() {
  sendStatus();
  mqtt.subscribe('watering/command');
  mqtt.subscribe('watering/watchdog');
});

mqtt.on('disconnected', function() {
  load();
});

mqtt.on('publish', function (pub) {
  if(pub.topic=='watering/command'){
    if(pub.message=='normal')
      setNormalState();
    if(pub.message=='greenhouse1')
      setGreenhouse1();
    if(pub.message=='greenhouse2')
      setGreenhouse2();
  }
  if(pub.topic=="watering/watchdog"){
    E.kickWatchdog();
    kicks++;
    return;
  }
  sendStatus();
});

function sendStatus(){
  var status = {
   overflow:!(G2OWERFLOW.read()),
   status:state,
    kicks:kicks
  };
  mqtt.publish("watering/status",JSON.stringify(status)); 
}

setInterval(function (){
  sendStatus();
}, 15000);


setWatch(function(e) 
         {sendStatus();}, 
         G2OWERFLOW, { repeat:true, edge:'falling',debounce:100}
        );

function onInit(){
  console.log("on init");
  messageTime = getTime();
  kicks=0;
  G2OWERFLOW.mode('input_pullup');
  setNormalState();
  E.enableWatchdog(25, false);  
  wifi.connect(WIFI_NAME, WIFI_OPTIONS, function(err) {
      if (err) {
        console.log("Connection error: "+err);
        return;
      }
      console.log("Connected!");
      mqtt.connect();
    });
  }