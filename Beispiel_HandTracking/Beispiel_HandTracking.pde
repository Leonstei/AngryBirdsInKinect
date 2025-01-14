import SimpleOpenNI.*;

SimpleOpenNI context;

void setup() {
  size(1280, 960);

  // Initialisiere SimpleOpenNI
  context = new SimpleOpenNI(this);
  if (!context.isInit()) {
    println("Kinect konnte nicht initialisiert werden.");
    exit();
  }
  context.enableDepth();

  // Aktivierung von Hand-Tracking und Gesten-Erkennung
  //context.enableGesture(); // Aktiviert Gesten-Erkennung
  context.enableHand();    // Aktiviert Hand-Tracking
  context.startGesture(SimpleOpenNI.GESTURE_CLICK ); 
  context.startGesture(SimpleOpenNI.GESTURE_HAND_RAISE );
  context.startGesture(SimpleOpenNI.GESTURE_WAVE );
  context.setMirror(true);
}

void draw() {
  context.update();

  // Zeichne das Tiefenbild
  image(context.depthImage(), 640, 0);
  
}

void onNewHand(SimpleOpenNI curContext, int handId, PVector pos) {
  //println("Neue Hand erkannt - ID: " + handId + ", Position: " + pos);
}

void onTrackedHand(SimpleOpenNI curContext, int handId, PVector pos) {
  //println("Hand wird getrackt - ID: " + handId + ", Position: " + pos);

  // Zeichne die Hand auf dem Bildschirm
  //PVector screenPos = new PVector();
  //context.convertRealWorldToProjective(pos, screenPos);
  //println(screenPos.z);
  //fill(0, 255, 0);
  //ellipse(screenPos.x, screenPos.y, 20, 20);
}

void onLostHand(SimpleOpenNI curContext, int handId) {
  println("Hand verloren - ID: " + handId);
}

void onCompletedGesture(SimpleOpenNI curContext, int gestureType, PVector pos) {
  //println("Geste erkannt: " + gestureType + ", Position: " + pos);
  if(gestureType == 1){
    PVector screenPos = new PVector();
    context.convertRealWorldToProjective(pos, screenPos);
    fill(255, 0, 0);
    ellipse(screenPos.x, screenPos.y, 30, 30);
  }
  if(gestureType == 2){
    PVector screenPos = new PVector();
    context.convertRealWorldToProjective(pos, screenPos);
    screenPos.y = screenPos.y + 480;
    fill(0, 255, 0);
    ellipse(screenPos.x, screenPos.y, 20, 20);
  }
  if(gestureType == 0){
    PVector screenPos = new PVector();
    context.convertRealWorldToProjective(pos, screenPos);
    screenPos.x = screenPos.x + 640;
    screenPos.y = screenPos.y + 480;
    fill(0, 0, 255);
    ellipse(screenPos.x, screenPos.y, 20, 20);
  }
  
  
  // Starte Hand-Tracking
  int handId = context.startTrackingHand(pos);
  //println("Hand-Tracking gestartet mit ID: " + handId);
}
