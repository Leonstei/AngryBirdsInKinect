PVector slingshotOrigin;    // Ursprung der Steinschleuder
PVector birdPosition;     // Position des Vogels 
PVector birdStartPosition;   // Startposition des Vogels
PVector velocity;     // Geschwindigkeitsvektor bei Freigabe
PVector stretch;  // Dehnung des Gummibands
float maxStretch = 120;      // Maximale Länge des Gummibands
//int count = 0;

float birdSize = 30; // Größe des Vogels

// Beschleunigung und Schwerkraft
float gravity = 2; // Schwerkraft in Pixeln pro Sekunde²
float airResistance = 0.01; // Luftwiderstand (optional)

// Zeitmanagement
float deltaTime = 1.0 ; // Zeit pro Frame (60 FPS)


// Zustand des Vogels (ob er fliegt oder nicht)
boolean isFlying = false;
boolean isDragging = false;

void initializeValuesForGravity(){
  // Ursprungsposition der Schleuder definieren
  slingshotOrigin = new PVector(200, height - 150);
  velocity = new PVector(0, 0);
  birdStartPosition = slingshotOrigin.copy();
  stretch = new PVector(0, 0);
  
  // Startposition des Vogels auf die Ursprungsposition setzen
  birdPosition = birdStartPosition.copy();
}

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
  stroke(0);
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
  fill(255, 0, 0);
  ellipse(birdPosition.x, birdPosition.y, birdSize, birdSize);
  
}


// Funktion zum Neustarten des Vogels
void resetBird() {
  birdPosition.x = birdStartPosition.x;       // Startposition in X
  birdPosition.y = birdStartPosition.y;       // Startposition in Y
  velocity.x = 0;                 // Startgeschwindigkeit in X
  velocity.y = 0;                 // Startgeschwindigkeit in Y
}
