class DataBlock {
  PVector index;
  PVector dimensions;
  String data;
  boolean isWritten;
  boolean isCorrupt;
  int address;
  boolean previousButton;
  DataBlock(int x, int y, int w, int h, int addr, String d ) {
    index = new PVector(x, y);
    dimensions = new PVector(w, h);
    data = d;
    address = addr;
    isWritten = true;
    isCorrupt = false;
  }
  
  DataBlock(int x, int y, int w, int h, int addr) {
    index = new PVector(x, y);
    dimensions = new PVector(w, h);
    data = "";
    address = addr;
    isWritten = false;
    isCorrupt = false;

  }
  
  void display() {
    if(isWritten)fill(99,178,15);
    if(!isWritten)fill(204,51,11);
    if(isCorrupt)fill(102,25,6);
    rect(index.x * dimensions.x, index.y * dimensions.y, dimensions.x, dimensions.y);
  }
  
  void update() {
    if(isWithin(mouseX, mouseY) && mousePressed && !previousButton) {
     isWritten = !isWritten;
     //println("Click recorded at " + address + " with data: " + data);
   }
   previousButton=mousePressed;
  }
  
  void changeData(String d) {
    if(data == "") isWritten = true;
    data = d;
  }
  
  boolean isData() {
   if(isWritten) return true; 
   return false;
  }
  
  void clearBlock() {
    data = "";
    //address = -1;
    isWritten = false;
  }
  
  boolean isWithin(int x, int y){
    int minX = (int)index.x * (int)dimensions.x;
    int minY = (int)index.y * (int)dimensions.y;
    
    int maxX = (int)minX + (int)dimensions.x;
    int maxY = (int)minY + (int)dimensions.y;
    
    if(x>minX && x<maxX && y>minY && y<maxY) return true;
    return false;
  }
}