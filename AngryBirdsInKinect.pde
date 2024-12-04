import SimpleOpenNI.*;
import processing.serial.*;


SimpleOpenNI kinect;

PImage backgroundImage,rightHandOpen, leftHandOpen, handClosed, slingshotImage, birdImage;
PVector rightHand, leftHand, screenPos;
int slingshotSize = 200;
int count = 0;
Bird bird , bird2;
HashMap<Integer, PVector> trackedHands = new HashMap<Integer, PVector>();

void setup() {
  // Kinect-Einstellungen
  setupKinect();
  //fullScreen();
  size(1840, 980);


  // Bilder laden
  backgroundImage = loadImage("background.png");
  rightHandOpen = loadImage("rightHandOpen.png");
  handClosed = loadImage("leftHandClosed.png");
  leftHandOpen = loadImage("leftHandOpen.png");
  slingshotImage = loadImage("slingshotfin.png");
  birdImage = loadImage("grover1.png");

  // Hintergrundbildgröße überprüfen und anpassen
  if (backgroundImage.width != width || backgroundImage.height != height) {
    backgroundImage.resize(width, height);
  }

  // Vogel-Objekt initialisieren
  PVector slingshotOrigin = new PVector(200, height - 150);
  screenPos = new PVector();
  bird = new Bird(slingshotOrigin);
  bird2 = new Bird(slingshotOrigin);
}

void draw() {
  //delay(1000);
  // Kinect-Update
  kinect.update();

  // Hintergrund zeichnen
  image(backgroundImage, 0, 0);

  // Schleuder zeichnen
  //rect(bird.slingshotOrigin.x - 5, bird.slingshotOrigin.y, 10, 50);
  image(slingshotImage, bird.slingshotOrigin.x - slingshotSize/2 , bird.slingshotOrigin.y -slingshotSize/2, slingshotSize, slingshotSize);

  // Vogelbewegung und Zeichnung
  bird.drawFlight();
  drawHand();
  
  // Kinect-Benutzer verfolgen
  //IntVector userList = new IntVector();
  //kinect.getUsers(userList);
  
  
  //if (userList.size() > 0) {
  //  int userId = userList.get(0);

  //  if (kinect.isTrackingSkeleton(userId)) {
  //    drawSkeleton(userId);
  //  }
  //  PVector joint = new PVector();
  //  kinect.startTrackingHand(joint);
  //  println(joint);
  //}
  
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
