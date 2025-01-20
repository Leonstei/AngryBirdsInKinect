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
  if (trackedHands.size()==0)return;
  for (HashMap.Entry<Integer, PVector> entry : trackedHands.entrySet()) {
    int handId = entry.getKey();
    PVector handPos = entry.getValue();

    handPos.x = map(handPos.x, 0, 640, -420, 2160);
    handPos.y = map(handPos.y, 0, 480, -240, 1680);

    decideIfRightOrLeft(handPos);

    if (dist(handPos.x, handPos.y, bird.birdPosition.x, bird.birdPosition.y) < 30 && !bird.isFlying) {
      count++;
    }

    if (count > 20 && dist(handPos.x, handPos.y, leftHand.x, leftHand.y) < 100) {
      bird.isDragging = true;
      bird.startDragging(leftHand.x, leftHand.y); // Wenn Hände sich senken, wird der Vogel losgelassen
      if ( rightHand.y < 50 ) {
        count = 0;
        bird.releaseWithPower();
      }
    }
    if (trackedHands.size() == 1) {
      if (handPos.x < width/2) {
        drawLeftHand();
      } else {
        drawRightHand();
      }
    } else {
      drawRightHand();
      drawLeftHand();
    }
  }
  activateAbility();
}

void drawRightHand() {
  image(rightHandOpen, rightHand.x - 50, rightHand.y - 50, 100, 100);
}

void drawLeftHand() {
  if (count > 20) {
    image(handClosed, leftHand.x - 50, leftHand.y - 50, 100, 100);
  } else {
    image(leftHandOpen, leftHand.x - 50, leftHand.y - 50, 100, 100);
  }
}


void activateAbility() {
  float thresholdY = 800;
  line(0, thresholdY, width, thresholdY);
  if (rightHand.y > thresholdY && leftHand.y > thresholdY && bird.isFlying) {
    bird.activateHeavyMode();
  }
  if (dist(rightHand.x, rightHand.y, leftHand.x, leftHand.y) < 200 && bird.isFlying) {
    bird.activateSplitMode();
  }
  if (leftHand.y < 200 && bird.isFlying) { //Wenn die linke Hand hochgehoben wird
    bird.activateTargetKin(rightHand);
  }
}

void decideIfRightOrLeft(PVector handPos) {
  if (
    dist(handPos.x, handPos.y, leftHand.x, leftHand.y) < 100 &&
    dist(leftHand.x, leftHand.y, rightHand.x, rightHand.y) >100
    ) {
    smoothHandWithSpeed(handPos, leftHand, leftHand);
    //println(leftHand);
    //leftHand.set(handPos.x, handPos.y);
  } else if (
    dist(handPos.x, handPos.y, rightHand.x, rightHand.y) < 100 &&
    dist(leftHand.x, leftHand.y, rightHand.x, rightHand.y) > 100
    ) {
    smoothHandWithSpeed(handPos, rightHand, rightHand);
    //rightHand.set(handPos.x, handPos.y);
  } else {
    if (handPos.x >= width / 2) {
      rightHand.set(handPos.x, handPos.y);
    } else {
      leftHand.set(handPos.x, handPos.y);
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
      bird.activateTargetKin(rightHand);
    }
  }
  // Starte Hand-Tracking
  int handId = kinect.startTrackingHand(pos);
  //println("Hand-Tracking gestartet mit ID: " + handId);
}
