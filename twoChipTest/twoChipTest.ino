#include <SPI.h>
#include <SpiRAM.h>
#include <SpiEEPROM.h>

#define SS1 10
#define SS2 9

byte clock = 0;
SpiRAM sram(0, SS1);
SpiEEPROM eeprom(0, SS2);


void setup(){
  Serial.begin(9600);

  // Disable both chips initially
  digitalWrite(SS1, HIGH);
  digitalWrite(SS2, HIGH);
}

int addr = 3000;
byte value = 28;
byte storage = 0;

void loop(){
  
    Serial.print("Storage initially: ");
    Serial.println(storage);
    Serial.println("Write 28 to sram @ 3000");
    
    sram.write_byte(addr, value);

    Serial.println("storage = value @ addr");
    storage = sram.read_byte(addr);
    Serial.print("Storage now = ");
    Serial.println(storage);

    storage = 0;
    Serial.println("-------------------------------------");
    Serial.print("Storage initially: ");
    Serial.println(storage);
    Serial.println("Write 28 to eeprom @ 3000");

    eeprom.write(addr, value);

    Serial.println("storage = value @ addr");
    storage = eeprom.read(addr);
    Serial.print("Storage now = ");
    Serial.println(storage);
    while(1);
}

