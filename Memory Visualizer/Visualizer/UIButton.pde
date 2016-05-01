class UIButton {
 int xPos,yPos,boxWidth,boxHeight;
 String buttonText;
 String command;
 boolean previousButton;
 boolean isPressed;
 UIButton(int x, int y, int w, int h, String text, String c) {
   xPos = x;
   yPos = y;
   boxWidth = w;
   boxHeight = h;
   buttonText = text;
   command = c;
   isPressed=false;
 }
 
 void display() {
   textAlign(CENTER, CENTER);
   fill(100,155,255);
   rect(xPos, yPos, boxWidth, boxHeight);
   fill(0);
   textSize(30);
   text(buttonText, xPos +(boxWidth/2), yPos + (boxHeight/2));
 }
 
 void update() {
   if(isWithin(mouseX, mouseY) && mousePressed && !previousButton) {
     //isWritten = !isWritten;
     //println("Click recorded at " + address + " with data: " + data);
     println(command);
     isPressed=true;
   } else isPressed=false;
   previousButton=mousePressed;
   
 }
 
 boolean isWithin(int x, int y){
    int minX = xPos;
    int minY = yPos;
    
    int maxX = (int)minX + boxWidth;
    int maxY = (int)minY + boxHeight;
    
    if(x>minX && x<maxX && y>minY && y<maxY) return true;
    return false;
  }
}