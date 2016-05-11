/*RIT Space Exploration Radiation Memory Testing Proof of Concept
*Authors: T.J. Tarazevits, Austin Bodzas
*Display Date: ImagineRIT May 7th, 2016
*repo: https://github.com/venku122/MemTest
*/
import processing.serial.*;
import java.util.*;

int dataBlockSize = 32; // page size supported by memory chip
int bytesOfMemory = 32000; //total bytes in chip
int numDataBlocks = bytesOfMemory / dataBlockSize; //number of pages in chip
int arrayDimension = (int)sqrt(numDataBlocks); //creates even squared sides for visualizer matrix

int blockWidth = 30;//display Constants
int blockHeight = 30;
int windowWidth = 1920;
int windowHeight = 1080;
String imagePath = "logo.png";
PImage logo;
int writtenBlocks = 0;
int corruptBlocks = 0;

DataBlock [][] dataMatrix = new DataBlock[arrayDimension][arrayDimension]; //main data structure for visualizer
Map addrLookUp = new HashMap(); //allows for address to quickly link to specific dimensions in data structure

Serial port;//Variables for Serial initialization
String input="test";
int bitRate = 230400;//High bitrate allows near real time mirroring

List<UIButton> buttons;//holds all UI Objects
GraphicConsole console;//acts like a console object but uses Processing's graphics renderer

boolean changeData = false;//toggles whether to corrupt data each loop

//Sets up processing sketch enables several key functions
//Creates graphical console for fast output
//initializes serial port
//initializes dataMatrix with empty dataBlocks
//adds UIButtons to list

void setup() {
  size(1920, 1080);
  background(255,255,255);
  
  console= new GraphicConsole(arrayDimension* blockWidth, 0, windowWidth - (arrayDimension* blockWidth), windowHeight);
  setupSerial();
  
  int iterator = 0;
  for(int i= 0; i< arrayDimension; i++) {
     for(int j = 0; j < arrayDimension; j++) {
       
       DataBlock data = new DataBlock(i, j, blockWidth, blockHeight, iterator);
       dataMatrix[i][j] = data;
       addrLookUp.put(iterator, data.index);
       iterator+=32;
     }
  }
  buttons = new LinkedList();
  //UIButton(int x, int y, int w, int h, String text)
  //toggles
   UIButton startSwitch = new UIButton(0, 930, 200, 70, "Start/Stop", "Start/Stop");
   buttons.add(startSwitch);
   UIButton clearSwitch = new UIButton(200, 930, 250, 70, "Clear all blocks", "clear");
   buttons.add(clearSwitch);
   UIButton fillSwitch = new UIButton(450, 930, 250, 70, "Fill all blocks", "fill");
   buttons.add(fillSwitch);
   
   //stats
   UIButton totalBlocks = new UIButton(700, 930, 260, 70, "Blocks: " + arrayDimension*arrayDimension, "");
   buttons.add(totalBlocks);
    UIButton writtenBlock = new UIButton(400, 1000, 230, 80, "Written: " + writtenBlocks, "written");
   buttons.add(writtenBlock);
   UIButton corruptedBlock = new UIButton(630, 1000, 330, 80, "Corrupted: " + corruptBlocks, "corrupt");
   buttons.add(corruptedBlock);
   //second row toggles
   UIButton fastSwitch = new UIButton(0, 1000, 200, 80, "Fast Mode", "fast");
   buttons.add(fastSwitch);
    UIButton slowSwitch = new UIButton(200, 1000, 200, 80, "Slow Mode", "slow");
   buttons.add(slowSwitch);
   
   //load logo
   logo = loadImage(imagePath);
   
   
}

//main gameLoop thread
//split up update and draw functions
void draw() {
  background(255,255,255);
  
  update();
  //draws and updates dataMatrix
  //update is called to minimize for-loop iterations
  for(int i= 0; i< arrayDimension; i++) {
     for(int j = 0; j < arrayDimension; j++) {
       dataMatrix[i][j].update();
       dataMatrix[i][j].display();
     }
  }
  //draws the UI over the dataMatrix
  for( UIButton b : buttons) {
     b.display(); 
  }
  console.display(); //displays the graphical console
  drawLogo(); //draws SPEX logo
}

//main update logic of program
//reads and processing serial input
void update() {  
  
  readSerial();
  processInput();
  
  if(changeData) {
    port.write('c');
  }
  
  //handles UIButton interactivity 
  for( UIButton b : buttons) {
     b.update(); 
      if(b.command=="written")b.buttonText = "Written: " + writtenBlocks;//updates display UI elements
      if(b.command=="corrupt")b.buttonText = "Corrupted: " + corruptBlocks;
     if(b.isPressed){ // checks for mouse clicks on buttons 
       if(b.command=="Start/Stop") changeData = !changeData;
       if(b.command=="clear")  port.write('w');//clearAll();
       if(b.command=="fill")   port.write('i');//fillAll();
       if(b.command == "fast") port.write('9');
       if(b.command == "slow") port.write('1');
     }
  }
}

//sets up serial port connection to arduino
void setupSerial() {
  console.println(Serial.list()[0]);
  String portName = Serial.list()[0];
  port = new Serial(this, portName, bitRate);
}

//reads bitstream from serial port
void readSerial() {
 if ( port.available() > 0) 
  {  
    console.println("read from serial port");
    input = port.readStringUntil('\n'); 
    console.println(input);
  }  
  else input = "empty";
  
}

//clears each memory block by calling clear block
//unused since arduino handles clearing memory chip
void clearAll() {
  for(int i= 0; i< arrayDimension; i++) {
     for(int j = 0; j < arrayDimension; j++) {
       dataMatrix[i][j].clearBlock();
     }
  }
}

//unused, tells arduino to halt current operation
void stop() {
  port.write('q');
}

//deprecated, makes memory blocks appear to be in written mode
void fillAll() {
  for(int i= 0; i< arrayDimension; i++) {
     for(int j = 0; j < arrayDimension; j++) {
       dataMatrix[i][j].isWritten=true;
       writtenBlocks++;
     }
  }
}
//draws the SPEX logo
void drawLogo() {
 image(logo, 1920 - 400, 1080 - 400, 400,400); 
}

//processes serial input and changes the local state of dataMatrix to match the arduino
//write - writes new data to block and sets isWritten flag
//crrpt - writes corrupted data to dataBlock and sets isCorrupt flag
//wiped = wipes local data and sets isWritten flag false
void processInput() {
  
 String in = input;
 char[] data = new char[50];
 if(in!=null) { //prevents nullPointerExceptions when serial buffer is empty
   if(in.startsWith("write"))
   {
     int keyLength = 5;
     in = in.substring(keyLength);
     String address = in.substring(0,6);
     in.getChars(address.length(),in.length(), data,0);  //isolated data from input string
     address = address.trim();
     address = address.replaceFirst("^0+(?!$)", "");
     int addr = Integer.parseInt(address);
  
    PVector index = (PVector)addrLookUp.get(addr);
    dataMatrix[(int)index.x][(int)index.y].data = String.valueOf(data);
    if(dataMatrix[(int)index.x][(int)index.y].isCorrupt && !dataMatrix[(int)index.x][(int)index.y].isWritten) corruptBlocks--; 
    if(!dataMatrix[(int)index.x][(int)index.y].isWritten) writtenBlocks++;
    dataMatrix[(int)index.x][(int)index.y].isCorrupt = false;
    dataMatrix[(int)index.x][(int)index.y].isWritten = true; //<>//
   }
   
   if(in.startsWith("crrpt"))
   {
     int keyLength = 5;
     in = in.substring(keyLength);
     String address = in.substring(0,6);
     in.getChars(address.length(),in.length(), data,0); 
     address = address.trim();
     address = address.replaceFirst("^0+(?!$)", "");
     int addr = Integer.parseInt(address);
  
    PVector index = (PVector)addrLookUp.get(addr);
    if(dataMatrix[(int)index.x][(int)index.y].isWritten && !dataMatrix[(int)index.x][(int)index.y].isCorrupt){
      writtenBlocks--;
      
    }
    dataMatrix[(int)index.x][(int)index.y].data = String.valueOf(data);
    dataMatrix[(int)index.x][(int)index.y].isWritten = true;
    if(!dataMatrix[(int)index.x][(int)index.y].isCorrupt) corruptBlocks++;
    dataMatrix[(int)index.x][(int)index.y].isCorrupt = true;
   }
   
   if(in.startsWith("wiped"))
   {
     int keyLength = 5;
     in = in.substring(keyLength);
     String address = in.substring(0,6);
     in.getChars(address.length(),in.length(), data,0); 
     address = address.trim();
     address = address.replaceFirst("^0+(?!$)", "");
     int addr = Integer.parseInt(address);
  
    PVector index = (PVector)addrLookUp.get(addr);
    if(dataMatrix[(int)index.x][(int)index.y].isWritten && !dataMatrix[(int)index.x][(int)index.y].isCorrupt) writtenBlocks--;
    if(dataMatrix[(int)index.x][(int)index.y].isCorrupt) corruptBlocks--;
    dataMatrix[(int)index.x][(int)index.y].data = String.valueOf(data);
    dataMatrix[(int)index.x][(int)index.y].isWritten = false;
    dataMatrix[(int)index.x][(int)index.y].isCorrupt = false;
   }
 }
 
 
}