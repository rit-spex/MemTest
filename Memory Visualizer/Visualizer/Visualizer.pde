import processing.serial.*;

import java.util.*;

int dataBlockSize = 32;
int bytesOfMemory = 32000;
int numDataBlocks = bytesOfMemory / dataBlockSize;
int arrayDimension = (int)sqrt(numDataBlocks);

DataBlock [][] dataMatrix = new DataBlock[arrayDimension][arrayDimension];
Map addrLookUp = new HashMap();

Serial port;
String input="test";
int bitRate = 230400;

List<UIButton> buttons;

boolean changeData = false;

void setup() {
  size(1000,1000);
  background(255,255,255);
  setupSerial();
  
  int iterator = 0;
  for(int i= 0; i< arrayDimension; i++) {
     for(int j = 0; j < arrayDimension; j++) {
       
       DataBlock data = new DataBlock(i, j, 30,30, iterator);
       dataMatrix[i][j] = data;
       addrLookUp.put(iterator, data.index);
       iterator+=32;
     }
  }
  buttons = new LinkedList();
  //UIButton(int x, int y, int w, int h, String text)
   UIButton startSwitch = new UIButton(0, 930, 200, 70, "Start/Stop", "Start/Stop");
   buttons.add(startSwitch);
   UIButton clearSwitch = new UIButton(200, 930, 250, 70, "Clear all blocks", "clear");
   buttons.add(clearSwitch);
   UIButton fillSwitch = new UIButton(450, 930, 250, 70, "Fill all blocks", "fill");
   buttons.add(fillSwitch);
   
   
   //
   /*println("Initializing memory unit");
   port.write('i');*/
}

void draw() {
  background(255,255,255);
  
  update();
  for(int i= 0; i< arrayDimension; i++) {
     for(int j = 0; j < arrayDimension; j++) {
       dataMatrix[i][j].update();
       dataMatrix[i][j].display();
     }
  }
  
  for( UIButton b : buttons) {
     b.display(); 
  }
}

void update() {  
  
  readSerial();
  processInput();
  if(changeData) {/*
  int targetAddr = 32*(int)random(0, (arrayDimension*arrayDimension));
  PVector target = (PVector)addrLookUp.get(targetAddr);
  dataMatrix[(int)target.x][(int)target.y].isWritten = true;
  
  targetAddr = (int)random(1, (arrayDimension*arrayDimension));
  target = (PVector)addrLookUp.get(targetAddr);
  dataMatrix[(int)target.x][(int)target.y].clearBlock();*/
  port.write('c');
  }
  
  for( UIButton b : buttons) {
     b.update(); 
     if(b.isPressed){
       if(b.command=="Start/Stop") changeData = !changeData;
       if(b.command=="clear") port.write('w');//clearAll();
       if(b.command=="fill") port.write('i');//fillAll();
     }
  }
}

void setupSerial() {
  println(Serial.list()[0]);
  String portName = Serial.list()[0];
  //String portName = "COM5";
  port = new Serial(this, portName, bitRate);
}

void readSerial() {
 if ( port.available() > 0) 
  {  
    println("read from serial port");
    input = port.readStringUntil('\n'); 
    println(input);
  }  
  else input = "empty";
  
}

void clearAll() {
  for(int i= 0; i< arrayDimension; i++) {
     for(int j = 0; j < arrayDimension; j++) {
       dataMatrix[i][j].clearBlock();
     }
  }
}

void fillAll() {
  for(int i= 0; i< arrayDimension; i++) {
     for(int j = 0; j < arrayDimension; j++) {
       dataMatrix[i][j].isWritten=true;
     }
  }
}

void processInput() {
  
 String in = input;
 char[] data = new char[50];
 if(in!=null) {
   if(in.startsWith("write"))
   {
     int keyLength = 5;
     in = in.substring(keyLength);
     String address = in.substring(0,6);
     in.getChars(address.length(),in.length(), data,0); 
     address = address.trim();
     address = address.replaceFirst("^0+(?!$)", "");
     int addr = Integer.parseInt(address);
  
    PVector index = (PVector)addrLookUp.get(addr);
    dataMatrix[(int)index.x][(int)index.y].data = String.valueOf(data);
    dataMatrix[(int)index.x][(int)index.y].isWritten = true; //<>//
    dataMatrix[(int)index.x][(int)index.y].isCorrupt = false;
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
    dataMatrix[(int)index.x][(int)index.y].data = String.valueOf(data);
    dataMatrix[(int)index.x][(int)index.y].isWritten = true;
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
    dataMatrix[(int)index.x][(int)index.y].data = String.valueOf(data);
    dataMatrix[(int)index.x][(int)index.y].isWritten = false;
    dataMatrix[(int)index.x][(int)index.y].isCorrupt = false;
   }
 }
 
 
}