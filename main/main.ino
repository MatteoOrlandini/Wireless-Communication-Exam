#include <Sodaq_R4X.h>
#include <Sodaq_wdt.h>
#include <Sodaq_LSM303AGR.h>
#include <Sodaq_UBlox_GPS.h>
#include <Wire.h>
#include "ThingSpeak.h"
#include <DHT.h>
/* Parametri per SODAQ SARA AFF R412M*/
#define DEBUG_STREAM SerialUSB
#define MODEM_STREAM Serial1
#define powerPin SARA_ENABLE
#define enablePin SARA_TX_ENABLE
#define DEBUG_STREAM SerialUSB
#define DEBUG_STREAM_BAUD 115200
#define STARTUP_DELAY 15000
//parametri TIM per connessione mqtt
#define CURRENT_APN "nbiot.tids.tim.it"
#define CURRENT_URAT "8"
//parametri per il server cloudmqtt
#define MQTT_SERVER_NAME "test.mosquitto.org"
#define MQTT_SERVER_PORT 1883
#define MQTT_SERVER_CLIENT "jylhjcod"
#define MQTT_SERVER_password "UyFRsdfOp10T"

//DHT22
#define DHTPIN 2 //Pin a cui è connesso il sensore
#define DHTTYPE DHT22 //Tipo di sensore che stiamo utilizzando (DHT22)
DHT dht(DHTPIN, DHTTYPE); //Inizializza oggetto chiamato "dht", parametri: pin a cui è connesso il sensore, tipo di dht
//11/22
//Variabili
float hum; //Variabile in cui verrà inserita la % di umidità
float temp; //Variabile in cui verrà inserita la temperatura
//Z14A
//Request Gas concentration command
const long samplePeriod = 10000L;
const byte requestReading[] = {0xFF, 0x01, 0x86, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79};
byte result[9];
long lastSampleTime = 0;
//SODAQ
static Sodaq_R4X r4x;
static Sodaq_SARA_R4XX_OnOff saraR4xxOnOff;
static bool isReady;

void sendrssiMQTT()
{ 
  int8_t* RSSI_value;
  uint8_t* BER_value;
  // Get the Received Signal Strength Indication in dBm and Bit Error Rate. 
  if (r4x.getRSSIAndBER(RSSI_value, BER_value)) // getRSSIAndBER returns true if successful.
  {
    DEBUG_STREAM.println();
    DEBUG_STREAM.println("Sending message through MQTT");
    //String reading = "{\"RSSI\":{\"value\":" + String(getsegnale()) +"}}";
    String reading = "{\"RSSI\":{\"value\":" + String(*RSSI_value) +"}}";
    uint8_t size = reading.length();
    int lengthSent = r4x.mqttPublish("boh", (uint8_t*)reading.c_str(), size, 0, 0, 1);
    DEBUG_STREAM.print("Length buffer vs sent:");
    DEBUG_STREAM.print(size);
    DEBUG_STREAM.print(",");
    DEBUG_STREAM.println(lengthSent);
    DEBUG_STREAM.println();
  }
  else // getRSSIAndBER returns false if unsuccessful.
    DEBUG_STREAM.println("Unable to get RSSI and BER \n");
}

void setup() {
  sodaq_wdt_safe_delay(STARTUP_DELAY);
  Serial.begin(9600);
  SerialUSB.begin(9600);
  Serial1.begin( 9600, SERIAL_8N1 );
  //SETUP DHT22
  dht.begin();
  Wire.begin();
  //SETUP Z14A
  analogWriteResolution(10); //valgono anche per mq137
  analogReadResolution(12); //e servono per abilitare lettura da porta analogica
  pinMode(A0,INPUT);
  //SETUP MQ137
  pinMode(A1,INPUT);
  //INIZIO LA CONNESSIONE
  DEBUG_STREAM.begin(DEBUG_STREAM_BAUD);
  MODEM_STREAM.begin(r4x.getDefaultBaudrate());
  DEBUG_STREAM.println("Inizializzazione e connessione... ");
  r4x.setDiag(DEBUG_STREAM);
  r4x.init(&saraR4xxOnOff, MODEM_STREAM);
  isReady = r4x.connect(CURRENT_APN, CURRENT_URAT); //per connessione Nb-IoT
  //creo la connessione al cloud server MQTT
  if(isReady){
    isReady=r4x.mqttSetServer(MQTT_SERVER_NAME,MQTT_SERVER_PORT)&&r4x.mqttSetAuth(MQTT_SERVER_CLIENT, MQTT_SERVER_password) && r4x.mqttLogin();
    DEBUG_STREAM.println(isReady ? "MQTT connected" : "MQTT failed");
  }
  else 
    DEBUG_STREAM.println("connection failed");
  //dopo aver terminato il setup della scheda e la connessione invio i dati per la prima volta
  sendrssiMQTT();
  sendDHT22();
  sendZ14A();
  sendMQ137();
}
//SEND DHT22 MQTT
void sendDHT22(){
  hum = dht.readHumidity();
  temp= dht.readTemperature();
  uint8_t size = String(hum).length(); //utilizzo il comando String per passare da dato di tipo float o int a stringa
  uint8_t size2 = String(temp).length();
  //invio dati mqtt
  int lengthSent = r4x.mqttPublish("dht22/temperature", (uint8_t*)String(temp).c_str(), size, 0, 0, 1);
  int lengthSent2 = r4x.mqttPublish("dht22/humidity", (uint8_t*)String(hum).c_str(), size2, 0, 0, 1);
  //stampa a video
  SerialUSB.print("Umidità: ");
  SerialUSB.print(hum);
  SerialUSB.print(" %, Temp: ");
  SerialUSB.print(temp);
  SerialUSB.println(" Celsius");
}

//SEND Z14A MQTT
void sendZ14A()
{
  analogReference(AR_DEFAULT);
  ADC->INPUTCTRL.bit.GAIN = ADC_INPUTCTRL_GAIN_DIV2_Val;
  ADC->REFCTRL.bit.REFSEL = ADC_REFCTRL_REFSEL_INTVCC1;
  delay (1000); //should give the ADC a little bit time to save and apply the settings
  long now = millis();
  if (now > lastSampleTime + samplePeriod) {
  lastSampleTime = now;
  int ppmV = readPPMV();
  //invio dati mqtt
  uint8_t size = String(ppmV).length();
  int lengthSent = r4x.mqttPublish("z14a/ppm", (uint8_t*)String(ppmV).c_str(), size, 0, 0, 1);
  //stampa a video
  SerialUSB.print(ppmV);
  SerialUSB.print(" ppm");
  SerialUSB.print("\n");
  }
}

int readPPMV() {
  float v = analogRead(A0); //* 5.0 / 1023.0;
  int ppm = int((v - 0.4) * 3125.0);
  return v;
}

//SEND MQ137 MQTT
void sendMQ137()
{
  analogReference(AR_DEFAULT);
  ADC->INPUTCTRL.bit.GAIN = ADC_INPUTCTRL_GAIN_DIV2_Val;
  ADC->REFCTRL.bit.REFSEL = ADC_REFCTRL_REFSEL_INTVCC1;
  delay (1000); //ritardo per dare tempo all ADC di salvare e applicare le impostazioni
  float sensor_volt; //Variabile per il voltaggio del sensore
  float RS_air; //Variabile per la resistenza del sensore
  float R0;
  float sensorValue; //Definisce la variabile per la lettura dei valori analogici
  for(int x = 0 ; x < 500 ; x++) //Inizia il loop
  {
    sensorValue = sensorValue + analogRead(A1); //Somma i valori analogici del sensore 500 volte
  }
  sensorValue = sensorValue/500.0; //Prende il valor medio dei dati raccolti
  sensor_volt = sensorValue*(5.0/1023.0); //converte dalla media ai volt
  RS_air = ((5.0*10.0)/sensor_volt)-10.0; //calcolo di RS nell’aria
  R0 = RS_air/3.6; //Calculate R0
  //invio dati mqtt
  uint8_t size = String(R0).length();
  int lengthSent = r4x.mqttPublish("mq137/R0", (uint8_t*)String(R0).c_str(), size, 0, 0, 1);
  //stampa a video
  SerialUSB.print("R0 = "); //Stampa "R0"
  SerialUSB.println(R0); //Stampa valore di R0
  delay(1000); //Aspetto 1 secondo
}

//SEND SDS018 MQTT
void sendSDS018() {
  uint8_t mData = 0;
  uint8_t mPkt[10] = {0};
  uint8_t mCheck = 0;
  if(Serial.available() >0){
    for( int i=0; i<10; ++i ) {
      mPkt[i] = Serial.read();
      Serial.println( mPkt[i], HEX );
      }
    }
  uint8_t pm25Low = mPkt[2];
  uint8_t pm25High = mPkt[3];
  uint8_t pm10Low = mPkt[4];
  uint8_t pm10High = mPkt[5];
  float pm25 = ( ( pm25High * 256.0 ) + pm25Low ) / 10.0;
  float pm10 = ( ( pm10High * 256.0 ) + pm10Low ) / 10.0;
  SerialUSB.print( "PM2.5: " );
  SerialUSB.print( pm25 );
  SerialUSB.print( "\nPM10 :" );
  SerialUSB.print( pm10 );
  SerialUSB.println();
  Serial1.flush();
  uint8_t size = String(pm25).length();
  uint8_t size2 = String(pm10).length();
  //invio dati mqtt
  int lengthSent = r4x.mqttPublish("dht22/pm_2.5", (uint8_t*)String(pm25).c_str(), size, 0, 0, 1);
  int lengthSent2 = r4x.mqttPublish("dht22/pm_10", (uint8_t*)String(pm10).c_str(), size2, 0, 0, 1);
  delay( 10000 );
}

void loop() {
  sodaq_wdt_safe_delay(10000); // invio dati ogni 10s
  sendDHT22();
  sendZ14A();
  sendMQ137();
  sendSDS018();
}
