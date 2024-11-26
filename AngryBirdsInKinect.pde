import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;
import processing.serial.*;



PImage backgroundImage,rightHandOpen, handOpen, handClosed, slingshotImage, birdImage;
PVector rightHand, leftHand;
int slingshotSize = 200;
int count = 0;
Bird bird , bird2;
Kinect kinect;
ArrayList <SkeletonData> bodies;
float minDist, maxDist, offen;
boolean isClosed = false;

void setup() {
  // Kinect-Einstellungen
  kinect = new Kinect(this);
  //fullScreen();
  size(1840, 980);
  bodies = new ArrayList<SkeletonData>();

  // Hände initialisieren
  rightHand = new PVector(0, 0);
  leftHand = new PVector(0, 0);

  // Bilder laden
  backgroundImage = loadImage("background.png");
  rightHandOpen = loadImage("rightHandOpen.png");
  handClosed = loadImage("leftHandClosed.png");
  handOpen = loadImage("leftHandOpen.png");
  slingshotImage = loadImage("slingshotfin.png");
  birdImage = loadImage("grover1.png");

  // Hintergrundbildgröße überprüfen und anpassen
  if (backgroundImage.width != width || backgroundImage.height != height) {
    backgroundImage.resize(width, height);
  }

  // Vogel-Objekt initialisieren
  PVector slingshotOrigin = new PVector(200, height - 150);
  bird = new Bird(slingshotOrigin);
  bird2 = new Bird(slingshotOrigin);
}

void draw() {
  // Kinect-Update
  

  // Hintergrund zeichnen
  image(backgroundImage, 0, 0);

  // Schleuder zeichnen
  //rect(bird.slingshotOrigin.x - 5, bird.slingshotOrigin.y, 10, 50);
  image(slingshotImage, bird.slingshotOrigin.x - slingshotSize/2 , bird.slingshotOrigin.y -slingshotSize/2, slingshotSize, slingshotSize);

  // Vogelbewegung und Zeichnung
  bird.drawFlight();
  
  // Kinect-Benutzer verfolgen
  
  
  
  for (int i=0; i<bodies.size (); i++) 
  {
    drawSkeleton(bodies.get(i));
    //drawPosition(bodies.get(i));
  }
  
}

void drawSkeleton(SkeletonData _s) {
  stroke(5);
  strokeWeight(5);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_WRIST_LEFT, 
  Kinect.NUI_SKELETON_POSITION_HAND_LEFT);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT, 
  Kinect.NUI_SKELETON_POSITION_HAND_RIGHT);
}

void DrawBone(SkeletonData _s, int _j1, int _j2) 
{
  noFill();
  stroke(255, 255, 0);
  if (_s.skeletonPositionTrackingState[_j1] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED &&
    _s.skeletonPositionTrackingState[_j2] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
    line(_s.skeletonPositions[_j1].x*width/2, 
    _s.skeletonPositions[_j1].y*height/2, 
    _s.skeletonPositions[_j2].x*width/2, 
    _s.skeletonPositions[_j2].y*height/2);
  }
  PVector convertedJoint = new PVector();
  if(_j1 == Kinect.NUI_SKELETON_POSITION_WRIST_LEFT){
    convertedJoint.x = map(_s.skeletonPositions[_j1].x*640, 0, 640, -420, 2160);
    convertedJoint.y = map(_s.skeletonPositions[_j1].y*480, 0, 480, -240, 1680);
    ellipse(_s.skeletonPositions[_j1].x*width/2, _s.skeletonPositions[_j1].y*height/2, 20, 20);
  }
  if(_j2 == Kinect.NUI_SKELETON_POSITION_HAND_LEFT){
    convertedJoint.x = map(_s.skeletonPositions[_j2].x*640, 0, 640, -420, 2160);
    convertedJoint.y = map(_s.skeletonPositions[_j2].y*480, 0, 480, -240, 1680);
    leftHand.set(convertedJoint.x, convertedJoint.y);
    ellipse(_s.skeletonPositions[_j2].x*width/2, _s.skeletonPositions[_j2].y*height/2, 20, 20);
    PVector wrist = new PVector ( _s.skeletonPositions[_j1].x*width/2, _s.skeletonPositions[_j1].y*height/2);
    PVector hand = new PVector ( _s.skeletonPositions[_j2].x*width/2, _s.skeletonPositions[_j2].y*height/2);
    println("" + _s.skeletonPositions[_j2].z );
    minDist = 6000.0;
    maxDist = 20000.0;
    offen = map(_s.skeletonPositions[_j2].z,minDist,maxDist,17,8);
    println("offen = " + offen );
    println("dictance between hand an wrist =" + PVector.sub(wrist,hand).mag());
    if(PVector.sub(wrist,hand).mag()>=offen){
      println("hand offen");
      isClosed =false;
    }else{
      println("hand zu");
      isClosed = true;
    }
  }
  if(isClosed){
    image(handClosed, leftHand.x - 50, leftHand.y - 50, 100, 100);
    bird.startDragging(leftHand);
  }
  //if(isClosed && dist(leftHand.x, leftHand.y, bird.birdPosition.x, bird.birdPosition.y) < 20){
  //  image(handClosed, leftHand.x - 50, leftHand.y - 50, 100, 100);
  //  bird.startDragging(leftHand);
  //}else if(!isClosed && bird.isDragging){
  //  image(handOpen, leftHand.x - 50, leftHand.y - 50, 100, 100);
  //   bird.releaseWithPower(0.4);
  //}else{
  //  image(handOpen, leftHand.x - 50, leftHand.y - 50, 100, 100);
  //}
}

//void drawJoint(int userId, int jointId) {
  //PVector joint = new PVector();
  //float confidence = kinect.getJointPositionSkeleton(userId, jointId, joint);

  //if (confidence < 0.8) {
  //  return;
  //}

  //PVector convertedJoint = new PVector();
  //kinect.convertRealWorldToProjective(joint, convertedJoint);

  //convertedJoint.x = map(convertedJoint.x, 0, 640, -420, 2160);
  //convertedJoint.y = map(convertedJoint.y, 0, 480, -240, 1680);


  //if (jointId == SimpleOpenNI.SKEL_RIGHT_HAND) {
  //  rightHand.set(convertedJoint.x, convertedJoint.y);
  //} else if (jointId == SimpleOpenNI.SKEL_LEFT_HAND) {
  //  leftHand.set(convertedJoint.x, convertedJoint.y);
  //}

  //// Kinect-Interaktion mit dem Vogel
  //if (dist(convertedJoint.x, convertedJoint.y, bird.birdPosition.x, bird.birdPosition.y) < 20) {
  //  count++;
  //}

  //if (count > 20 && jointId == SimpleOpenNI.SKEL_LEFT_HAND) {
  //  bird.startDragging(convertedJoint);
  //  // Wenn Hände sich senken, wird der Vogel losgelassen
  //  if ( rightHand.y < 50 ) {
  //    count = 0;
  //    bird.releaseWithPower(0.4);
  //  }
  //}

  //// Hand-Symbol zeichnen
  //if(count > 20 && jointId == SimpleOpenNI.SKEL_LEFT_HAND){
  //  image(handClosed, convertedJoint.x - 50, convertedJoint.y - 50, 100, 100);
  //}else if(jointId == SimpleOpenNI.SKEL_RIGHT_HAND){
  //  image(rightHandOpen, convertedJoint.x - 50, convertedJoint.y - 50, 100, 100);
  //}else{
  //  image(handOpen, convertedJoint.x - 50, convertedJoint.y - 50, 100, 100);
  //}
//}

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
}void appearEvent(SkeletonData _s) 
{
  if (_s.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(bodies) {
    bodies.add(_s);
  }
}

void disappearEvent(SkeletonData _s) 
{
  synchronized(bodies) {
    for (int i=bodies.size ()-1; i>=0; i--) 
    {
      if (_s.dwTrackingID == bodies.get(i).dwTrackingID) 
      {
        bodies.remove(i);
      }
    }
  }
}

void moveEvent(SkeletonData _b, SkeletonData _a) 
{
  if (_a.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(bodies) {
    for (int i=bodies.size ()-1; i>=0; i--) 
    {
      if (_b.dwTrackingID == bodies.get(i).dwTrackingID) 
      {
        bodies.get(i).copy(_a);
        break;
      }
    }
  }
}
