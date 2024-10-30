import SimpleOpenNI.*;
import processing.serial.*;

//Generate a SimpleOpenNI object
SimpleOpenNI kinect;

Serial myPort;  // Create object from Serial class

void setup() {
        kinect = new SimpleOpenNI(this);
        kinect.enableDepth();
        kinect.enableUser();
        size(640, 480);
        fill(255, 0, 0);
        kinect.setMirror(true);

        //Open the serial port
        //String portName = Serial.list()[1]; //change the 0 to a 1 or 2 etc. to match your port
        //myPort = new Serial(this, portName, 9600);

}

void draw() {
        kinect.update();
        image(kinect.depthImage(), 0, 0);

        IntVector userList = new IntVector();
        kinect.getUsers(userList);

        if (userList.size() > 0) {
                int userId = userList.get(0);
                //If we detect one user we have to draw it
                if ( kinect.isTrackingSkeleton(userId)) {
                        //User connected
                        //onNewUser(kinect, userId);
                        //Draw the skeleton user
                        drawSkeleton(userId);
                        // get the positions of the three joints of our arm
                        PVector rightHand = new PVector();
                        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,rightHand);
                        PVector rightElbow = new PVector();
                        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW,rightElbow);
                        PVector rightShoulder = new PVector();
                        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER,rightShoulder);
                        // we need right hip to orient the shoulder angle
                        PVector rightHip = new PVector();
                        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HIP,rightHip);
                        // reduce our joint vectors to two dimensions
                        PVector rightHand2D = new PVector(rightHand.x, rightHand.y);
                        PVector rightElbow2D = new PVector(rightElbow.x, rightElbow.y);
                        PVector rightShoulder2D = new PVector(rightShoulder.x,rightShoulder.y);
                        PVector rightHip2D = new PVector(rightHip.x, rightHip.y);
                        // calculate the axes against which we want to measure our angles
                        PVector torsoOrientation = PVector.sub(rightShoulder2D, rightHip2D);
                        PVector upperArmOrientation = PVector.sub(rightElbow2D, rightShoulder2D);
                        // calculate the angles between our joints
                        float shoulderAngle = angleOf(rightElbow2D, rightShoulder2D, torsoOrientation);
                        float elbowAngle = angleOf(rightHand2D,rightElbow2D,upperArmOrientation);
                        // show the angles on the screen for debugging
                        fill(255,0,0);
                        scale(3);
                        text("shoulder: " + int(shoulderAngle) + "\n" + " elbow: " + int(elbowAngle), 20, 20);
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
        if(confidence < 0.9) {
                return;
        }
        PVector convertedJoint = new PVector();
        kinect.convertRealWorldToProjective(joint, convertedJoint);
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
