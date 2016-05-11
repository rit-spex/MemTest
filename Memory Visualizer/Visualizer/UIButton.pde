//self contained class for clickable UI elements
class UIButton {
 int xPos,yPos,boxWidth,boxHeight; //display variables
 String buttonText; //displayed text
 String command; //actual processed command
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
 
 //displays button in window
 void display() {
   textAlign(CENTER, CENTER);
   fill(20,160,191);
   if(command=="" || command=="corrupt" || command=="written") fill(232,204,178); //data display buttons are colored differently
   rect(xPos, yPos, boxWidth, boxHeight);
   fill(0);
   textSize(30);
   text(buttonText, xPos +(boxWidth/2), yPos + (boxHeight/2));
 }
 
 //checks for mouse input
 void update() {
   if(isWithin(mouseX, mouseY) && mousePressed && !previousButton) {
     //isWritten = !isWritten;
     //println("Click recorded at " + address + " with data: " + data);
     println(command);
     isPressed=true;
   } else isPressed=false;
   previousButton=mousePressed;
   
 }
 
 //checks if mouse is within button's dimensions
 boolean isWithin(int x, int y){
    int minX = xPos;
    int minY = yPos;
    
    int maxX = (int)minX + boxWidth;
    int maxY = (int)minY + boxHeight;
    
    if(x>minX && x<maxX && y>minY && y<maxY) return true;
    return false;
  }
  
}