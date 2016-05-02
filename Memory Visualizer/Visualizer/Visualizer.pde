int dataBlockSize = 32;
int bytesOfMemory = 32000;
int numDataBlocks = bytesOfMemory / dataBlockSize;
int arrayDimension = (int)sqrt(numDataBlocks);

DataBlock [][] dataMatrix = new DataBlock[arrayDimension][arrayDimension];

void setup() {
  size(1000,1000);
  background(255,255,255);
  
  //DataBlock(int x, int y, int w, int h)
  for(int i= 0; i< arrayDimension; i++) {
     for(int j = 0; j < arrayDimension; j++) {
       dataMatrix[i][j] = new DataBlock(i, j, 30,30);
     }
  }
}

void draw() {
  background(255,255,255);
  
  update();
  for(int i= 0; i< arrayDimension; i++) {
     for(int j = 0; j < arrayDimension; j++) {
       dataMatrix[i][j].display();
     }
  }
  
}

void update() {
  int targetIndexX = (int)random(0, arrayDimension);
  int targetIndexY = (int)random(0, arrayDimension);
  dataMatrix[targetIndexX][targetIndexY].isWritten = true;
}