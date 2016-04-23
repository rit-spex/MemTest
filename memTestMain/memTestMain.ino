#include <SPI.h>
#include <SpiRAM.h>
#include <Wire.h>
#include <elapsedMillis.h>
#define SS_PIN 10
struct packet {
  int address;
  char info[13];
};

byte clock = 0;
SpiRAM SpiRam(0, SS_PIN);

const int dataSize = 32000;
//const int dataSize = sizeof(packet) * 5;



void setup() {
  Serial.begin(250000);

}

void loop() {
  Serial.println("Testing");

  /*
  for(int i = 0; i<dataSize; i++) {
    SpiRam.write_byte(i * sizeof(uint8_t),(uint8_t)random(0,256));
  }*/
  for(int i = 0; i<(dataSize / sizeof(packet)); i++) {
    packet data = {i* sizeof(packet), "data is here"};
    char* dataBuffer;
    memcpy(&dataBuffer, &data, sizeof(packet));
    SpiRam.write_stream(data.address, dataBuffer, sizeof(packet));
  }

  /*
  for(int i = 0; i<dataSize; i++) {
    //Serial.print((uint8_t)chipData[i]);
    Serial.print((uint8_t)SpiRam.read_byte(i * sizeof(uint8_t)));
    Serial.print(" ");
  }*/

for(int i = 0; i<(dataSize / sizeof(packet)); i++) {
    packet data;
    char* dataBuffer;
    SpiRam.read_stream(i*sizeof(packet),dataBuffer, sizeof(packet));
    memcpy(&data, &dataBuffer, sizeof(packet));
    Serial.print(data.address);
    Serial.print(" ");
    Serial.print(data.info);
    Serial.print(" ");
  }
  Serial.print("\n");
  delay(1000);
}
