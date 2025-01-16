void setupKinect() {
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser(); // Aktiviert Skeleton Tracking
  kinect.enableHand();    // Aktiviert Hand-Tracking
  kinect.startGesture(SimpleOpenNI.GESTURE_CLICK);
  kinect.startGesture(SimpleOpenNI.GESTURE_HAND_RAISE ); // Starte Geste "Wave"
  kinect.setMirror(true);

  // Hände initialisieren
  rightHand = new PVector(0, 0);
  leftHand = new PVector(0, 0);
}


void drawHands() {
  //if(trackedHands.size()==0)return;
  IntVector userList = new IntVector();
  kinect.getUsers(userList);
  if (userList.size() > 0) {
    int userId = userList.get(0);

    if (kinect.isTrackingSkeleton(userId)) {
      //drawSkeleton(userId);

      drawOneHand(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
      drawOneHand(userId, SimpleOpenNI.SKEL_LEFT_HAND);
      //Fähigkeit Downwards
    }
    if (rightHand.y - leftHand.y > 100 && bird.isFlying) { //Wenn die rechte Hand tiefer als die linke Hand ist
      bird.activateHeavyMode();
    }
    if (dist(rightHand.x, rightHand.y, leftHand.x, leftHand.y) > 1800 && bird.isFlying) {
      bird.activateSplitMode();
    }
    if (leftHand.y < 500 && bird.isFlying) { //Wenn die linke Hand hochgehoben wird
 
      bird.activateTargetKin(rightHand);
      
    }
  }
}





void drawOneHand(int userId, int jointId) {
  PVector joint = new PVector();
  float confidence = kinect.getJointPositionSkeleton(userId, jointId, joint);
  //println(confidence + ": confidece");
  if (confidence < 0.5) {
    return;
  }

  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);

  convertedJoint.x = map(convertedJoint.x, 0, 640, -420, 2160);
  convertedJoint.y = map(convertedJoint.y, 0, 480, -240, 1680);


  if (jointId == SimpleOpenNI.SKEL_RIGHT_HAND) {
    smoothHandWithSpeed(convertedJoint, rightHand, rightHand);
    //rightHand.set(convertedJoint.x, convertedJoint.y);
  } else if (jointId == SimpleOpenNI.SKEL_LEFT_HAND) {
    smoothHandWithSpeed(convertedJoint, leftHand, leftHand);
    //leftHand.set(convertedJoint.x, convertedJoint.y);
  }

  // Kinect-Interaktion mit dem Vogel
  if (dist(convertedJoint.x, convertedJoint.y, bird.birdPosition.x, bird.birdPosition.y) < 20) {
    count++;
  }

  if (count > 20 && jointId == SimpleOpenNI.SKEL_LEFT_HAND) {
    bird.isDragging = true;
    bird.startDragging(convertedJoint.x, convertedJoint.y);
    if (rightHand.y < releaseHight ) {
      count = 0;
      bird.releaseWithPower();
    }
  }

  // Hand-Symbol zeichnen
  if (count > 20 && jointId == SimpleOpenNI.SKEL_LEFT_HAND) {
    image(handClosed, leftHand.x - 50, leftHand.y - 50, 100, 100);
  } else if (jointId == SimpleOpenNI.SKEL_RIGHT_HAND) {
    image(rightHandOpen, rightHand.x - 50, rightHand.y - 50, 100, 100);
  } else {
    image(leftHandOpen, leftHand.x - 50, leftHand.y - 50, 100, 100);
  }
}

void activateAbility() {
  IntVector userList = new IntVector();
  kinect.getUsers(userList);
  if (userList.size() > 0) {
    int userId = userList.get(0);

    if (kinect.isTrackingSkeleton(userId)) {
      PVector leftShoulder = new PVector();
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, leftShoulder);
      kinect.convertRealWorldToProjective(leftShoulder, leftShoulder);
      PVector rightShoulder = new PVector();
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, rightShoulder);
      kinect.convertRealWorldToProjective(rightShoulder, rightShoulder);

      leftShoulder.y = map(leftShoulder.y, 0, 480, -240, 1680);
      rightShoulder.y = map(rightShoulder.y, 0, 480, -240, 1680);

      //println("leftshouldery = " + leftShoulder.y  + " left = " + leftHand.y);
      //if(abs(leftShoulder.y-leftHand.y) + abs(rightShoulder.y - rightHand.y ) <200){
      //  println("actitivate Ability");
      //  bird.activateSplitMode();
      //}

      // if(abs(leftShoulder.y-leftHand.y) + abs(rightShoulder.y - rightHand.y ) <200){
      //  println("actitivate Ability");
      //  bird.activateHeavyMode();
      //}
      //if (rightHand.y - leftHand.y > 100 && bird.isFlying) {
      //  bird.activateHeavyMode();
      //}
      //if (dist(rightHand.x, rightHand.y, leftHand.x, leftHand.y) > 1500 && bird.isFlying && !bird.isAbilityLock) {
      //  bird.activateSplitMode();
      //}

      if (abs(leftShoulder.y-leftHand.y) + abs(rightShoulder.y - rightHand.y ) <200) {
        println("activate Ability");
        bird.activateTargetKin(rightHand);
      }
    }
  }
}





void smoothHandWithSpeed(PVector newPos, PVector oldPos, PVector smoothedPos) {
  float speed = dist(newPos.x, newPos.y, oldPos.x, oldPos.y);
  float dynamicAlpha = constrain(speed / 50.0, 0.05, 0.95); // Dynamischer Glättungsfaktor
  smoothedPos.x = dynamicAlpha * newPos.x + (1 - dynamicAlpha) * smoothedPos.x;
  smoothedPos.y = dynamicAlpha * newPos.y + (1 - dynamicAlpha) * smoothedPos.y;
}
float tolerance = 10; // Mindeständerung, um die Position zu aktualisieren

void updateHandPositionWithDeadband(PVector newPos, PVector oldPos, PVector smoothedPos) {
  if (dist(newPos.x, newPos.y, oldPos.x, oldPos.y) > tolerance) {
    smoothedPos.set(newPos);
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


void onNewUser(SimpleOpenNI kinect, int userID) {
  println("Start skeleton tracking");
  kinect.startTrackingSkeleton(userID);
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
  if (gestureType == 1) {
    println(SimpleOpenNI.GESTURE_CLICK);
    if (bird.isFlying) {
      PVector screenPos = new PVector();
      kinect.convertRealWorldToProjective(pos, screenPos);
      bird.setVelocityTowards(screenPos);
    }
  }
  // Starte Hand-Tracking
  int handId = kinect.startTrackingHand(pos);
  //println("Hand-Tracking gestartet mit ID: " + handId);
}
