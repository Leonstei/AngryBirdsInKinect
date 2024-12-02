class Bird {
  PVector slingshotOrigin;    // Ursprung der Steinschleuder
  PVector birdPosition;       // Position des Vogels 
  PVector birdStartPosition;  // Startposition des Vogels
  PVector velocity;           // Geschwindigkeitsvektor bei Freigabe
  PVector stretch;            // Dehnung des Gummibands
  float maxStretch = 120;     // Maximale Länge des Gummibands
  float birdSize = 30;        // Größe des Vogels
  PVector Center;
  float trailAge =150;
 
  
  // Physikalische Eigenschaften
  float gravity = 2;          // Schwerkraft in Pixeln pro Sekunde²
  float airResistance = 0.01; // Luftwiderstand
  float deltaTime = 0.4;      // Zeit pro Frame (60 FPS)
  
  // Zustand
  boolean isFlying = false;
  boolean isDragging = false;
  
  ArrayList<PVector> trail=new ArrayList<PVector>();// Liste für die Spur
 // ArrayList<ArrayList<PVector>> traillist = new ArrayList<ArrayList<PVector>>();
  float trailSize = 5;

  Bird(PVector slingshotOrigin) {
    this.slingshotOrigin = slingshotOrigin;
    this.velocity = new PVector(0, 0);
    this.birdStartPosition = slingshotOrigin.copy();
    this.stretch = new PVector(0, 0);
    this.birdPosition = birdStartPosition.copy();
    //this.Center= birdStartPosition.copy();
    //image(birdImage,this.birdPosition.x, this.birdPosition.y);
   
       
  }
  

  void drawFlight(float zoom, float CenterX, float CenterY) {
    float offSetX = 730*zoom;
    float offSetY = 275*zoom;
    float newCenterX = (CenterX-offSetX);
    float newCenterY = (CenterY+offSetY);
    //slingshotOrigin= new PVector(200,400);
     drawTrail();
     Center = new PVector(CenterX, CenterY);
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
    float birdCenterX = birdPosition.x*zoom;
    float birdCenterY = birdPosition.y*zoom;
    if(isDragging == true)
    line(slingshotOrigin.x, slingshotOrigin.y, birdCenterX, birdCenterY);
 //image(slingstand,bird.slingshotOrigin.x, bird.slingshotOrigin.y-160, 260/2, 490/2);
    // Flugbewegung
    if (isFlying && status == 0) {
      // Schwerkraft auf die Y-Geschwindigkeit anwenden
      velocity.y += gravity * deltaTime;

      // Luftwiderstand auf X und Y anwenden
      velocity.x -= velocity.x * airResistance * deltaTime;
      velocity.y -= velocity.y * airResistance * deltaTime;

      // Position aktualisieren basierend auf der Geschwindigkeit
      birdPosition.x += (velocity.x * deltaTime);
      birdPosition.y += (velocity.y * deltaTime);
      Center.x += (velocity.x * deltaTime);
      Center.y += (velocity.y * deltaTime);
      trail.add(birdPosition.copy()); 

       // Boden-Kollision
       // if (birdPosition.y > height - birdSize / 2) {
       // birdPosition.y = height - birdSize / 2;
        if (birdPosition.y > height - birdSize / 2 || birdPosition.y > 980) {
        birdPosition.y = 980;
        velocity.y = 0;
        velocity.x = 0;
        isFlying = false; // Flug beenden
      }
    }

    // Vogel zeichnen
    
    //image(birdImage, birdPosition.x, birdPosition.y, 305/4*zoom,305/4*zoom);
    
    image(birdImage, birdPosition.x, birdPosition.y, 305/4*zoom,305/4*zoom);
    //ellipse(birdPosition.x, birdPosition.y, birdSize, birdSize);
  }

  void resetBird() {
    birdPosition.set(birdStartPosition); // Zurück zur Startposition
    velocity.set(0, 0);                  // Geschwindigkeit zurücksetzen
    isFlying = false;
    
  }

void drawTrail() {
  if (trailAge < 0) {
    trailAge = 0;
  }
  for (PVector position : trail) {
   
   // if(trail.size()>2)trail.get(trail.size()-2); //Jedes vorheriges Trail soll durchsichtiger werden
     fill(255, trailAge); // Transparente weiße Punkte
    noStroke();
    ellipse(position.x*zoom, position.y*zoom, trailSize*zoom, trailSize*zoom);

  }
  //traillist.add(trail);
  //for (ArrayList<PVector> position2 : traillist) {
  //  trailAge -=2;
  }
   
 

  void handleMousePressed(float mouseX, float mouseY) {
    // Überprüfen, ob der Vogel gedrückt wird
    if (dist(mouseX, mouseY, birdPosition.x, birdPosition.y) < birdSize / 2 && status == 0 && isFlying != true && dist(slingshotOrigin.x, slingshotOrigin.y, birdPosition.x, birdPosition.y) < 20) {
      isDragging = true;
    }
  }

  void handleMouseDragged(float mouseX, float mouseY) {
    // Aktualisiere die Vogelposition, wenn gezogen wird
    if (isDragging && status == 0) {
      birdPosition.set(mouseX, mouseY);
    }
  }

  void handleMouseReleased() {
    if (isDragging && status == 0) {
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
