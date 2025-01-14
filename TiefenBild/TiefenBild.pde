import SimpleOpenNI.*;
SimpleOpenNI kinect;

void setup() {
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser(); // Aktiviert Skeleton Tracking
  kinect.enableHand();    // Aktiviert Hand-Tracking
  kinect.startGesture(SimpleOpenNI.GESTURE_HAND_RAISE );
  size(640, 480);
}

void draw() {
  kinect.update();
  image(kinect.depthImage(), 0, 0);

  IntVector userList = new IntVector();
  kinect.getUsers(userList);

  if (userList.size() > 0) {
    int userId = userList.get(0);

    if (kinect.isTrackingSkeleton(userId)) {
      
    }
  }
}






// Startet Skeleton Tracking für neue Benutzer
void onNewUser(SimpleOpenNI kinect, int userID) {
  println("Start skeleton tracking");
  kinect.startTrackingSkeleton(userID);
}
