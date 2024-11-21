PVector slingshotOrigin;    // Ursprung der Steinschleuder
PVector birdPosition;     // Position des Vogels 
PVector birdStartPosition;   // Startposition des Vogels
PVector velocity;     // Geschwindigkeitsvektor bei Freigabe
PVector stretch;  // Dehnung des Gummibands
PVector rubberPosFr; //Position Vorderband
PVector rubberPosB; //Position Hinterband
float maxStretch = 120;      // Maximale Länge des Gummibands

float birdSize = 30; // Größe des Vogels

// Startgeschwindigkeit und Richtung (kann angepasst werden)
float initialVelocityX = 50;  // Startgeschwindigkeit in X-Richtung
float initialVelocityY = -30; // Startgeschwindigkeit in Y-Richtung (negativ für Aufwärtsbewegung)

// Beschleunigung und Schwerkraft
float gravity = 2; // Schwerkraft in Pixeln pro Sekunde²
float airResistance = 0.01; // Luftwiderstand (optional)

// Zeitmanagement
float deltaTime = 1.0 ; // Zeit pro Frame (60 FPS)


// Zustand des Vogels (ob er fliegt oder nicht)
boolean isFlying = false;
boolean isDragging = false;


void drawflight(){
  //background(152,190,100);
  
  if (isDragging) {
    stretch = PVector.sub(birdPosition, slingshotOrigin);
  }
  // Begrenze die Länge des Gummibands auf maxStretch
  if (stretch.mag() > maxStretch) {
    stretch.setMag(maxStretch);
    birdPosition = PVector.add(slingshotOrigin, stretch);
  }

  // Gummiband zeichnen
  //stroke(0);
  image(rubberBack, slingshotOrigin.x, slingshotOrigin.y, birdPosition.x, birdPosition.y);
  image(rubberFront,slingshotOrigin.x, slingshotOrigin.y, birdPosition.x, birdPosition.y);
  line(slingshotOrigin.x, slingshotOrigin.y, birdPosition.x, birdPosition.y);
  
  if (isFlying) {
    // Schwerkraft auf die Y-Geschwindigkeit anwenden
    velocity.y += gravity * deltaTime;

    // Luftwiderstand auf X und Y anwenden, falls gewünscht
    velocity.x -= velocity.x * airResistance * deltaTime;
    velocity.y -= velocity.y * airResistance * deltaTime;

    // Position aktualisieren basierend auf der Geschwindigkeit
    birdPosition.x += velocity.x * deltaTime;
    birdPosition.y += velocity.y * deltaTime;
    
    // Boden-Kollision
    if (birdPosition.y > height - birdSize / 2) {
      birdPosition.y = height - birdSize / 2;
      velocity.y = 0;
      velocity.x = 0;
      isFlying = false; // Flug beenden
    }
  }

  // Vogel zeichnen

  //ellipse(birdPosition.x, birdPosition.y, 30, 30);
  //birdPosition.x= birdStartPosition.x;
  //birdPosition.y= birdStartPosition.y;

  //image(bird,birdStartPosition.x, birdStartPosition.y, 100,100);

  bird();
}


// Funktion zum Neustarten des Vogels
void resetBird() {
  birdPosition.x = birdStartPosition.x;       // Startposition in X
  birdPosition.y = birdStartPosition.y;       // Startposition in Y
  velocity.x = 0;                 // Startgeschwindigkeit in X
  velocity.y = 0;                 // Startgeschwindigkeit in Y
}




void mousePressed() {
  // Überprüfen, ob der Vogel gedrückt wird
  if (dist(mouseX, mouseY, birdPosition.x, birdPosition.y) < 15) {
    isDragging = true;
  }
}

void mouseDragged() {
  // Wenn der Vogel gezogen wird, aktualisiere seine Position
  if (isDragging) {
    birdPosition.set(mouseX, mouseY);
  }
}

void mouseReleased() {
  // Wenn der Vogel losgelassen wird, berechne die Release-Geschwindigkeit
  if (isDragging) {
    float power = 0.3; // Anpassungsfaktor für die Stärke
    velocity = PVector.sub(slingshotOrigin, birdPosition).mult(power); 
    isDragging = false;  // Beendet das Ziehen
    isFlying = true;
  }
}

// Funktion zum Auslösen des Vogels mit Keybord (oder Kinect später)
void keyPressed() {
  if (!isFlying) {
    resetBird(); // Nur neu starten, wenn der Vogel am Boden ist
  }
}
