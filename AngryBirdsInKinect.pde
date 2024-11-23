import SimpleOpenNI.*;
import processing.serial.*;

SimpleOpenNI kinect;

PImage backgroundImage,rightHandOpen, handOpen, handClosed, slingstand, slingstandfr, birdImage, fox, backr, frontr;
PVector rightHand, leftHand;
float zoom = 1;
final static float inc = 0.1;
int count = 0;
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

  // Bilder laden
  backgroundImage = loadImage("background.png");
  rightHandOpen = loadImage("handkinectr.png");
  handClosed = loadImage("handkinectclosedr.png");
  handOpen = loadImage("handkinect.png");
  slingstand = loadImage("slingshotempty.png");
  slingstandfr = loadImage("slingshotemptyfr.png");
  birdImage = loadImage("grover1.png");
  backr= loadImage("rubberbandback.png");
  frontr= loadImage("rubberbandfront.png");
  fox= loadImage("foxenemy1.png");

  // Hintergrundbildgröße überprüfen und anpassen
  if (backgroundImage.width != width || backgroundImage.height != height) {
    backgroundImage.resize(width, height);
  }

  // Vogel-Objekt initialisieren
  PVector slingshotOrigin = new PVector(235, height - 280);
  bird = new Bird(slingshotOrigin, birdImage);
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

  // Vogelbewegung und Zeichnung
  bird.drawFlight(zoom, centerX, centerY);
  image(slingstandfr,centerX-slingX, centerY+slingY, 260/2*zoom, 490/2*zoom);
  
  //Zoom erhöhen/senken
  if (mousePressed)
    if      (mouseButton == CENTER && zoom < 1.6)   zoom += inc; //Mittlere Maustaste klicken um Bild zu vergrößern.
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
