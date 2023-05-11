#include "FS.h"
#include "esp_system.h"
#include <esp_wifi.h>
#include <string.h>
#include <WiFi.h>
#include <Preferences.h> 
#include <WiFiClientSecure.h>
#include <MQTTPubSubClient.h>
#include <ArduinoJson.h>
#include "EmonLib.h"             // Include Emon Library
// define oled display
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <DHT.h>
#include <Fonts/FreeSerif9pt7b.h>

#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels

#define OLED_RESET     -1 // Reset pin # (or -1 if sharing Arduino reset pin)
#define SCREEN_ADDRESS 0x3C ///< See datasheet for Address; 0x3D for 128x64, 0x3C for 128x32




#define SN getMacAddress()
#define MQTT_TOPIC_U    getMacAddress()+"_U"
#define MQTT_TOPIC_D    getMacAddress()+"_D"
#define MQTT_WILL_TOPIC MQTT_TOPIC
#define MQTT_WILL_MSG   "Disconnect" 
#define MQTT_RPC_TOPIC  "v1/devices/me/attributes"

#define default_ssid "HTPro-T1"
#define default_pass "Ht8888888"


#define RELAY1 12
#define RELAY2 14
#define RELAY3 27
#define RELAY4 26

#define DHTPIN 25     // what pin we're connected to
#define DHTTYPE DHT22   // DHT 22  (AM2302)

EnergyMonitor emon1; 



void ON_RELAY(int i);
void OFF_RELAY(int i);
void CONTROL_RELAY_FROM_DATA(int i);
void testdrawrect(void);


 void ON_RELAY(int i)
 {
  switch(i){
    case 1:
    digitalWrite(RELAY1, HIGH);
    break;
    case 2:
    digitalWrite(RELAY2, HIGH);
    break;
    case 3:
    digitalWrite(RELAY3, HIGH);
    break;
    case 4:
    digitalWrite(RELAY4, HIGH);
    break;
    }
 }
 void OFF_RELAY(int i)
 {
  switch(i){
    case 1:
    digitalWrite(RELAY1, LOW);
    break;
    case 2:
    digitalWrite(RELAY2, LOW);
    break;
    case 3:
    digitalWrite(RELAY3, LOW);
    break;
    case 4:
    digitalWrite(RELAY4, LOW);
    break;
    }
 }
  void CONTROL_RELAY_FROM_DATA(int i)
  {
    if(i&1)ON_RELAY(1);
    else OFF_RELAY(1);
    if(i&2)ON_RELAY(2);
    else OFF_RELAY(2);
    if(i&4)ON_RELAY(3);
    else OFF_RELAY(3);
    if(i&8)ON_RELAY(4);
    else OFF_RELAY(4);
  }

int get_data_relay(){
    int data_read=0;
    data_read = digitalRead(RELAY1)*1+digitalRead(RELAY2)*2+digitalRead(RELAY3)*4+digitalRead(RELAY4)*8;
    return data_read;
  }
double round2(float value) {
   return (int)(value * 100 + 0.5) / 100.0;
}
