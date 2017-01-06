#include <OneWire.h>
#include <PubSubClient.h>
#include <ESP8266WiFi.h>

// Add missing definitions for WIFI and mq information here
#include "config.h"
#define SECONDS_DS(seconds)  ((seconds)*1000000UL)
#define AMOUNT_SENSORS 20
const char* mqtt_server = SERVERADDRESS;
int numSensors = AMOUNT_SENSORS;
float  sensorValues[AMOUNT_SENSORS];
byte* sendsensors[8];
int sendSensors = 0;
OneWire  ds(ONEWIREPIN);


WiFiClient espClient;
PubSubClient client(espClient);

void setup_wifi() {
  WiFi.begin(WIFIHOTSPOT, WIFIKEY);
  client.setServer(mqtt_server, 1883);
}


void setup() {
  byte addr[8];

  //Serial.begin(9600);
  Serial.println("Starting search now");
  while (ds.search(addr)) {
    Serial.println("Found Sensor.. Addindg it");
    byte *byteArray;
    byteArray = (byte*) malloc (8 * sizeof(byte));
    memcpy(byteArray, addr, 8);
    sendsensors[sendSensors] = byteArray;
    sendSensors++;
    Serial.print("Address:");
    Serial.write(addr, 8);
    Serial.println("");
  }
  Serial.println("setup wifi");
  setup_wifi();
  Serial.print("init done");
}

void readAllSensorsData() {
  byte data[12];
  byte present = 0;
  byte type_s = 0;
  byte first;
  char msg[30];
  char str_temperature[10];

  for (int i = 0; i < sendSensors; i++) {

    Serial.print("Iterating one sensor");
    ds.reset();
    ds.select(sendsensors[i]);
    ds.write(0x44, 1);
    //wait for conversion ready
    delay(1000);
    present = ds.reset();
    ds.select(sendsensors[i]);
    ds.write(0xBE);
    Serial.print("P=");
    Serial.print(present, HEX);
    Serial.print(" ");
    for (int j = 0; j < 9; j++) {           // we need 9 bytes
      data[j] = ds.read();
      Serial.print(data[j], HEX);
      Serial.print(" ");
    }
    Serial.print(" CRC=");
    Serial.print( OneWire::crc8( data, 8), HEX);
    Serial.println();
    int16_t raw = (data[1] << 8) | data[0];
    if (type_s) {
      raw = raw << 3; // 9 bit resolution default
      if (data[7] == 0x10) {
        // "count remain" gives full 12 bit resolution
        raw = (raw & 0xFFF0) + 12 - data[6];
      }
    } else {
      byte cfg = (data[4] & 0x60);
      // at lower res, the low bits are undefined, so let's zero them
      if (cfg == 0x00) raw = raw & ~7;  // 9 bit resolution, 93.75 ms
      else if (cfg == 0x20) raw = raw & ~3; // 10 bit res, 187.5 ms
      else if (cfg == 0x40) raw = raw & ~1; // 11 bit res, 375 ms
      //// default is 12 bit resolution, 750 ms conversion time
    }

    float   celsius = (float)raw / 16.0;
    float  fahrenheit = celsius * 1.8 + 32.0;
    Serial.print("  Temperature = ");
    Serial.print(celsius);
    Serial.print(" Celsius, ");
    Serial.print(fahrenheit);
    Serial.println(" Fahrenheit");
    dtostrf(celsius, 1, 2, str_temperature);
    snprintf (msg, 30, "%d,%s",i,str_temperature);
    client.publish("HVACData", msg);

  }


}

void reconnect() {
  while (!client.connected()) {
    String clientId = "ESP8266Client-";
    clientId += String(random(0xffff), HEX);
    // Attempt to connect
    if (client.connect(clientId.c_str())) {
      //good connection just spew the data and continue
    readAllSensorsData();
    delay(3000);
    ESP.deepSleep(SECONDS_DS(55));
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
