#include <SPI.h>
#include <SpiRAM.h>

#define SS 10           // Slave Select pin is 10
#define DATA_SIZE 32000 // 23768 bytes is max capacity of the chip

#define BITSHIFTS 10    // Quantity of bitshifts to operate on the data
#define STRING_LENGTH  29 // Length of the packet data member
struct packet{
    uint16_t address;
    boolean isCorrupt;
    char data[STRING_LENGTH];
};

byte clock = 0;
SpiRAM Sram(0, SS);

void setup(){
    // Initialize rate to stable rate
    Serial.begin(230400);

    // Set the board up and have it populated with defaults
    initialize();

    // Prevents spooky unexpected things from happening after initialization
    delay(10);
}




void loop(){
    corrupt(0);
    printPackets(DATA_SIZE / sizeof(packet));
    
    while(1);
}

/**
 * Corrupts the nth packet
 *
 * Corrupts 10 random indexes in the packet's data member
 *
 * Corruption is performed by XOR'ing that index by using a random mask
 * that flips only one bit.
 */
void corrupt(int packetNumber){
    if(isValid(packetNumber)){
      packet data = readPacket(packetNumber);
      int rand;

      for(int i = 0; i < BITSHIFTS; i++){
        rand = random(0,29);

        data.data[rand] = data.data[rand] ^ ( (char) 1 << random(1,8));   // XOR 
      }

      data.isCorrupt = true;

      writePacket(data, packetNumber);
    }
}

/**
 * read's and returns the nth packet 
 *
 * if packetNumber is out of bounds, then the first packet is read and returned
 */
packet readPacket(int packetNumber){
  if(isValid(packetNumber)){
    packet data;
    char buffer[sizeof(packet)];
    Sram.read_stream(packetNumber * sizeof(packet), buffer, sizeof(packet));
    memcpy(&data, &buffer, sizeof(packet));

    return data;
  } else {
    packet data;
    char buffer[sizeof(packet)];
    Sram.read_stream(0 * sizeof(packet), buffer, sizeof(packet));
    memcpy(&data, &buffer, sizeof(packet));

    return data;
  }
}

/**
 * Writes pack to the address packetNumber * sizeof(packet)
 */
void writePacket(packet pack, int packetNumber){
  if(isValid(packetNumber)){
    char buffer[sizeof(packet)];
    memcpy(&buffer, &pack, sizeof(packet));
    Sram.write_stream(packetNumber * sizeof(packet), buffer, sizeof(packet));
  }
}

/**
 * Prints out the packets in a structured form.  Preceeded and succeeded by "+++"
 *
 * Format:  address [integer, HEX]
 *          isCorrupt [boolean, BIN]
 *          data    [char *]
 */
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

/**
 * Checks if the packet index is in bounds
 */
boolean isValid(int packetNumber){
  if((sizeof(packet) * packetNumber) < DATA_SIZE){
    return true;
  } else {
    return false;
  }
}

/**
 * Sets up the SRAM chip with the maximum number of packets.
 * 
 * Each packet initialized to:  address = int value of its address in memory
 *                              isCorrupt = false 
 *                              data = "Memtest is the best payload."
 */
void initialize(){

  for(uint16_t i = 0; i < (DATA_SIZE / sizeof(packet)); i++){
      packet data = { i * sizeof(packet), false, 
          "Memtest is the best payload."};

      char buffer[sizeof(packet)];
      memcpy(&buffer, &data, sizeof(packet));

      Sram.write_stream(data.address, buffer, sizeof(packet));
    }
}


