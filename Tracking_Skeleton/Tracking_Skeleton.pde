import SimpleOpenNI.*;
SimpleOpenNI kinect;

void setup() {
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser(); // Aktiviert Skeleton Tracking
  size(640, 480);
  fill(255, 0, 0);
}

void draw() {
  kinect.update();
  image(kinect.depthImage(), 0, 0);

  IntVector userList = new IntVector();
  kinect.getUsers(userList);

  if (userList.size() > 0) {
    int userId = userList.get(0);

    if (kinect.isTrackingSkeleton(userId)) {
     // drawSkeleton(userId);
    }
  }
}

void drawSkeleton(int userId) {
  stroke(0);
  strokeWeight(5);

  // Zeichne Skelette
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP);

  noStroke();
  fill(255, 0, 0);

  // Zeichne Gelenke mit Namen
  drawJoint(userId, SimpleOpenNI.SKEL_HEAD, "HEAD");
  drawJoint(userId, SimpleOpenNI.SKEL_NECK, "NECK");
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, "LEFT_SHOULDER");
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, "LEFT_ELBOW");
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND, "LEFT_HAND");
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, "RIGHT_SHOULDER");
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, "RIGHT_ELBOW");
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND, "RIGHT_HAND");
  drawJoint(userId, SimpleOpenNI.SKEL_TORSO, "TORSO");
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP, "LEFT_HIP");
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_KNEE, "LEFT_KNEE");
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT, "LEFT_FOOT");
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HIP, "RIGHT_HIP");
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, "RIGHT_KNEE");
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT, "RIGHT_FOOT");
}

void drawJoint(int userId, int jointID, String jointName) {
  PVector joint = new PVector();

  float confidence = kinect.getJointPositionSkeleton(userId, jointID, joint);
  if (confidence < 0.5) {
    return; // Wenn die Erkennung unsicher ist, überspringen
  }

  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);

  // Zeichne Gelenkpunkt
  ellipse(convertedJoint.x, convertedJoint.y, 20, 20);

  // Füge den Namen des Joints hinzu
  if(
   jointID == SimpleOpenNI.SKEL_LEFT_SHOULDER ||
   jointID == SimpleOpenNI.SKEL_LEFT_ELBOW ||
   jointID == SimpleOpenNI.SKEL_LEFT_HAND ||
   jointID == SimpleOpenNI.SKEL_LEFT_HIP ||
   jointID == SimpleOpenNI.SKEL_LEFT_KNEE ||
   jointID == SimpleOpenNI.SKEL_LEFT_FOOT 
  ){
    fill(255,0,0); // Weißer Text
    textSize(24);
    text(jointName, convertedJoint.x - 100, convertedJoint.y); // Text leicht neben dem Punkt
  }else{
    fill(255,0,0); // Weißer Text
    textSize(24);
    text(jointName, convertedJoint.x + 10, convertedJoint.y); // Text leicht neben dem Punkt
  }
}

// Startet Skeleton Tracking für neue Benutzer
void onNewUser(SimpleOpenNI kinect, int userID) {
  println("Start skeleton tracking");
  kinect.startTrackingSkeleton(userID);
}
