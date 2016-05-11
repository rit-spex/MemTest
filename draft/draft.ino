/*RIT Space Exploration Radiation Memory Testing Proof of Concept
 * Authors: T.J. Tarazevits, Austin Bodzas
 * Display Date: ImagineRIT May 7th, 2016
 * repo: https://github.com/venku122/MemTest
 */

#include <SPI.h> 
#include <SpiRAM.h> //arduino library supports SRAM chip

#define SS 10           // Slave Select pin is 10
//#define DATA_SIZE 32000 // 23768 bytes is max capacity of the chip
#define DATA_SIZE 30752 // 23768 bytes is max capacity of the chip

#define BITSHIFTS 10    // Quantity of bitshifts to operate on the data
#define STRING_LENGTH  29 // Length of the packet data member
struct packet{ //the struct is a representation of the page size
    uint16_t address;
    boolean isCorrupt;
    char data[STRING_LENGTH];
};

byte clock = 0;
SpiRAM Sram(0, SS); //initalizes SRAM library
int iterator = 1;
int loopSpeed = 10; //millisecond delay for looping
void setup(){
    // Initialize rate to stable rate
    Serial.begin(230400);

    // Set the board up and have it populated with defaults
    //initialize();

    // Prevents spooky unexpected things from happening after initialization
    delay(5);
}
/**
 * Serial input commands:
 * all commands report status change to the visualizer
 * Initialize: 'i' fills entire memory chip with data in packet sized chunks
 * wipe: 'w' clears entire memory chip
 * corrupt: 'c' randomly chooses a packet and flips the bits of the data stored within
 */

//main logic loop of the program
void loop(){
  if(Serial.available() > 0){
    char command = Serial.read();

    switch(command){
      case 'i':
        initialize();
        break;
      case 'c':
        corrupt(getSerialPacketNumber());
        break;
      case 'w':
        wipe();
        break;
      case '9': //sets loop delay to ASAP
      loopSpeed=10;
      break;
      case '1':
      loopSpeed=100; //slows down memory processes
      break;
      default:
        break;
    }
  }
}

//gets a random address of a packet/page in memory
int getSerialPacketNumber(){
  int addr = sizeof(packet) * (int)random(0,(DATA_SIZE / sizeof(packet)));
  return addr;
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
      sendCommand("crrpt ", packetNumber, data.data); //mirrors the command on the visualizer
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
  if((sizeof(packet) + packetNumber) < DATA_SIZE){
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
    }
}

//wipes entire chip in page sized chunks
void wipe() {
  for(uint16_t i = 0; i < (DATA_SIZE / sizeof(packet)); i++){
    char buffer[sizeof(packet)] = "";
    Sram.write_stream(i * sizeof(packet), buffer, sizeof(packet));
    sendCommand("wiped ",i * sizeof(packet), buffer);
  }
}


//Sends a command to the visualizer
//first 6 bytes are the command string
//2 byte integer address
//String of packet data
void sendCommand(String command, int addr, String data) {
  String commandString = command;
    if (addr<10000) commandString += '0';
    if (addr<1000) commandString += '0';
    if (addr<100) commandString += '0';
    if (addr<10) commandString += '0';
    commandString += addr;
    commandString += ' ';
    commandString += data;
    Serial.println(commandString);
    delay(loopSpeed);
}



