import SimpleOpenNI.*;
import processing.serial.*;

//Generate a SimpleOpenNI object
SimpleOpenNI kinect;

Serial myPort;  // Create object from Serial class
PImage backgroundImage;
PImage bird;
PImage slingstand;
PImage fox;
PImage rectmatwoodhor;
PImage rectmatwoodver;
PImage rubberFront;
PImage rubberBack;
int slingdifx = 75;
int slingdify = 0;


void setup() {
  //fullScreen();
  backgroundImage = loadImage("angry_birds_background.jpg");
  bird = loadImage("grover1.png");
  slingstand = loadImage("slingshotempty.png");
  fox = loadImage("foxenemy1.png");
  rectmatwoodhor = loadImage("woodplankwaagprot.png");
  rectmatwoodver= loadImage("woodplanksenkprot.png");
  rubberFront=loadImage("rubberbandfront.png");
  rubberBack=loadImage("rubberbandback.png");
  
  
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  size(1280, 480);
  fill(255, 0, 0);
  kinect.setMirror(true);

  //Open the serial port
  //String portName = Serial.list()[1]; //change the 0 to a 1 or 2 etc. to match your port
  //myPort = new Serial(this, portName, 9600);
   // Ersetze "background.png" mit dem Pfad zu deinem Bild

  // Überprüfen, ob das Bild die richtige Größe hat
  if (backgroundImage.width != width || backgroundImage.height != height) {
    backgroundImage.resize(width, height);
  }
  
  // Ursprungsposition der Schleuder definieren
  slingshotOrigin = new PVector(150, height-330);
  //slingshotOrigin = new PVector(200, height - 150);
  velocity = new PVector(0, 0);
  //birdStartPosition = slingshotOrigin.copy();
  birdStartPosition = new PVector(150, 150);
  stretch = new PVector(0, 0);
  
  // Startposition des Vogels auf die Ursprungsposition setzen
  birdPosition = birdStartPosition.copy();
  
}

void draw() {
  kinect.update();
  //image(kinect.depthImage(), 640, 0);
  //fill(150);
  //rect(0, 0, 640, height);
  image(backgroundImage, 0, 0);
  
  fill(120, 70, 30);
  //rect(slingshotOrigin.x - 5, slingshotOrigin.y, 10, 50);  
  image(slingstand,slingshotOrigin.x-25, slingshotOrigin.y, 260/2, 490/2);
  fox();
  
  //image(loadImage("slingshotfin.png"), -100, height);
  //scale(5);
  //image(loadImage("grover2.png"), 0, 0);
  drawflight();


  IntVector userList = new IntVector();
  kinect.getUsers(userList);

  if (userList.size() > 0) {
    int userId = userList.get(0);
    //If we detect one user we have to draw it
    if (kinect.isTrackingSkeleton(userId)) {
      //User connected
      //onNewUser(kinect, userId);
      //Draw the skeleton user
      drawSkeleton(userId);
      // show the angles on the screen for debugging
      fill(255, 0, 0);
      scale(3);
      //text("shoulder: " + int(shoulderAngle) + "\n" + " elbow: " + int(elbowAngle), 20, 20);
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
  if (confidence < 0.9) {
    return;
  }
  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);
  fill(255, 0, 0);
  ellipse(convertedJoint.x, convertedJoint.y, 100, 100);
}
//Generate the angle
float angleOf(PVector one, PVector two, PVector axis) {
  PVector limb = PVector.sub(two, one);
  return degrees(PVector.angleBetween(limb, axis));
}
//Calibration not required
void onNewUser(SimpleOpenNI kinect, int userId) {
  println("Start skeleton tracking");
  kinect.startTrackingSkeleton(userId);
}
