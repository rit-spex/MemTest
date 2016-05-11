//represents a page in memory on the arduino chip
class DataBlock {
  PVector index; //index of its position in dataMatrix
  PVector dimensions; //holds size for drawing
  String data; //actual stored data
  boolean isWritten; 
  boolean isCorrupt; //flag is data contained is corrupted
  int address; //address to page in chip memory
  boolean previousButton; //supports single click changes
  
  DataBlock(int x, int y, int w, int h, int addr, String d ) {
    index = new PVector(x, y);
    dimensions = new PVector(w, h);
    data = d;
    address = addr;
    isWritten = true;
    isCorrupt = false;
  }
  
  //constructor creates empty data block, used for initalization of dataMatrix before serial communication is established
  DataBlock(int x, int y, int w, int h, int addr) {
    index = new PVector(x, y);
    dimensions = new PVector(w, h);
    data = "";
    address = addr;
    isWritten = false;
    isCorrupt = false;

  }
  //draws the dataBlock in the dataMatrix
  void display() {
    if(isWritten)fill(99,178,15);
    if(!isWritten)fill(204,51,11);
    if(isCorrupt)fill(102,25,6);
    rect(index.x * dimensions.x, index.y * dimensions.y, dimensions.x, dimensions.y);
  }
  
  //simple update function handles mouse interaction on a per block basis
  void update() {
    if(isWithin(mouseX, mouseY) && mousePressed && !previousButton) {
     isWritten = !isWritten;
   }
   previousButton=mousePressed;
  }
  //function for safety setting data
  void changeData(String d) {
    if(data == "") isWritten = true;
    data = d;
  }
  
  //checks to make sure data is contained within the block
  boolean isData() {
   if(isWritten) return true; 
   return false;
  }
  
  //resets the block to empty
  void clearBlock() {
    data = "";
    //address = -1;
    isWritten = false;
  }
  //simple check for mouse click within button bounds
  boolean isWithin(int x, int y){
    int minX = (int)index.x * (int)dimensions.x;
    int minY = (int)index.y * (int)dimensions.y;
    
    int maxX = (int)minX + (int)dimensions.x;
    int maxY = (int)minY + (int)dimensions.y;
    
    if(x>minX && x<maxX && y>minY && y<maxY) return true;
    return false;
  }
}