import SimpleOpenNI.*;
import processing.serial.*;
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;

SimpleOpenNI kinect;
Box2DProcessing box2d;
TowerBlock tower; // Turm-Objekt
Enemy enemy; 
Level level;


PImage backgroundImage,rightHandOpen, leftHandOpen, handClosed, slingshotImage, birdImage, enemySprite, woodImage, 
rubberBandImage, rubberBandBackImage;



HashMap<Integer, PVector> trackedHands = new HashMap<Integer, PVector>();


PVector rightHand, leftHand;
int slingshotSize = 200;
int count = 0;
Bird bird;
float groundHeight = height - 10,releaseHight = 100;
ArrayList<Button> buttons;

void setup() {
  //// Kinect-Einstellungen
  //kinect = new SimpleOpenNI(this);
  //kinect.enableDepth();
  //kinect.enableUser();
  //kinect.setMirror(true);
  setupKinect();

  //Fenster Setup
  size(1840, 980);
  frameRate(75); // Setzt die FPS auf 60
  buttons = new ArrayList<Button>();
  
  PImage buttonOneNormal = loadImage("buttononeclear.png");
  PImage buttonOneHover = loadImage("buttonone.png");
  
  PImage buttonTwoNormal = loadImage("buttontwoclear.png");
  PImage buttonTwoHover = loadImage("buttontwo.png");
  
  PImage buttonThreeNormal = loadImage("buttonthreeclear.png");
  PImage buttonThreeHover = loadImage("buttonthree.png");
  
  PImage resetNormal = loadImage("buttonresetclear.png");
  PImage resetHover = loadImage("buttonreset.png");
  
  // Buttons hinzufügen (Position, Größe, Bilder)
  buttons.add(new Button(new PVector(100, 10), new PVector(200, 200), buttonOneNormal, buttonOneHover)); // Button 1
  buttons.add(new Button(new PVector(350, 10), new PVector(200, 200), buttonTwoNormal, buttonTwoHover)); // Button 2
  buttons.add(new Button(new PVector(600, 10), new PVector(200, 200), buttonThreeNormal, buttonThreeHover)); // Button 3
  buttons.add(new Button(new PVector(850, 10), new PVector(200, 200), resetNormal, resetHover)); // Reset Button



  // Hände initialisieren
  rightHand = new PVector(0, 0);
  leftHand = new PVector(0, 0);

  // Bilder laden
  backgroundImage = loadImage("background.png");
  rightHandOpen = loadImage("rightHandOpen.png");
  handClosed = loadImage("leftHandClosed.png");
  leftHandOpen = loadImage("leftHandOpen.png");
  slingshotImage = loadImage("slingshotfin.png");
  birdImage = loadImage("grover1.png");
  enemySprite = loadImage("enemy_sprite.png");
  woodImage = loadImage("wood.png"); // Bild für die Blöcke laden
  rubberBandImage = loadImage("rubberbandfront 1.png");
  rubberBandBackImage = loadImage("rubberbandback.png");

  // Hintergrundbildgröße anpassen
  if (backgroundImage.width != width || backgroundImage.height != height) {
    backgroundImage.resize(width, height);
  }

 // Box2D initialisieren
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, -25);

  // Vogel-Objekt initialisieren
  bird = new Bird(box2d, new PVector(200, height - 190));
  
  // Boden erstellen
  createGround();

  // Tower-Objekt initialisieren
  tower = new TowerBlock(box2d);

  // Gegner-Objekt initialisieren
  enemy = new Enemy(box2d);
  
  level = new Level(box2d, tower, enemy, bird);


  // Lade Level 1 standardmäßig
  level.loadLevel(1);


  //Assets zu Gegner und Türmen hinzufügen
  enemy.enemyImage = enemySprite;
  tower.blockImage = woodImage;
}

void draw() {
  // Kinect-Update
  kinect.update();
  box2d.step();

  // Hintergrund zeichnen
  image(backgroundImage, 0, 0);
  
    // Buttons anzeigen
  for (Button button : buttons) {
    button.display();
  }
  
 for (Button button : buttons) {
    button.display(); // Button zeichnen
    button.update(rightHand, leftHand);

    if (button.isActivated()) {
      if (button == buttons.get(0)) {
        println("Level 1 wird geladen!");
        level.loadLevel(1);
      } else if (button == buttons.get(1)) {
        println("Level 2 wird geladen!");
        level.loadLevel(2);
      } else if (button == buttons.get(2)) {
        println("Level 3 wird geladen!");
        level.loadLevel(3);
      } else if (button == buttons.get(3)) {
        println("Vogel wird zurückgesetzt!");
        bird.resetBird();
      }
    }
  }

  // Schleuder zeichnen
  image(slingshotImage, bird.slingshotOrigin.x - slingshotSize / 2, bird.slingshotOrigin.y - slingshotSize / 3 +10, slingshotSize, slingshotSize);

  // Vogelbewegung und Zeichnung
  bird.display();
  
  // Turm anzeigen
  tower.display();

    PVector birdPos = bird.getPixelPosition();
    float birdRadius = bird.getRadius();

    enemy.display();
    enemy.checkForBirdCollision(birdPos, birdRadius);
    enemy.checkForImpact(tower.getBlocks());

    drawHands();
}

void createGround() {
  float y = height - 10; // Höhe des Bodens in Pixeln
  BodyDef bd = new BodyDef();
  bd.position = box2d.coordPixelsToWorld(new Vec2(width / 2, y)); // Konvertiere Pixel in Box2D-Koordinaten

  Body ground = box2d.createBody(bd);

  PolygonShape ps = new PolygonShape();
  float boxWidth = box2d.scalarPixelsToWorld(width / 2); // Breite des Bodens in Weltkoordinaten
  float boxHeight = box2d.scalarPixelsToWorld(10);      // Dicke des Bodens in Weltkoordinaten

  ps.setAsBox(boxWidth, boxHeight); // Definiere den Boden als flaches Rechteck
  ground.createFixture(ps, 0); // Füge das Fixture hinzu
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
  if (dist(convertedJoint.x, convertedJoint.y, bird.getPixelPosition().x, bird.getPixelPosition().y) < 20) {
    count++;
  }

  if (count > 20 && jointId == SimpleOpenNI.SKEL_LEFT_HAND) {
  //  bird.startDragging(convertedJoint); // Dragging starts with Kinect hand
    // Wenn Hände sich senken, wird der Vogel losgelassen
    if (rightHand.y < 50) {
      count = 0;
     // bird.releaseWithPower(0.4);
    }
  }

  // Hand-Symbol zeichnen
  if (count > 20 && jointId == SimpleOpenNI.SKEL_LEFT_HAND) {
    image(handClosed, convertedJoint.x - 50, convertedJoint.y - 50, 100, 100);
  } else if (jointId == SimpleOpenNI.SKEL_RIGHT_HAND) {
    image(rightHandOpen, convertedJoint.x - 50, convertedJoint.y - 50, 100, 100);
  } else {
    image(leftHandOpen, convertedJoint.x - 50, convertedJoint.y - 50, 100, 100);
  }
}

void mousePressed() {
  bird.handleMousePressed(mouseX, mouseY); // Maus-Interaktion an Vogel delegieren
}

void mouseDragged() {
  bird.startDragging(mouseX, mouseY); // Maus-Interaktion an Vogel delegieren
}

void mouseReleased() {
  bird.releaseWithPower(); // Maus-Interaktion an Vogel delegieren
}

void keyPressed() {
    if (key == ' ') {
        println("reset");
        bird.resetBird();
    } else if (key == '1') {
        level.loadLevel(1);
    } else if (key == '2') {
        level.loadLevel(2);
    } else if (key == '3') {
        level.loadLevel(3);
    } else if (key == 'h' && bird.isFlying) { // "h" für Heavy Mode
        bird.activateHeavyMode();
    }  else if (key == 's' && bird.isFlying) {
    bird.activateSplitMode();
  }


}
