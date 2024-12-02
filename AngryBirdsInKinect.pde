import SimpleOpenNI.*;
import processing.serial.*;


SimpleOpenNI kinect;

PImage backgroundImage,rightHandOpen, leftHandOpen, handClosed, slingshotImage, birdImage;
PVector rightHand, leftHand, screenPos;
int slingshotSize = 200;
int count = 0;
Bird bird , bird2;
HashMap<Integer, PVector> trackedHands = new HashMap<Integer, PVector>();

void setup() {
  // Kinect-Einstellungen
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableHand();    // Aktiviert Hand-Tracking
  kinect.startGesture(SimpleOpenNI.GESTURE_CLICK);
  kinect.startGesture(SimpleOpenNI.GESTURE_HAND_RAISE ); // Starte Geste "Wave"
  kinect.setMirror(true);
  //fullScreen();
  size(1840, 980);

  // Hände initialisieren
  rightHand = new PVector(0, 0);
  leftHand = new PVector(0, 0);

  // Bilder laden
  backgroundImage = loadImage("background.png");
  rightHandOpen = loadImage("rightHandOpen.png");
  handClosed = loadImage("leftHandClosed.png");
  leftHandOpen = loadImage("leftHandOpen.png");
  slingshotImage = loadImage("slingshotfin.png");
  birdImage = loadImage("grover1.png");

  // Hintergrundbildgröße überprüfen und anpassen
  if (backgroundImage.width != width || backgroundImage.height != height) {
    backgroundImage.resize(width, height);
  }

  // Vogel-Objekt initialisieren
  PVector slingshotOrigin = new PVector(200, height - 150);
  screenPos = new PVector();
  bird = new Bird(slingshotOrigin);
  bird2 = new Bird(slingshotOrigin);
}

void draw() {
  //delay(1000);
  // Kinect-Update
  kinect.update();

  // Hintergrund zeichnen
  image(backgroundImage, 0, 0);

  // Schleuder zeichnen
  //rect(bird.slingshotOrigin.x - 5, bird.slingshotOrigin.y, 10, 50);
  image(slingshotImage, bird.slingshotOrigin.x - slingshotSize/2 , bird.slingshotOrigin.y -slingshotSize/2, slingshotSize, slingshotSize);

  // Vogelbewegung und Zeichnung
  bird.drawFlight();
  drawHand();
  
  // Kinect-Benutzer verfolgen
  //IntVector userList = new IntVector();
  //kinect.getUsers(userList);
  
  
  //if (userList.size() > 0) {
  //  int userId = userList.get(0);

  //  if (kinect.isTrackingSkeleton(userId)) {
  //    drawSkeleton(userId);
  //  }
  //  PVector joint = new PVector();
  //  kinect.startTrackingHand(joint);
  //  println(joint);
  //}
  
}

void drawHand(){
  if(trackedHands.size()==0)return;
  for (HashMap.Entry<Integer, PVector> entry : trackedHands.entrySet()) {
    int handId = entry.getKey();
    PVector handPos = entry.getValue();
   
    handPos.x = map(handPos.x, 0, 640, -420, 2160);
    handPos.y = map(handPos.y, 0, 480, -240, 1680);

  decideIfRightOrLeft(handPos);
  
  if (dist(handPos.x, handPos.y, bird.birdPosition.x, bird.birdPosition.y) < 30) {
    count++;
  }
  
  if (count > 20 && handPos.x < width/2) {
    bird.startDragging(handPos);
    // Wenn Hände sich senken, wird der Vogel losgelassen
    if ( rightHand.y < 50 ) {
      count = 0;
      bird.releaseWithPower(1.25);
    }
  }
  if(trackedHands.size() == 1){
    if(handPos.x < width/2){
      drawLeftHand();
    }else{
      drawRightHand();
    }
  }else{
    drawRightHand();
    drawLeftHand();
  }
  }
}
void drawRightHand(){
  image(rightHandOpen, rightHand.x - 50, rightHand.y - 50, 100, 100);
}
void drawLeftHand(){
  if(count > 20){
    image(handClosed, leftHand.x - 50, leftHand.y - 50, 100, 100);
  }else{
    image(leftHandOpen, leftHand.x - 50, leftHand.y - 50, 100, 100);
  }
}

 void decideIfRightOrLeft(PVector handPos){
   if(
   dist(handPos.x, handPos.y, leftHand.x, leftHand.y) < 100 && 
   dist(leftHand.x, leftHand.y, rightHand.x, rightHand.y) >100
   ){
     leftHand.set(handPos.x, handPos.y);
   }else if(
     dist(handPos.x, handPos.y, rightHand.x, rightHand.y) < 100 && 
     dist(leftHand.x, leftHand.y, rightHand.x, rightHand.y) > 100
   ){
     rightHand.set(handPos.x, handPos.y);
   }else{
     if (handPos.x >= width / 2) {
      rightHand.set(handPos.x, handPos.y);
    } else {
      leftHand.set(handPos.x, handPos.y);
    }
   }
 }
 //if(
 //  leftHand.x != 0 && leftHand.y != 0 &&
 //  rightHand.x != 0 && rightHand.y != 0 &&
 //  dist(handPos.x, handPos.y, leftHand.x, leftHand.y) < 
 //  dist(handPos.x, handPos.y, rightHand.x, rightHand.y)
   
 //  ){
 //    leftHand.set(handPos.x, handPos.y);
 //  }else if(
 //  rightHand.x != 0 && rightHand.y != 0 &&
 //  leftHand.x != 0 && leftHand.y != 0 &&
 //    dist(handPos.x, handPos.y, rightHand.x, rightHand.y) < 
 //    dist(handPos.x, handPos.y, leftHand.x, leftHand.y) 
 //  )
 

void mousePressed() {
  bird.handleMousePressed(mouseX, mouseY); // Maus-Interaktion an Vogel delegieren
}

void mouseDragged() {
  bird.handleMouseDragged(mouseX, mouseY); // Maus-Interaktion an Vogel delegieren
}

void mouseReleased() {
  bird.handleMouseReleased(); // Maus-Interaktion an Vogel delegieren
}

void keyPressed() {
  if (!bird.isFlying) {
    bird.resetBird(); // Nur zurücksetzen, wenn der Vogel nicht fliegt
  }
}

void onNewHand(SimpleOpenNI curContext, int handId, PVector pos) {
  //println("Neue Hand erkannt - ID: " + handId + ", Position: " + pos);
}

void onTrackedHand(SimpleOpenNI curContext, int handId, PVector pos) {
  PVector screenPos = new PVector();
  kinect.convertRealWorldToProjective(pos, screenPos);
  trackedHands.put(handId, screenPos);
  
}
void onLostHand(SimpleOpenNI curContext, int handId) {
  //println("Hand verloren - ID: " + handId);
  trackedHands.remove(handId);
}

void onCompletedGesture(SimpleOpenNI curContext, int gestureType, PVector pos) {
  //println("Geste erkannt: " + gestureType + ", Position: " + pos);
  if(gestureType == 1){
    println(SimpleOpenNI.GESTURE_CLICK);
  }
  // Starte Hand-Tracking
  int handId = kinect.startTrackingHand(pos);
  //println("Hand-Tracking gestartet mit ID: " + handId);
}
