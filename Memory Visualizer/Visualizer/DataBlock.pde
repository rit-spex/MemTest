class DataBlock {
  PVector index;
  PVector dimensions;
  String data;
  boolean isWritten;
  int address;
  
  DataBlock(int x, int y, int w, int h, String d, int addr) {
    index = new PVector(x, y);
    dimensions = new PVector(w, h);
    data = d;
    address = addr;
    isWritten = true;
  }
  
  DataBlock(int x, int y, int w, int h) {
    index = new PVector(x, y);
    dimensions = new PVector(w, h);
    data = "No Data Stored";
    address = -1;
    isWritten = false;
  }
  
  void display() {
    if(isWritten)fill(255,0,0);
    if(!isWritten)fill(0,255,0);
    rect(index.x * dimensions.x, index.y * dimensions.y, dimensions.x, dimensions.y);
  }
  
  void changeData(String d) {
    if(data == "No Data Stored") isWritten = true;
    data = d;
  }
  
  boolean isData() {
   if(isWritten) return true; 
   return false;
  }
}