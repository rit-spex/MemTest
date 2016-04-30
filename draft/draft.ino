#include <SPI.h>
#include <SpiRAM.h>

#define SS 10           // Slave Select pin is 10
#define DATA_SIZE 32000 // 23768 bytes is max capacity of the chip
struct packet{
    uint16_t address;
    boolean isCorrupt;
    char data[29];
};

byte clock = 0;
SpiRAM Sram(0, SS);

void setup(){
    // Initialize rate to stable rate
    Serial.begin(230400);

    initialize();

    delay(100);
}




void loop(){
    
  
    printPackets(5);
    
    while(1);
}

void corrupt(int numPackets){
    
}
void printPackets(int numPackets){
      for(int i = 0; i < numPackets; i++){
      packet data;
      char buffer[sizeof(packet)];
      Sram.read_stream(i*sizeof(packet), buffer, sizeof(packet));
      memcpy(&data, &buffer, sizeof(packet));

      Serial.println("+++");
      Serial.println(data.address, HEX);
      Serial.println(data.isCorrupt, BIN);
      Serial.println(data.data);
      Serial.println("+++");
    }

}

void initialize(){

  for(uint16_t i = 0; i < (DATA_SIZE / sizeof(packet)); i++){
      packet data = { i * sizeof(packet), false, 
          "Memtest is the best payload."};

      char buffer[sizeof(packet)];
      memcpy(&buffer, &data, sizeof(packet));

      Sram.write_stream(data.address, buffer, sizeof(packet));
    }
}


