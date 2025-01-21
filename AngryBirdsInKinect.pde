import SimpleOpenNI.*;
import processing.serial.*;
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import ddf.minim.*;


SimpleOpenNI kinect;
Box2DProcessing box2d;
TowerBlock tower; // Turm-Objekt
Enemy enemy;
Level level;


PImage backgroundImage, rightHandOpen, leftHandOpen, handClosed, slingshotImage, birdImage, enemySprite, woodImage,
  rubberBandImage, rubberBandBackImage;



HashMap<Integer, PVector> trackedHands = new HashMap<Integer, PVector>();


PVector rightHand, leftHand;
int slingshotSize = 200;
int count = 0;
Bird bird;
float groundHeight = height - 10, releaseHight = 100;
ArrayList<Button> buttons;


//Score System
int score = 0; // Gesamtpunktzahl
int shotsFired = 0; // Anzahl der Schüsse
boolean gameWon = false; // Gibt an, ob das Spiel gewonnen wurde
boolean bonusAwarded = false; // Neue Variable, um Bonuspunkte zu tracken

  Minim minim; // Minim-Objekt für die Audiowiedergabe
  AudioPlayer backgroundMusic; // AudioPlayer für die Hintergrundmusik
  AudioSample collisionSound; // Sound für Kollision
  AudioSample enemyDeathSound; // Sound für das Sterben eines Gegners



void setup() {
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
    //Game Music


   minim = new Minim(this);
   backgroundMusic = minim.loadFile("background.mp3"); //https://pixabay.com/music/main-title-friendly-town-fun-video-game-music-loop-256055/ 
    // Soundeffekte laden (Dateien im 'data'-Ordner platzieren)
   collisionSound = minim.loadSample("collision.mp3", 512); // https://pixabay.com/sound-effects/wood-block-105066/
   enemyDeathSound = minim.loadSample("enemy_death.mp3", 512); // https://pixabay.com/sound-effects/puffofsmoke-47176/


   // Musik abspielen und auf Wiederholung setzen
   backgroundMusic.loop();
   
   // Setze die Lautstärke
    backgroundMusic.setGain(-25);
   

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
  // Kinect-Updates
  //if (frameCount%2 == 0) {
  //  kinect.update();
  //}
  kinect.update();
  Vec2 velocity = bird.body.getLinearVelocity(); //  Geschwindigkeit des Vogels
  float birdSpeed = velocity.length(); // Betrag des Geschwindigkeitsvektors
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
  bird.display(birdSpeed);

  // Turm anzeigen
  tower.display();

  // Punktestand anzeigen
  displayScore();
  displayShotsFired();

  // Prüfen, ob alle Gegner tot sind
  if (enemy.allEnemiesDefeated()) {
    gameWon = true;
  }

  // Win-Screen überlagern, falls das Spiel gewonnen wurde
  if (gameWon) {
    displayWinScreen(); // Win-Screen in der Mitte
  }

  PVector birdPos = bird.getPixelPosition();
  float birdRadius = bird.getRadius();
  //Vec2 velocity = bird.body.getLinearVelocity(); //  Geschwindigkeit des Vogels
  //float birdSpeed = velocity.length(); // Betrag des Geschwindigkeitsvektors
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
  if (!bird.AbilityUsed && bird.isFlying) {
    bird.activateTarget();
  }
}

void mouseDragged() {
  bird.startDragging(mouseX, mouseY); // Maus-Interaktion an Vogel delegieren
}

void mouseReleased() {
  bird.releaseWithPower(); // Maus-Interaktion an Vogel delegieren
}

void keyPressed() {
  if (key == 'r') {
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
  } else if (key == 's' && bird.isFlying) {
    bird.activateSplitMode();
  } else if (key == 'r') {
    bird.resetBird();
  }
}


void displayScore() {
  fill(255);
  textSize(24);
  text("Score: " + score, 50, 50);
}

void displayShotsFired() {
  fill(255);
  textSize(24);
  text("Shots: " + shotsFired, 50, 80);
}

void displayWinScreen() {
  // Bonuspunkte nur einmal vergeben, wenn das Spiel gewonnen wurde
  if (gameWon && !bonusAwarded) {
    if (shotsFired == 1) {
      score += 300; // Bonus für einen Schuss
    } else if (shotsFired == 2) {
      score += 200; // Bonus für zwei Schüsse
    } else if (shotsFired == 3) {
      score += 100; // Bonus für drei Schüsse
    }
    bonusAwarded = true; // Bonus wurde vergeben
  }

  // Halbtransparenter Hintergrund
  fill(0, 150);
  rectMode(CENTER);
  rect(width / 2, height / 2, 400, 200);

  // Textanzeige
  textAlign(CENTER);
  textSize(36);
  fill(255, 255, 0);
  text("You Win!", width / 2, height / 2 - 40);
  text("Score: " + score, width / 2, height / 2);
  text("Shots Used: " + shotsFired, width / 2, height / 2 + 40);
  textSize(16);
  fill(255);
  text("Press 1, 2, or 3 to load a new level", width / 2, height / 2 + 80);
}
