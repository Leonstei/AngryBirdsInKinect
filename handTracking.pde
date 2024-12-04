void setupKinect(){
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableHand();    // Aktiviert Hand-Tracking
  kinect.startGesture(SimpleOpenNI.GESTURE_CLICK);
  kinect.startGesture(SimpleOpenNI.GESTURE_HAND_RAISE ); // Starte Geste "Wave"
  kinect.setMirror(true);
  
  // Hände initialisieren
  rightHand = new PVector(0, 0);
  leftHand = new PVector(0, 0);
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
