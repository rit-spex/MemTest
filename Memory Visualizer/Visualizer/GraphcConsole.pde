import java.util.List;

class GraphicConsole {
  //String buffer;
  LinkedList<String> buffer;
  int xPos,yPos,boxWidth,boxHeight, currentLine, maxLine;
  PFont font;
  
  GraphicConsole(int xPos, int yPos, int boxWidth, int boxHeight) {
    buffer = new LinkedList<String>();
    this.xPos = xPos;
    this.yPos = yPos;
    this.boxWidth = boxWidth;
    this.boxHeight = boxHeight;
    //this.font = font;
    buffer.addLast( "Console Initalized");
    currentLine= 1;
    maxLine = 24;
  }
  
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
  
  void println(String input) {
    if(input!=null) {
   buffer.addLast(input);
   currentLine++;
  if(currentLine>maxLine) buffer.removeFirst();
    }
  }
 
  
  void clear() {
   buffer.clear();
  }
}