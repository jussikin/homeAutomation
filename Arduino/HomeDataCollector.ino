#include <SPI.h>
#include <Ethernet.h>
#include <EthernetUdp.h>       
#include "DHT.h"
#include <stdlib.h>

#define BUFFSIZE 100
#define DHTPIN 6
#define DHTPIN2 5
#define DHTTYPE DHT22

#define TEMPID 14
#define HUMID 8
#define TEMPID2 18
#define HUMID2 19


DHT dht(DHTPIN, DHTTYPE);
DHT dht2(DHTPIN2, DHTTYPE);

byte mac[] = {  
  0xDE, 0xAD, 0xBE, 0xEF, 0x56, 0xED };
IPAddress ip(10,102,27,111);
IPAddress serverIp(10,102,27,90);
unsigned int serverPort = 8888;

char  sendBuffer[100];      
EthernetUDP Udp;

void setup() {
  Ethernet.begin(mac,ip);
  dht.begin();
  dht2.begin();
  Udp.begin(8888);
}

void sendPacket(int sensorID,float value){
    Udp.beginPacket(serverIp, serverPort);
    char floatString[10];
    dtostrf(value,11,5,floatString);
    snprintf(sendBuffer,100,"%d:%s",sensorID,floatString);
    Udp.write(sendBuffer);
    Udp.endPacket();
}

void loop() {
  float h = dht.readHumidity();
  float t = dht.readTemperature();
  
  if(!isnan(t))
    sendPacket(TEMPID,t);
  if(!isnan(h))  
    sendPacket(HUMID,h);
    
  h = dht2.readHumidity();
  t = dht2.readTemperature();
  
  if(!isnan(t))
    sendPacket(TEMPID2,t);
  if(!isnan(h))  
    sendPacket(HUMID2,h);
  
  delay(10000);
}


