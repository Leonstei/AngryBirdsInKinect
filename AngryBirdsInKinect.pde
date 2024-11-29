import shiffman.box2d.*;

import SimpleOpenNI.*;
import processing.serial.*;

SimpleOpenNI kinect;

PImage backgroundImage,rightHandOpen, handOpen, handClosed, slingstand, slingstandfr, birdImage, fox, backr, frontr, glassno, woodno, stoneno;
PVector rightHand, leftHand;
PVector blockpos; //Koordinaten vom Editorblock
float zoom = 1; //Zoomfaktor
final static float inc = 0.1; // Zoomschrittweite
int count = 0;
int status = 0; //um zwischen den Modi zu wechseln
int step = 100; //um den Raster zu vergrößern/schrumpfen
boolean isDraggingBlock= false; //um Blöcke vom Editor aufzunehmen
//PVector buildpos;
int blockstatus = 0;
Bird bird;

void setup() {
  // Kinect-Einstellungen
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  kinect.setMirror(true);
  fullScreen();
  //size(1920, 1080,P3D);

  // Hände initialisieren
  rightHand = new PVector(0, 0);
  leftHand = new PVector(0, 0);
  
  blockpos = new PVector(1800,100);

  // Bilder laden
  backgroundImage = loadImage("background.png"); //Hintergrund
  rightHandOpen = loadImage("handkinectr.png"); //Rechte Kinecthand
  handClosed = loadImage("handkinectclosedr.png"); // Rechte geschlossene Kinecthand
  handOpen = loadImage("handkinect.png"); //Linke Kinecthand
  slingstand = loadImage("slingshotempty.png"); //Offene Schleuder ohne Gummiband
  slingstandfr = loadImage("slingshotemptyfr.png"); //Vorderteil der Schleuder
  birdImage = loadImage("grover1.png"); //Vogel
  backr= loadImage("rubberbandback.png"); //Hinterteil Gummiband
  frontr= loadImage("rubberbandfront.png"); //Vorderteil Gummiband
  fox= loadImage("foxenemy1.png"); //Fuchs/Gegner
  glassno= loadImage("gsnodmg.png"); //Senkrechter Glassblock ohne Schaden
  woodno= loadImage("wpsnodmg.png"); //Senkrechter Holzblock ohne Schaden
  stoneno= loadImage("stsnodmg.png"); //Senkrechter Steinblock ohne Schaden

  // Hintergrundbildgröße überprüfen und anpassen
  if (backgroundImage.width != width || backgroundImage.height != height) {
    backgroundImage.resize(width, height);
  }

  // Vogel-Objekt initialisieren
  PVector slingshotOrigin = new PVector(235, height - 280);
  bird = new Bird(slingshotOrigin);
}

void draw() {
  // Kinect-Update
  kinect.update();
 //Zoom In und Out
 //Beim Reinzoomen kann man nach links und rechts wischen um den Rest des Bildschirms zu sehen.
  float centerX = mouseX - (mouseX - width/2) * zoom; //X Koordinate für Zoom auf Mauszeiger
  float centerY = mouseY - (mouseY - height/2) * zoom; //Y Koordinate für Zoom auf Mauszeiger
  float slingX = 735*zoom; //Zusätzliche X Variable für die Schleuderposition
  float slingY = 350*zoom; //Zusätzliche Y Variable für die Schleuderposition
  imageMode(CENTER); //zentriert das Bild (sonst wird die linke obere Ecke des Hintergrunds an die Mitte positioniert)
  image(backgroundImage, centerX, centerY, backgroundImage.width * zoom, backgroundImage.height * zoom);
  image(slingstand,centerX-slingX, centerY+slingY, 260/2*zoom, 490/2*zoom);
  
  if(blockstatus==1){
  image(glassno,blockpos.x,blockpos.y, 50, 150);  
  }
  //Baumodus
  if(status==1){
  image(glassno, 1800,100, 50, 150); //Blockauswahl
  //handleMousePressedBlock(mouseX,mouseY); //Block klickbar
  //handleMouseDraggedBlock(mouseX,mouseY); //Block ziehbar machen

  
   textSize(100);
   fill(10);
   text("Mode: Building", 100, 100);
   for(int i = 0; i < width/step; i++ ) {
     
     line(i*step, 0, i*step, height);
     line(0, i*step, width, i*step);
     } 
   } else {
      textSize(100);
      fill(10);
      text("Mode: Play", 100, 100);
}


  // Vogelbewegung und Zeichnung
  bird.drawFlight(zoom, centerX, centerY);
  image(slingstandfr,centerX-slingX, centerY+slingY, 260/2*zoom, 490/2*zoom);
  textSize(15);
  fill(10);
  text("Instructions:",1550,20);
  text("Press right or center mouse button to zoom.",1550,40);
  text("Press 'b' or 'p' to turn grid on/off. Press '+'",1550,60);
  text("or '-' to increase grid width.",1550,80);
  
  //Zoom erhöhen/senken
  if (mousePressed)
    if (mouseButton == CENTER && zoom < 1.6)   zoom += inc; //Mittlere Maustaste klicken um Bild zu vergrößern.
      else if (mouseButton == RIGHT && zoom > 1)  zoom -= inc; //Rechte Maustaste um Bild zu verkleinern.





//-----------------------------------------------------------------------------------------------------------------------------------
//Kinect Abschnitt


  // Kinect-Benutzer verfolgen
  IntVector userList = new IntVector();
  kinect.getUsers(userList);

  if (userList.size() > 0) {
    int userId = userList.get(0);

    if (kinect.isTrackingSkeleton(userId)) {
      drawSkeleton(userId);
    }
  }
}

void drawSkeleton(int userId) {
  stroke(5);
  strokeWeight(5);

  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
}

void drawJoint(int userId, int jointId) {
  PVector joint = new PVector();
  float confidence = kinect.getJointPositionSkeleton(userId, jointId, joint);

  if (confidence < 0.8) {
    return;
  }

  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);

  convertedJoint.x = map(convertedJoint.x, 0, 640, -420, 2160);
  convertedJoint.y = map(convertedJoint.y, 0, 480, -240, 1680);


  if (jointId == SimpleOpenNI.SKEL_RIGHT_HAND) {
    rightHand.set(convertedJoint.x, convertedJoint.y);
  } else if (jointId == SimpleOpenNI.SKEL_LEFT_HAND) {
    leftHand.set(convertedJoint.x, convertedJoint.y);
  }

  // Kinect-Interaktion mit dem Vogel
  if (dist(convertedJoint.x, convertedJoint.y, bird.birdPosition.x, bird.birdPosition.y) < 20) {
    count++;
  }

  if (count > 20 && jointId == SimpleOpenNI.SKEL_LEFT_HAND) {
    bird.startDragging(convertedJoint);
    // Wenn Hände sich senken, wird der Vogel losgelassen
    if ( rightHand.y < 50 ) {
      count = 0;
      bird.releaseWithPower(0.4);
    }
  }

  // Hand-Symbol zeichnen
  if(count > 20 && jointId == SimpleOpenNI.SKEL_LEFT_HAND){
    image(handClosed, convertedJoint.x - 50, convertedJoint.y - 50, 100, 100);
  }else if(jointId == SimpleOpenNI.SKEL_RIGHT_HAND){
    image(rightHandOpen, convertedJoint.x - 50, convertedJoint.y - 50, 100, 100);
  }else{
    image(handOpen, convertedJoint.x - 50, convertedJoint.y - 50, 100, 100);
  }
  
}
//--------------------------------------------------------------------------------------------------------------
//Void Abschnitt


void mousePressed() {
  bird.handleMousePressed(mouseX, mouseY); // Maus-Interaktion an Vogel delegieren
  handleMousePressedBlock(mouseX,mouseY);
}

void mouseDragged() {
  bird.handleMouseDragged(mouseX, mouseY); // Maus-Interaktion an Vogel delegieren
  handleMouseDraggedBlock(mouseX,mouseY);
}

void mouseReleased() {
  bird.handleMouseReleased(); // Maus-Interaktion an Vogel delegieren
  handleMouseReleasedBlock();
}


void handleMousePressedBlock(float mouseX, float mouseY) {
    // Überprüfen, ob der Block gedrückt wird
    
    if (dist(mouseX, mouseY, blockpos.x, blockpos.y) < 15) {
      //count++;
      isDraggingBlock = true;
      blockstatus=1;
    }
  }

void handleMouseDraggedBlock(float mouseX, float mouseY) {
    // Aktualisiere die Blockposition, wenn gezogen wird
    if(isDraggingBlock == true) { 
      //testblock2=testblock.copy();
      //ellipse(testblock.x,testblock.y,100,100);
      //image(glassno,testblock.x,testblock.y, 50, 150);
      blockpos.set(mouseX, mouseY);
      
    }
  }

void handleMouseReleasedBlock() {
    if (isDraggingBlock) {
      
      isDraggingBlock = false; // Beendet das Ziehen
      
    }
  }
  


void keyPressed() {
      if(key == 'b' && status != 1){
        println("Mode switched to Building"); 
        //text("Mode switched to Building", 100, 100);
        status = 1;
    }
  
    if(key == 'p' && status == 1){
        println("Mode switched to Play");
        //text("Mode switched to Play", 100, 100);
        status = 0;
    }
    if(key == 'r'){
      if(!bird.isFlying){
        bird.resetBird(); // Nur zurücksetzen, wenn der Vogel nicht fliegt
      }  
    }
  
    if(key == '+' && step < 150){
      step += 10;
    }
    
    if(key == '-' && step > 50){
      step -= 10;
    }
}


void onNewUser(SimpleOpenNI kinect, int userId) {
  println("Start skeleton tracking");
  kinect.startTrackingSkeleton(userId);
}
