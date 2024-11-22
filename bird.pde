class Bird {
  PVector slingshotOrigin;    // Ursprung der Steinschleuder
  PVector birdPosition;       // Position des Vogels 
  PVector birdStartPosition;  // Startposition des Vogels
  PVector velocity;           // Geschwindigkeitsvektor bei Freigabe
  PVector stretch;            // Dehnung des Gummibands
  float maxStretch = 120;     // Maximale Länge des Gummibands
  float birdSize = 30;        // Größe des Vogels
  
  // Physikalische Eigenschaften
  float gravity = 2;          // Schwerkraft in Pixeln pro Sekunde²
  float airResistance = 0.01; // Luftwiderstand
  float deltaTime = 1.0;      // Zeit pro Frame (60 FPS)
  
  // Zustand
  boolean isFlying = false;
  boolean isDragging = false;

  Bird(PVector slingshotOrigin,PImage birdImage) {
    this.slingshotOrigin = slingshotOrigin;
    this.velocity = new PVector(0, 0);
    this.birdStartPosition = slingshotOrigin.copy();
    this.stretch = new PVector(0, 0);
    this.birdPosition = birdStartPosition.copy();
    image(birdImage,this.birdPosition.x, this.birdPosition.y);
   
       
  }
  

  void drawFlight() {
    //slingshotOrigin= new PVector(200,400);
    // Berechne die Dehnung des Gummibands, wenn der Vogel gezogen wird
    if (isDragging) {
      stretch = PVector.sub(birdPosition, slingshotOrigin);
    }

    // Begrenze die Länge des Gummibands auf maxStretch
    if (stretch.mag() > maxStretch) {
      stretch.setMag(maxStretch);
      birdPosition = PVector.add(slingshotOrigin, stretch);
    }

    // Zeichne das Gummiband
    stroke(0);
    //image(slingstand,bird.slingshotOrigin.x, bird.slingshotOrigin.y-160, 260/2, 490/2);
    line(slingshotOrigin.x+70, slingshotOrigin.y-120, birdPosition.x, birdPosition.y);

    // Flugbewegung
    if (isFlying) {
      // Schwerkraft auf die Y-Geschwindigkeit anwenden
      velocity.y += gravity * deltaTime;

      // Luftwiderstand auf X und Y anwenden
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
    image(birdImage, birdPosition.x+35, birdPosition.y-150, 305/4,305/4);
    //ellipse(birdPosition.x, birdPosition.y, birdSize, birdSize);
  }

  void resetBird() {
    birdPosition.set(birdStartPosition); // Zurück zur Startposition
    velocity.set(0, 0);                  // Geschwindigkeit zurücksetzen
    isFlying = false;
  }

  void handleMousePressed(float mouseX, float mouseY) {
    // Überprüfen, ob der Vogel gedrückt wird
    if (dist(mouseX, mouseY, birdPosition.x, birdPosition.y) < birdSize / 2) {
      isDragging = true;
    }
  }

  void handleMouseDragged(float mouseX, float mouseY) {
    // Aktualisiere die Vogelposition, wenn gezogen wird
    if (isDragging) {
      birdPosition.set(mouseX, mouseY);
    }
  }

  void handleMouseReleased() {
    if (isDragging) {
      float power = 0.4; // Anpassungsfaktor für die Stärke
      velocity = PVector.sub(slingshotOrigin, birdPosition).mult(power);
      isDragging = false; // Beendet das Ziehen
      isFlying = true;
    }
  }
  void startDragging(PVector handPosition) {
    isDragging = true;
    //println(handPosition);
    birdPosition.set(handPosition.x,handPosition.y);
  }

  void releaseWithPower(float power) {
    velocity = PVector.sub(slingshotOrigin, birdPosition).mult(power);
    isDragging = false;
    isFlying = true;
  }

}
