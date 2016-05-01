import processing.serial.*;

import java.util.*;

int dataBlockSize = 32;
int bytesOfMemory = 32000;
int numDataBlocks = bytesOfMemory / dataBlockSize;
int arrayDimension = (int)sqrt(numDataBlocks);

DataBlock [][] dataMatrix = new DataBlock[arrayDimension][arrayDimension];
Map addrLookUp = new HashMap();

Serial port;
String input;
int bitRate = 9600;

List<UIButton> buttons;

boolean changeData = true;

void setup() {
  size(1000,1000);
  background(255,255,255);
  //setupSerial();
  
  int iterator = 0;
  for(int i= 0; i< arrayDimension; i++) {
     for(int j = 0; j < arrayDimension; j++) {
       iterator++;
       DataBlock data = new DataBlock(i, j, 30,30, iterator);
       dataMatrix[i][j] = data;
       addrLookUp.put(iterator, data.index);
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
  
  //readSerial();
  if(changeData) {
  int targetAddr = (int)random(1, (arrayDimension*arrayDimension));
  PVector target = (PVector)addrLookUp.get(targetAddr);
  dataMatrix[(int)target.x][(int)target.y].isWritten = true;
  
  targetAddr = (int)random(1, (arrayDimension*arrayDimension));
  target = (PVector)addrLookUp.get(targetAddr);
  dataMatrix[(int)target.x][(int)target.y].clearBlock();
  }
  
  for( UIButton b : buttons) {
     b.update(); 
     if(b.isPressed){
       if(b.command=="Start/Stop") changeData = !changeData;
       if(b.command=="clear") clearAll();
       if(b.command=="fill") fillAll();
     }
  }
}

void setupSerial() {
  String portName = Serial.list()[0];
  port = new Serial(this, portName, bitRate);
}

void readSerial() {
 if ( port.available() > 0) 
  {  
  input = port.readStringUntil('\n'); 
  }  
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