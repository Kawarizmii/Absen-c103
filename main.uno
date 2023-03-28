/*
   WebSocketClientSocketIO.ino

    Created on: 06.06.2016

    6A A0 9E 1A = M Wahyudi Harlianto


*/

#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>   // Include the Wi-Fi-Multi library
#include <Arduino.h>
#include <ArduinoJson.h>
#include <WebSocketsClient.h>
#include <SocketIOclient.h>
#include <HardwareSerial.h>
#include <Adafruit_GFX.h>    // Core graphics library
#include <Adafruit_ST7735.h> // Hardware-specific library for ST7735
#include <Adafruit_ST7789.h> // Hardware-specific library for ST7789
#include <SPI.h>
#include <MFRC522.h>
#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>
#include <Hash.h>
#include <ESP8266HTTPClient.h>

ESP8266WiFiMulti WiFiMulti;
WebSocketsClient webSocket;

#define RST_PIN         5          // Configurable, see typical pin layout above
#define SS_PIN          15         // Configurable, see typical pin layout above
#define USE_SERIAL Serial

int RelayPin = 4;

MFRC522 mfrc522(SS_PIN, RST_PIN);
String tappedCodeTag = "";

void setup() {
  // USE_SERIAL.begin(9600);
  USE_SERIAL.begin(9600);

  //Serial.setDebugOutput(true);
  USE_SERIAL.setDebugOutput(true);

  pinMode(RelayPin, OUTPUT);
  SPI.begin();
  mfrc522.PCD_Init();
  digitalWrite(RelayPin, LOW);
}

unsigned long messageTimestamp = 0;
void loop() {
  
  if ( ! mfrc522.PICC_IsNewCardPresent())
  {
    return;
  }

  if ( ! mfrc522.PICC_ReadCardSerial())
  {
    return;
  }

  USE_SERIAL.print("UID tag :");
  String content = "";
  byte letter;
  for (byte i = 0; i < mfrc522.uid.size; i++)
  {
    USE_SERIAL.print(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " ");
    USE_SERIAL.print(mfrc522.uid.uidByte[i], HEX);
    content.concat(String(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " "));
    content.concat(String(mfrc522.uid.uidByte[i], HEX));
  }
  USE_SERIAL.println();
  USE_SERIAL.print("Message : ");
  content.toUpperCase();

  if (content.substring(1) == "43 D4 CA 1B" || content.substring(1) == "A4 B9 23 07" || content.substring(1) == "6A A0 9E 1A") { //change here the UID of the card/cards that you want to give access{
    USE_SERIAL.println("Authorized access");
    USE_SERIAL.println();
    digitalWrite(RelayPin, HIGH);
    USE_SERIAL.println("HALLO");
    delay(1000);
    digitalWrite(RelayPin, LOW);
    USE_SERIAL.println("Terimkasih sudah berkunjung");
    tappedCodeTag = content.substring(1);
      
    Serial.println(tappedCodeTag);
    Serial.println(tappedCodeTag.length());
  }
  else {
    USE_SERIAL.println(" Access denied");
    digitalWrite(RelayPin, LOW);
    USE_SERIAL.println("Mati");
    delay(1000);
  }
}
