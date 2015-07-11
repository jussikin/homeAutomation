#define  WOL_client YES

#include <EtherShield.h>
#include <SPI.h>
#include <OneWire.h>
#include <TM1638.h>
#include <avr/wdt.h>

#define MYUDPPORT 8888
#define SERVERUDPPORT 8888
#define AMOUNT_SENSORS 20
#define DATAOFFSET 19

#define BUFFER_SIZE 150
static uint8_t buf[BUFFER_SIZE+1];


int numSensors = AMOUNT_SENSORS;
int mode=1;
boolean valueChanged=false;
float  sensorValues[AMOUNT_SENSORS];
String time;

static uint8_t mymac[6] = { 0x54,0x55,0x58,0x12,0x34,0x56 };
static uint8_t myip[4] = { 10,102,27,110};
static uint8_t websrvip[4] = { 10, 102, 27, 90 };
//jussinkone
static uint8_t wolmac3[6] = { 0x40,0x61,0x86,0xC7,0x69,0x44 };
//palvelin 1
static uint8_t wolmac[6] = { 0x00,0x22,0x15,0xCF,0xD2,0x20 };
static uint8_t wolmac2[6] = { 0x00,0x30,0x84,0x0F,0x5B,0xBE };
static int8_t dns_state=0;

EtherShield es=EtherShield();
OneWire  ds(5);
TM1638 module(3, 2, 4);
long stabCount=0;
int sendSensors = 0;
int sensorToProcess=AMOUNT_SENSORS;
byte* sendsensors[8];


static uint8_t broadcastip[4] = {
  10,102,27,90};

// Port 8888
#define DEST_PORT_L  0xB8
#define DEST_PORT_H  0x22

const char iphdr[] PROGMEM ={
  0x45,0,0,0x82,0,0,0x40,0,0x20};
  
struct UDPPayload {
  char data[60];        //string of data
};

UDPPayload udpPayload;
uint8_t  srcport = 11023;



void setup() {
  module.setupDisplay(true,1);
  module.setDisplayToString("init");
  //Serial.begin(9600);
  delay(1000);
  byte addr[8];
  int i;
  
  es.ES_enc28j60SpiInit();  
  es.ES_enc28j60DisableMulticast();
  es.ES_enc28j60Init(mymac);
  es.ES_init_ip_arp_udp_tcp(mymac,myip, MYUDPPORT);
  module.clearDisplay();
  module.setDisplayToString("one-s");
  
  while(ds.search(addr)){
    module.clearDisplay();
    byte *byteArray;
    module.setDisplayToString("one-a");
    byteArray = (byte*) malloc (8 * sizeof(byte));
    memcpy(byteArray,addr,8);
    sendsensors[sendSensors]=byteArray;
    sendSensors++;
    //Serial.println("Found Sensor.. Addindg it");
    //Serial.print("Address:");
    //Serial.write(addr,8);
    //Serial.println("");
    
    delay(10000);
    module.clearDisplay();
    module.setDisplayToString("one-s");    
  }
  wdt_enable(WDTO_8S);

}
void putFloatIntoDisplay(float toPut, int toByte, int maxLength){
   char printed[9];
   dtostrf(toPut,maxLength+1,2,printed);
   putDecInModuleFromString(printed,toByte,maxLength);
}



void putDecInModuleFromString(String toPut,int toByte,int maxAmount){
    int cur=0;
    int byteToPut = toByte;
    int bytesLeft = toPut.length();
    if(bytesLeft>maxAmount){
      bytesLeft=maxAmount;
    }
    
    while(byteToPut<8 && bytesLeft>0){
        if(toPut.charAt(cur+1)=='.' && byteToPut!=7 && bytesLeft>1){
          module.setDisplayDigit(toPut.charAt(cur), byteToPut, true);
          cur++; 
        } else{
           module.setDisplayDigit(toPut[cur], byteToPut, false);
        }      
        cur++;
        byteToPut++;
        bytesLeft--;
    }  
}

void loop(){
  long timetosend;
  long curTime;
  int curNumOnewire = 0;
  long timeConversionReady;
  boolean ongoingConversion = false;
  byte data[12];
  int HighByte, LowByte, TReading, SignBit, Tc_100, Whole, Fract;
  int Count_Per_C,Count_Remain;
  
  
  uint16_t dat_p;
  int sec = 0;
  long lastDnsRequest = 0L;
  int plen = 0;
  boolean modeChanged=true;
  
  curTime = millis();
  timetosend=curTime+(10*1000); 
  while(1) {
    wdt_reset();
   
    
    
    plen = es.ES_enc28j60PacketReceive(BUFFER_SIZE, buf);
    dat_p=es.ES_packetloop_icmp_tcp(buf,plen);
    
    if(plen>0){ 
      unsigned int ad= *(buf+UDP_DST_PORT_H_P);  
      unsigned int port = 0;
      port=ad;
      port=port<<8;
      ad = *(buf+UDP_DST_PORT_L_P);     
      port=port+ad;
      if(port==MYUDPPORT){
        ad = *(buf+UDP_LEN_H_P);
        int payloadLength = ad<<8;
        ad = *(buf+UDP_LEN_L_P);
        payloadLength =  payloadLength+ad;
       
        char idc[3];
        strlcpy(idc,(char*) buf+UDP_DATA_P+DATAOFFSET,3);
        int i = atoi(idc);
 
 
        int lentti = 2;
        int maxCopy = payloadLength-lentti-UDP_HEADER_LEN-DATAOFFSET;
        if(maxCopy>15) 
            maxCopy=15;
        char toTime[15];
        strlcpy(toTime,(char*) buf+UDP_DATA_P+lentti+1+DATAOFFSET,maxCopy);
        if(i==0)
           time = String(toTime);             
        else
           sensorValues[i]=atof(toTime);        
         valueChanged=true;
                   
        }
      }
     
    
    byte keys = module.getButtons();
    if(keys!=0){
      mode=keys;
      modeChanged=true;
    }
    if(modeChanged){
      module.clearDisplay();
      modeChanged=false;
      valueChanged=true;
      module.setLEDs(mode); 
    }
    if(valueChanged){
      valueChanged=false;
      
      switch (mode){
        //kello & Ulko
        case 1:
             putDecInModuleFromString(time,0,4);
             if(sensorValues[2]<0)
               putFloatIntoDisplay(sensorValues[2],4,4);
             else{
               module.setDisplayDigit(32, 4, false);
               putFloatIntoDisplay(sensorValues[2],5,3); 
             }           
             break;
        //kello & Makkari
        case 2:
              putDecInModuleFromString(time,0,4);
             module.setDisplayDigit(32, 4, false); 
             putFloatIntoDisplay(sensorValues[5],5,3); 
              break;
        //kello & Olohuone
        case 4:
            putDecInModuleFromString(time,0,4);
            module.setDisplayDigit(32, 4, false);
            putFloatIntoDisplay(sensorValues[12],5,3);                         
             break;
        case 8:
           //Kello & Lämmitys
            putDecInModuleFromString(time,0,4);
            module.setDisplayDigit(32, 4, false);
            putFloatIntoDisplay(sensorValues[13],5,3);             
          break;
        case 16:
           //Kello & Yläkerta
             putDecInModuleFromString(time,0,4);
             module.setDisplayDigit(32, 4, false);
            putFloatIntoDisplay(sensorValues[9],5,3);                   
             break;
        case 32:
           //Kuisti & ja Hoito
            putFloatIntoDisplay(sensorValues[11],0,4);
            module.setDisplayDigit(32, 4, false);  
            putFloatIntoDisplay(sensorValues[1],5,3);                             
          break;
          //Mokin kosteus ja lampo
          case 64:
            putFloatIntoDisplay(sensorValues[8],0,4);
            module.setDisplayDigit(32, 4, false);  
            putFloatIntoDisplay(sensorValues[14],5,3);  
           break;
         case 128:
            module.clearDisplay();
            module.setDisplayDigit('U', 0, false);
            module.setDisplayDigit('P', 1, false);
            module.setDisplayDigit('1', 7, false);
            es.ES_send_wol( buf, wolmac );
            wdt_reset();            
            delay(5000);
            wdt_reset(); 
            module.setDisplayDigit('2', 7, false); 
            es.ES_send_wol( buf, wolmac2 );
            delay(5000);
            wdt_reset();
            module.setDisplayDigit('3', 7, false); 
            es.ES_send_wol( buf, wolmac3 );
              delay(5000);
            wdt_reset();
            mode=1;  
            break;
        default:
          module.setDisplayToDecNumber( mode, 0)  ; 
      }
      
    }
     curTime = millis();
    //one wire app here
    if(timetosend<=curTime){
       //Serial.print("Time to read sensor data on device:");
       //Serial.write(sendsensors[curNumOnewire],8);
       //Serial.println("");
      ds.reset();
      ds.select(sendsensors[curNumOnewire]);
      
      ds.write(0x44,1);
      timetosend=curTime+(10*1000);
      timeConversionReady=curTime+1000;
      ongoingConversion=true;
    }  
    if(ongoingConversion && timeConversionReady<curTime){
        ds.reset();
        ds.select(sendsensors[curNumOnewire]);
        ds.write(0xBE);
        int i;
        for ( i = 0; i < 9; i++) {           
            data[i] = ds.read();  
        }
        //Serial.println("ongoing conversion");
        LowByte = data[0];
        HighByte = data[1];
        TReading = (HighByte << 8) + LowByte;
        SignBit = TReading & 0x8000;  // test most sig bit
        if (SignBit) // negative
        {
            TReading = (TReading ^ 0xffff) + 1; // 2's comp
            TReading = TReading*-1;
        }
        TReading = TReading>>1;
        TReading = TReading<<1;
        //Tc_100 = (6 * TReading) + (TReading / 4);    // multiply by (100 * 0.0625) or 6.2
        Tc_100 = (TReading*100/2);
        
        /*Extented bytes described in dataSheets*/
        Tc_100 = Tc_100-25;
        Count_Remain = data[6];
        Count_Per_C = data[7];
        Count_Remain = Count_Remain*100;
         Count_Per_C = Count_Per_C*100;
        
        int correctionAmount = (Count_Per_C-Count_Remain)/  data[7];
        Tc_100 = Tc_100+ correctionAmount;
        
        Whole = Tc_100 / 100;  // separate off the whole and fractional portions
        //Whole = TReading>>4;
        Fract = Tc_100 % 100;
        if(Fract<0)
          Fract=Fract*-1;
        //Fract = 0;
        char sensorID[30]="test";
        snprintf(sensorID,30,"%02X%02X%02X%02X%02X%02X%02X%02X",(unsigned)sendsensors[curNumOnewire][0],
                                                               (unsigned)sendsensors[curNumOnewire][1],
                                                               (unsigned)sendsensors[curNumOnewire][2],
                                                               (unsigned)sendsensors[curNumOnewire][3],
                                                               (unsigned)sendsensors[curNumOnewire][4],
                                                              (unsigned)sendsensors[curNumOnewire][5],
                                                               (unsigned)sendsensors[curNumOnewire][6],
                                                               (unsigned)sendsensors[curNumOnewire][7]
                                                               );
        
        snprintf(udpPayload.data,60,"%s:%d.%02d:",sensorID,Whole,Fract);
         
        ////Serial.println("Trying to send upd");
        broadcastData() ;
        //Serial.println("upd sent");
        //Serial.println(Whole);
        curNumOnewire++;
        if(curNumOnewire>=sendSensors)
          curNumOnewire=0;
        //Serial.println("conversion done");
        ongoingConversion=false;
    }
    
  } 
}

void broadcastData( void ) {
  uint8_t i=0;
  uint16_t ck;
  // Setup the MAC addresses for ethernet header
  while(i<6){
    buf[ETH_DST_MAC +i]= 0xff; // Broadcsat address
    buf[ETH_SRC_MAC +i]=mymac[i];
    i++;
  }
  buf[ETH_TYPE_H_P] = ETHTYPE_IP_H_V;
  buf[ETH_TYPE_L_P] = ETHTYPE_IP_L_V;
  es.ES_fill_buf_p(&buf[IP_P],9,iphdr);

  // IP Header
  buf[IP_TOTLEN_L_P]=28+sizeof(UDPPayload);
  buf[IP_PROTO_P]=IP_PROTO_UDP_V;
  i=0;
  while(i<4){
    buf[IP_DST_P+i]=broadcastip[i];
    buf[IP_SRC_P+i]=myip[i];
    i++;
  }
  es.ES_fill_ip_hdr_checksum(buf);
  buf[UDP_DST_PORT_H_P]=DEST_PORT_H;
  buf[UDP_DST_PORT_L_P]=DEST_PORT_L;
  buf[UDP_SRC_PORT_H_P]=10;
  buf[UDP_SRC_PORT_L_P]=srcport; // lower 8 bit of src port
  buf[UDP_LEN_H_P]=0;
  buf[UDP_LEN_L_P]=8+sizeof(UDPPayload); // fixed len
  // zero the checksum
  buf[UDP_CHECKSUM_H_P]=0;
  buf[UDP_CHECKSUM_L_P]=0;
  // copy the data:
  i=0;
  // most fields are zero, here we zero everything and fill later
  uint8_t* b = (uint8_t*)&udpPayload;
  while(i< sizeof( UDPPayload ) ){ 
    buf[UDP_DATA_P+i]=*b++;
    i++;
  }
  // Create correct checksum
  ck=es.ES_checksum(&buf[IP_SRC_P], 16 + sizeof( UDPPayload ),1);
  buf[UDP_CHECKSUM_H_P]=ck>>8;
  buf[UDP_CHECKSUM_L_P]=ck& 0xff;
  es.ES_enc28j60PacketSend(42 + sizeof( UDPPayload ), buf);
}
