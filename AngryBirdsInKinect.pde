import SimpleOpenNI.*;
import processing.serial.*;

SimpleOpenNI kinect;

PImage backgroundImage, blackHand, handOpen, slingshotImage, birdImage;
PVector rightHand, leftHand;
int count = 0;
Bird bird;

void setup() {
  // Kinect-Einstellungen
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  kinect.setMirror(true);
  
  size(1280, 480);

  // Hände initialisieren
  rightHand = new PVector(0, 0);
  leftHand = new PVector(0, 0);

  // Bilder laden
  backgroundImage = loadImage("angry_birds_background.jpg");
  blackHand = loadImage("black-hand.png");
  handOpen = loadImage("hand.png");
  slingshotImage = loadImage("slingshotfin.png");
  birdImage = loadImage("grover2.png");

  // Hintergrundbildgröße überprüfen und anpassen
  if (backgroundImage.width != width || backgroundImage.height != height) {
    backgroundImage.resize(width, height);
  }

  // Vogel-Objekt initialisieren
  PVector slingshotOrigin = new PVector(200, height - 150);
  bird = new Bird(slingshotOrigin, birdImage);
}

void draw() {
  // Kinect-Update
  kinect.update();

  // Hintergrund zeichnen
  image(backgroundImage, 0, 0);

  // Schleuder zeichnen
  fill(120, 70, 30);
  rect(bird.slingshotOrigin.x - 5, bird.slingshotOrigin.y, 10, 50);
  image(slingshotImage, bird.slingshotOrigin.x - 5, bird.slingshotOrigin.y , 100, 100);

  // Vogelbewegung und Zeichnung
  bird.drawFlight();

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
  convertedJoint.x = map(convertedJoint.x, 0, 640, -280, 720);
  convertedJoint.y = map(convertedJoint.y, 0, 480, -180, 780);

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
  image(handOpen, convertedJoint.x - 50, convertedJoint.y - 50, 100, 100);
}

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

void onNewUser(SimpleOpenNI kinect, int userId) {
  println("Start skeleton tracking");
  kinect.startTrackingSkeleton(userId);
}
