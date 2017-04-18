#include <DHT.h>
#include "config.h"
#include <PubSubClient.h>
#include <ESP8266WiFi.h>

#define SECONDS_DS(seconds)  ((seconds)*1000000UL)

WiFiClient espClient;
PubSubClient client(espClient);
DHT dht(DHTPIN, DHTTYPE);

long lastMsg=0;
int value =0;
const char* mqtt_server = MQTTSERVER;
char msg[71];
char str_humidity[10], str_temperature[10];

void setup()
{
  pinMode(D0, WAKEUP_PULLUP);
 setup_wifi();
 float h = dht.readHumidity();

}


void setup_wifi() {
  WiFi.begin(WIFINETWORK, WIFIPASSWORD);
  client.setServer(mqtt_server, 1883);
}

void reconnect() {
  while (!client.connected()) {
    String clientId = "ESP8266Client-";
    clientId += String(random(0xffff), HEX);
    // Attempt to connect
    if (client.connect(clientId.c_str())) {
      float h = dht.readHumidity();
    float t = dht.readTemperature();
    dtostrf(h, 1, 2, str_humidity);
    dtostrf(t, 1, 2, str_temperature);
    snprintf (msg, 75, "1,%s,%s",str_humidity,str_temperature);
    client.publish(MQTOPIC, msg);
    int time=55;
    if(ADAPTIVECLAUSE)
      time=time*ADAPTIVEMULTIPLIER;
    delay(3000);
    ESP.deepSleep(SECONDS_DS(time));
    } else {
      delay(2000);
    }
  }
}

void loop() {
   if (!client.connected()) {
    reconnect();
  }
}
