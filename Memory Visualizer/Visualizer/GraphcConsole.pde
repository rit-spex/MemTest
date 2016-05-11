import java.util.List;

//class manages a text console that uses the Processing graphics engine
class GraphicConsole {
  LinkedList<String> buffer; // each row of the console is its own string
  int xPos,yPos,boxWidth,boxHeight, currentLine, maxLine; // display variables
  PFont font;
  
  GraphicConsole(int xPos, int yPos, int boxWidth, int boxHeight) {
    buffer = new LinkedList<String>();
    this.xPos = xPos;
    this.yPos = yPos;
    this.boxWidth = boxWidth;
    this.boxHeight = boxHeight;
    buffer.addLast( "Console Initalized");
    currentLine= 1;
    maxLine = 24;// determines the maximum height of the console before text loops
  }
  
  //draws the various components of the console as well as the data
  void display() {
   
   //draw console window
   fill(211,211,211);
   rect(xPos, yPos, boxWidth, boxHeight);
   
   //draw header
   textAlign(CENTER, CENTER);
   fill(243,110,33);
   rect(xPos, yPos, boxWidth, 100);
   fill(0);
   textSize(50);
   text("Arduino Memory Controller Output", xPos +(boxWidth/2), yPos + (100/2));
   
   //draw text
   textAlign(LEFT);
   fill(0);
   int lineSize = 30;
   textSize(lineSize);
      for(int i = 0; i < buffer.size()-1; i++) {
       String line = buffer.get(i);
       text(line, xPos + 10, yPos + 150 + (lineSize * i));
   }
   
  }
  
  //adds string to the console on its own line
  void println(String input) {
    if(input!=null) {
   buffer.addLast(input);
   currentLine++;
  if(currentLine>maxLine) buffer.removeFirst(); // allows old lines to be discarded to make way for new information
    }
  }
 
  //clears entire console
  void clear() {
   buffer.clear();
  }
}