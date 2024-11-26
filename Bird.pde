class Bird {
  PVector slingshotOrigin;    // Ursprung der Steinschleuder
  PVector birdPosition;       // Position des Vogels 
  PVector birdStartPosition;  // Startposition des Vogels
  PVector velocity;           // Geschwindigkeitsvektor bei Freigabe
  PVector stretch;            // Dehnung des Gummibands
  float maxStretch = 100;     // Maximale Länge des Gummibands
  float birdSize = 50;        // Größe des Vogels
  
  // Physikalische Eigenschaften
  float gravity = 9.8;          // Schwerkraft in Pixeln pro Sekunde²
  //float airResistance = 0.1; // Luftwiderstand
  float deltaTime = 0.16;      // Zeit pro Frame (60 FPS)
  
  // Zustand
  boolean isFlying = false;
  boolean isDragging = false;
  
  ArrayList<PVector> trail=new ArrayList<PVector>();// Liste für die Spur
  float trailSize = 5;
  


  Bird(PVector slingshotOrigin) {
    this.slingshotOrigin = slingshotOrigin;
    this.velocity = new PVector(0, 0);
    this.birdStartPosition = new PVector(slingshotOrigin.x, slingshotOrigin.y);
    this.stretch = new PVector(0, 0);
    this.birdPosition = birdStartPosition.copy();
       
  }

  void drawFlight() {
    // Berechne die Dehnung des Gummibands, wenn der Vogel gezogen wird
    drawTrail();
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
    line(slingshotOrigin.x, slingshotOrigin.y, birdPosition.x, birdPosition.y);

    // Flugbewegung
    if (isFlying) {
      // Schwerkraft auf die Y-Geschwindigkeit anwenden
      velocity.y += gravity * deltaTime;

      // Luftwiderstand auf X und Y anwenden
      //velocity.x -= velocity.x * airResistance * deltaTime;
      //velocity.y -= velocity.y * airResistance * deltaTime;

      // Position aktualisieren basierend auf der Geschwindigkeit
      birdPosition.x += velocity.x * deltaTime;
      birdPosition.y += velocity.y * deltaTime;
      
      trail.add(birdPosition.copy()); 

      // Boden-Kollision
      if (birdPosition.y > height- birdSize / 2) {
        birdPosition.y = height - birdSize / 2;
        velocity.y = 0;
        velocity.x = 0;
        isFlying = false; // Flug beenden
      }
    }

    // Vogel zeichnen
    image(birdImage ,birdPosition.x-birdSize/2, birdPosition.y-birdSize/2, birdSize, birdSize);
    //ellipse(birdPosition.x, birdPosition.y, birdSize, birdSize);
  
  }
  
  void drawTrail() {
  fill(255, 0, 0, 150); // Transparente rote Punkte
  noStroke();
  for (PVector position : trail) {
    ellipse(position.x, position.y, trailSize, trailSize);
  }
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
      float power = 1.25; // Anpassungsfaktor für die Stärke
      velocity = PVector.sub(slingshotOrigin, birdPosition).mult(power);
      println(velocity);
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
