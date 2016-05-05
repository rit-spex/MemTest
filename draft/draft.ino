#include <SPI.h>
#include <SpiRAM.h>

#define SS 10           // Slave Select pin is 10
//#define DATA_SIZE 32000 // 23768 bytes is max capacity of the chip
#define DATA_SIZE 30752 // 23768 bytes is max capacity of the chip

#define BITSHIFTS 10    // Quantity of bitshifts to operate on the data
#define STRING_LENGTH  29 // Length of the packet data member
struct packet{
    uint16_t address;
    boolean isCorrupt;
    char data[STRING_LENGTH];
};

byte clock = 0;
SpiRAM Sram(0, SS);
int iterator = 1;
void setup(){
    // Initialize rate to stable rate
    Serial.begin(230400);

    // Set the board up and have it populated with defaults
    initialize();

    // Prevents spooky unexpected things from happening after initialization
    delay(5);
}
/**
 * Serial input commands:
 * Initialize: i
 * Read
 */


void loop(){
  //initialize();
  if(Serial.available() > 0){
    char command = Serial.read();
    

    // Need to finish on these switch cases
    switch(command){
      case 'i':
        initialize();
        break;
      case 'c':
        corrupt(getSerialPacketNumber());
        break;
      default:
        break;
    }

    
  }
    /*iterator++;
    if(iterator>961) iterator = 1;
    String commandString = "write ";
    if (iterator<100) commandString += '0';
    if (iterator<10) commandString += '0';
    commandString += iterator;
    commandString += " This is the data";
    Serial.println(commandString);
    delay(50);*/
}

int getSerialPacketNumber(){
  if(Serial.available() == 4){
    int packetNumber = 0;

    // 1000's place
    char input = Serial.read();     
    packetNumber += ((int) atol(&input)) * 1000;

    // 100's place
    input = Serial.read();
    packetNumber += ((int) atol(&input)) * 100;

    // 10's
    input = Serial.read();
    packetNumber += ((int) atol(&input)) * 10;

    //1's
    input = Serial.read();
    packetNumber += (int) atol(&input);

    return packetNumber;
  }

  return 0;
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
      sendCommand("write ", data.address, data.data);
    /*
    String commandString = "write ";
    if (data.address<10000) commandString += '0';
    if (data.address<1000) commandString += '0';
    if (data.address<100) commandString += '0';
    if (data.address<10) commandString += '0';
    commandString += data.address;
    commandString += data.data;
    Serial.println(commandString);
    delay(50);*/
    }
}

void sendCommand(String command, int addr, String data) {
  String commandString = command;
    if (addr<10000) commandString += '0';
    if (addr<1000) commandString += '0';
    if (addr<100) commandString += '0';
    if (addr<10) commandString += '0';
    commandString += addr;
    commandString += data;
    Serial.println(commandString);
    delay(50);
}



