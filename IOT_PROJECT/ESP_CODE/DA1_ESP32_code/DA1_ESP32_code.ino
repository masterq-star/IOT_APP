#include "main_define.h" 

 char macStr[12] = { 0 };
  const  char* rssiSSID;       // NO MORE hard coded set AP, all SmartConfig
  const  char* password;
  String PrefSSID, PrefPassword;  // used by preferences storage

  int  WFstatus;
  int UpCount = 0;
  int32_t rssi;           // store WiFi signal strength here
  String getSsid;
  String getPass;
  String  MAC;
  String internet_connect ;
  bool run_read = 0;
  bool run_core1 =0;
  bool new_data = 0;
  float temp_s,humi_s,volt_s,curent_s;


  // SSID storage
       Preferences preferences;  // declare class object
  // END SSID storage
  StaticJsonDocument<200> doc;



WiFiClientSecure client;
DHT dht(DHTPIN, DHTTYPE);
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
MQTTPubSubClient mqtt;
void upload_data();
unsigned long lastMillis = 0;
char msg[200];
void Println_to_lcd(String data_text) {
  if(display.getCursorY() >=50){
    display.clearDisplay();
    display.setCursor(0,0);
    }
  display.setFont();
  display.setTextSize(1);
  display.setTextColor(WHITE);
  display.println(data_text);
  display.display(); 
}
void connect() {
  int cn_count = 0;
  Serial.print("checking wifi...");
  while ((WiFi.status() != WL_CONNECTED)&(cn_count < 30)) {
    Serial.print(".");
    internet_connect="CNTING";
    delay(1000);
    cn_count++;
  }
if( cn_count >25 ) initSmartConfig() ; //go to smart config
  

    Serial.print("connecting to host...");
    //Println_to_lcd("Connecting mqtt!");
    client.setInsecure();  // skip verification
    while (!client.connect("103.101.162.184", 8883)) {
        Serial.print(".");
        delay(1000);
    }
    Serial.println(" connected!");

    // initialize mqtt client
    mqtt.begin(client);
    //Println_to_lcd("Connecting broker!");
    Serial.print("connecting to mqtt broker...");
    while (!mqtt.connect(MAC, "", "")) 
    {
        Serial.print(".");
        delay(1000);
    }
    Serial.println(" connected!");

    // subscribe callback which is called when every packet has come
    mqtt.subscribe([](const String& topic, const String& payload, const size_t size) {
        Serial.println("mqtt received: " + topic + " - " + payload);
    });

    // subscribe topic and callback which is called when /hello has come
    mqtt.subscribe(MQTT_TOPIC_D, [](const String& payload, const size_t size) {
        Serial.print(MQTT_TOPIC_D);
        Serial.println(payload);
        //parse json and sen can-mesage
        DeserializationError error = deserializeJson(doc, payload);
        // Test if parsing succeeds.
        if (error) {
            Serial.print(F("deserializeJson() failed: "));
            Serial.println(error.c_str());
        }
        else {
          int data = doc["data"];
          CONTROL_RELAY_FROM_DATA(data);
          Serial.println(get_data_relay());
          Serial.println(data);

        }
        
    });
  
}


static void UART_ISR_ROUTINE(void *pvParameters)
{
while(1)
    {
        // read data from sensor
        delay(1000);
        //int randNumber1 = random(1, 20);
        emon1.calcVI(20,2000);
        temp_s=dht.readTemperature();
       // temp_s,humi_s,volt_s,curent_s;
       humi_s=dht.readHumidity();
       volt_s=emon1.Vrms;
       curent_s=emon1.Irms;
       Serial.print("temprature");
       Serial.println(temp_s);
       Serial.print("humidity");
       Serial.println(humi_s);
       if(isnan(humi_s) || isnan(temp_s))
       {
       Serial.println("not read temp humi"); 
       show_data_to_lcd(0,0,volt_s,curent_s);
       }else
       {
        new_data=1;
        //Println_to_lcd("Test line");
        show_data_to_lcd(temp_s,humi_s,volt_s,curent_s);
        vTaskDelay(1000 / portTICK_RATE_MS);
        }
          // go to block  
    }

}
static void UPLOAD_DATA(void *pvParameters)
{
while(1)
    {
                   Serial.println("Task 1 Hello!");
                  if ( WiFi.status() ==  WL_CONNECTED )      // Main connected loop
                    { //main LOOP
                       mqtt.update();
                       Serial.println("update ok");
                      if (!client.connected()) {
                      connect();
                       }
                       else{
                            if(new_data)
                            {
                              upload_data(temp_s,humi_s,volt_s,curent_s);
                            //  temp_s,humi_s,volt_s,curent_s;
                              new_data=0;
                            }
                        }
                    
                    //Gui theo dinh ky 10s thong tin thiet bi

                    }   // END Main connected loop()
                    else
                    {            // WiFi DOWN
                  
                       //  wifi down start LED flasher here
                  
                           WFstatus = getWifiStatus( WFstatus );
                  
                       WiFi.begin( PrefSSID.c_str() , PrefPassword.c_str() );
                       int WLcount = 0;
                       while (WiFi.status() != WL_CONNECTED && WLcount < 200 )
                       {
                        delay( 100 );
                         //  Serial.printf(".");
                  
                           if (UpCount >= 60)  // keep from scrolling sideways forever
                           {
                              UpCount = 0;
                              //   Serial.printf("\n");
                           }
                           ++UpCount;
                           ++WLcount;
                       }
                  
                      if( getWifiStatus( WFstatus ) == 3 )   //wifi returns
                      { 
                      // stop LED flasher, wifi going up
                      }
                       delay( 1000 );
                    }
                      
                      // END WiFi dow
           vTaskDelay(1000 / portTICK_RATE_MS);         
    }

}


void setup() {
  pinMode(RELAY1, OUTPUT);
  pinMode(RELAY2, OUTPUT);
  pinMode(RELAY3, OUTPUT);
  pinMode(RELAY4, OUTPUT);
  emon1.voltage(32, 106.8, 1.7);  // Voltage: input pin, calibration, phase_shift
  emon1.current(35, 5g);       // Current: input pin, calibration.
  Wire.begin(15,2);
  Serial.begin(115200);
  dht.begin();
  Serial.printf("\tWiFi Setup -- \n"  );
  delay(200);
  if(!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println(F("SSD1306 allocation failed"));
    for(;;); // Don't proceed, loop forever
  }
  display.display();
  display.setCursor(0,17);
  // Clear the buffer
  display.clearDisplay();

  // Show the display buffer on the screen. You MUST call display() after
  // drawing commands to make them visible on screen!
  display.display();
  delay(1000);
  xTaskCreatePinnedToCore(UART_ISR_ROUTINE, "UART_ISR_ROUTINE", 10000, NULL, 2, NULL,0);
  wifiInit();       // get WiFi connected
  IP_info();
  MAC = getMacAddress();

   WiFi.mode(WIFI_AP_STA);                    // required to read NVR before WiFi.begin()
    uint8_t baseMac[6];
    esp_read_mac( baseMac, ESP_MAC_WIFI_STA ); // Get MAC address for WiFi station
    sprintf(macStr, "%02X%02X%02X%02X%02X%02X", baseMac[0], baseMac[1], baseMac[2], baseMac[3], baseMac[4], baseMac[5]);
  
  connect();
  xTaskCreatePinnedToCore(UPLOAD_DATA, "UPLOAD_DATA", 10000, NULL, 2, NULL,1);
  
} //  END setup()
  
void loop()
{
//RUN RTOS
} // END loop()
  
void wifiInit()  // 
{
   Serial.println("Connect Wifi with default");
  // Println_to_lcd("Default Connect!");
   WiFi.begin( default_ssid , default_pass);
   int check_df_connect = 0;
   internet_connect = "DFWF";
   while(WiFi.status() != WL_CONNECTED  && check_df_connect < 50)
   {
     delay( 100 );
     Serial.printf(".");
     ++check_df_connect;
   }
   WiFi.mode(WIFI_AP_STA);   // required to read NVR before WiFi.begin()

   // load credentials from NVR, a little RTOS code here
   wifi_config_t conf;
   esp_wifi_get_config(WIFI_IF_STA, &conf);  // load wifi settings to struct comf
   rssiSSID = reinterpret_cast<const char*>(conf.sta.ssid);
   password = reinterpret_cast<const char*>(conf.sta.password);

    //  Serial.printf( "%s\n", rssiSSID );
    //  Serial.printf( "%s\n", password );

   // Open Preferences with "wifi" namespace. Namespace is limited to 15 chars
   preferences.begin("wifi", false);
       PrefSSID          =  preferences.getString("ssid", "none");      //NVS key ssid
       PrefPassword  =  preferences.getString("password", "none");  //NVS key password
   preferences.end();

   // keep from rewriting flash if not needed
   if( !checkPrefsStore() )     // see is NV and Prefs are the same
   {              // not the same, setup with SmartConfig
      if( PrefSSID == "none" )  // New...setup wifi
      {
       // Println_to_lcd("Smart Config!");
        initSmartConfig(); 
        delay( 3000);
        ESP.restart();   // reboot with wifi configured
      }
   } 

   // I flash LEDs while connecting here
  // Println_to_lcd("Smart pass!");
   WiFi.begin( PrefSSID.c_str() , PrefPassword.c_str() );
   internet_connect="PREF";
   int WLcount = 0;
   while (WiFi.status() != WL_CONNECTED && WLcount < 200 ) // can take > 100 loops depending on router settings
   {
     delay( 100 );
       // Serial.printf(".");
     ++WLcount;
   }
  delay( 3000 );

  //  stop the led flasher here

  }  // END wifiInit()

// match WiFi IDs in NVS to Pref store,  assumes WiFi.mode(WIFI_AP_STA);  was executed
bool checkPrefsStore()   
{
    bool val = false;
    String NVssid, NVpass, prefssid, prefpass;

    NVssid = getSsidPass( "ssid" );
    NVpass = getSsidPass( "pass" );

    // Open Preferences with my-app namespace. Namespace name is limited to 15 chars
    preferences.begin("wifi", false);
        prefssid  =  preferences.getString("ssid", "none");     //NVS key ssid
        prefpass  =  preferences.getString("password", "none"); //NVS key password
    preferences.end();

    if( NVssid.equals(prefssid) && NVpass.equals(prefpass) )
      { val = true; }

  return val;
}

// optionally call this function any way you want in your own code
// to remap WiFi to another AP using SmartConfig mode.   Button, condition etc.. 
void initSmartConfig() 
{
   // start LED flasher
  int loopCounter = 0;
  internet_connect = "SMRTCF";
  WiFi.mode( WIFI_AP_STA );       //Init WiFi, start SmartConfig
      Serial.printf( "Entering SmartConfig\n" );
 
  WiFi.beginSmartConfig();

  while (!WiFi.smartConfigDone()) 
  {
     // flash led to indicate not configured
        //    Serial.printf( "." );
     if( loopCounter >= 40 )  // keep from scrolling sideways forever
     {
         loopCounter = 0;
         //Serial.printf( "\n" );
     }
     delay(600);
    ++loopCounter;
  }
  loopCounter = 0;

  // stopped flasher here
 
 
   Serial.printf("\nSmartConfig received.\n Waiting for WiFi\n\n");
   delay(2000 );
    
  while( WiFi.status() != WL_CONNECTED )      // check till connected
  { 
    delay(500);
  }
  IP_info();  // connected lets see IP info

  preferences.begin("wifi", false);      // put it in storage
     preferences.putString( "ssid"         , getSsid);
     preferences.putString( "password", getPass);
  preferences.end();

    delay(300);
}  // END SmartConfig()

void IP_info()
{
   getSsid = WiFi.SSID();
   getPass = WiFi.psk();
   rssi = getRSSI(  rssiSSID );
   WFstatus = getWifiStatus( WFstatus );
   MAC = getMacAddress();

      Serial.printf( "\n\n\tSSID\t%s, ", getSsid.c_str() );
      Serial.print( rssi);  Serial.printf(" dBm\n" );  // printf??
      Serial.printf( "\tPass:\t %s\n", getPass.c_str() ); 
      Serial.print( "\n\n\tIP address:\t" );  Serial.print(WiFi.localIP() );
      Serial.print( " / " );
      Serial.println( WiFi.subnetMask() );
      Serial.print( "\tGateway IP:\t" );  Serial.println( WiFi.gatewayIP() );
      Serial.print( "\t1st DNS:\t" );     Serial.println( WiFi.dnsIP() );
      Serial.printf( "\tMAC:\t\t%s\n", MAC.c_str() );
}

int getWifiStatus( int WiFiStatus  )
{
  WiFiStatus = WiFi.status();
  Serial.printf("\tStatus %d",  WiFiStatus );
  switch( WiFiStatus )
  {
    case WL_IDLE_STATUS :                         // WL_IDLE_STATUS     = 0,
          Serial.printf(", WiFi IDLE \n");
          break;
    case WL_NO_SSID_AVAIL:                        // WL_NO_SSID_AVAIL   = 1,
          Serial.printf(", NO SSID AVAIL \n");
          break;
    case WL_SCAN_COMPLETED:                       // WL_SCAN_COMPLETED  = 2,
          Serial.printf(", WiFi SCAN_COMPLETED \n");
          break;
    case WL_CONNECTED:                            // WL_CONNECTED       = 3,
          Serial.printf(", WiFi CONNECTED \n");
          break;
    case WL_CONNECT_FAILED:                       // WL_CONNECT_FAILED  = 4,
          Serial.printf(", WiFi WL_CONNECT FAILED\n"); 
          break;
    case WL_CONNECTION_LOST:                      // WL_CONNECTION_LOST = 5,
          Serial.printf(", WiFi CONNECTION LOST\n");
          WiFi.persistent(false);                 // don't write FLASH
          break;
    case WL_DISCONNECTED:                         // WL_DISCONNECTED    = 6
          Serial.printf(", WiFi DISCONNECTED ==\n");
          WiFi.persistent(false);                 // don't write FLASH when reconnecting
          break;
  }
  return WiFiStatus;
}
// END getWifiStatus()

// Get the station interface MAC address.
// @return String MAC
String getMacAddress(void)
{
    WiFi.mode(WIFI_AP_STA);                    // required to read NVR before WiFi.begin()
    uint8_t baseMac[6];
    esp_read_mac( baseMac, ESP_MAC_WIFI_STA ); // Get MAC address for WiFi station
    char macStr[18] = { 0 };
    sprintf(macStr, "%02X%02X%02X%02X%02X%02X", baseMac[0], baseMac[1], baseMac[2], baseMac[3], baseMac[4], baseMac[5]);
    return String(macStr);
}// END getMacAddress()
// Return RSSI or 0 if target SSID not found
// const char* SSID = "YOUR_SSID";  // declare in GLOBAL space
// call:  int32_t rssi = getRSSI( SSID );
int32_t getRSSI( const char* target_ssid ) 
{
  byte available_networks = WiFi.scanNetworks();

  for (int network = 0; network < available_networks; network++) 
  {
    if ( strcmp(  WiFi.SSID( network).c_str(), target_ssid ) == 0) 
    {
      return WiFi.RSSI( network );
    }
  }
  return 0;
} //  END  getRSSI()


// Requires; #include <esp_wifi.h>
// Returns String NONE, ssid or pass arcording to request 
// ie String var = getSsidPass( "pass" );
String getSsidPass( String s )
{
  String val = "NONE";  // return "NONE" if wrong key sent
  s.toUpperCase();
  if( s.compareTo("SSID") == 0 )
  {
     wifi_config_t conf;
     esp_wifi_get_config( WIFI_IF_STA, &conf );
     val = String( reinterpret_cast<const char*>(conf.sta.ssid) );
  }
  if( s.compareTo("PASS") == 0 )
  {
     wifi_config_t conf;
     esp_wifi_get_config( WIFI_IF_STA, &conf );
     val = String( reinterpret_cast<const char*>(conf.sta.password) );
  }
 return val;
}
void upload_data(float temp_d , float humi_d , float volt_d , float current_d){
  String data_upload;
  StaticJsonDocument<200> data_esp;
    data_esp["data"] = get_data_relay();
    
  // Add an array.
  //
  
  JsonArray temp = data_esp.createNestedArray("temp");
  temp.add(round2(temp_d));
  temp.add(round2(humi_d));

  JsonArray volt = data_esp.createNestedArray("volt");
  volt.add(round2(volt_d));
  volt.add(round2(current_d));

  // Generate the minified JSON and send it to the Serial port.
  //
  serializeJson(data_esp, Serial);
  serializeJson(data_esp, data_upload);
  Serial.println();
  mqtt.publish(MQTT_TOPIC_U,data_upload );
}
void show_data_to_lcd(float temp, float humi,float volt,float current){
  String mqtt_connect;
  String RL1_STT,RL2_STT,RL3_STT,RL4_STT;
  static char volt_str[15];
  static char current_str[15];
  static char temp_str[15];
  static char humi_str[15];
  static char power_str[15];
  static char energy_str[15];
  if(WiFi.status() == WL_CONNECTED) internet_connect= "OK";
  if(client.connected()) mqtt_connect="OK";
  else mqtt_connect= "NOK";
  if(digitalRead(RELAY1)) RL1_STT="ON";
  else RL1_STT="OFF";

  if(digitalRead(RELAY2)) RL2_STT="ON";
  else RL2_STT="OFF";

  if(digitalRead(RELAY3)) RL3_STT="ON";
  else RL3_STT="OFF";

  if(digitalRead(RELAY4)) RL4_STT="ON";
  else RL4_STT="OFF";
  char _buffer[150];
  dtostrf(volt,7, 3, volt_str);
  dtostrf(current,7, 3, current_str);
  dtostrf(temp,7, 3, temp_str);
  dtostrf(humi,7, 3, humi_str);
  char Buf_inter[9];
  char Buf_mqtt[5];
  char Buf_RL1[5];
  char Buf_RL2[5];
  char Buf_RL3[5];
  char Buf_RL4[5];
  internet_connect.toCharArray(Buf_inter,9);
  mqtt_connect.toCharArray(Buf_mqtt,5);
  RL1_STT.toCharArray(Buf_RL1,5);
  RL2_STT.toCharArray(Buf_RL2,5);
  RL3_STT.toCharArray(Buf_RL3,5);
  RL4_STT.toCharArray(Buf_RL4,5);
  
  sprintf(_buffer,"Temp: %s°C\nHumi: %s /% \nVolt:%s V\nCurrent:%s A\nInternet:%s \nMqtt:%s\n RL1:%s  RL2:%s \n RL3:%s  RL4:%s",temp_str,humi_str, volt_str,current_str,Buf_inter,Buf_mqtt,Buf_RL1,Buf_RL2,Buf_RL3,Buf_RL4);
  Serial.println(_buffer);
  
  display.clearDisplay();
  display.setCursor(0,0);
  display.setFont();
  display.setTextSize(1);
  display.setTextColor(WHITE);
  display.println(_buffer);
  display.display();
  }
