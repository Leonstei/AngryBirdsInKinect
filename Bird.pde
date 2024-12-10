
class Bird {
  Box2DProcessing box2d;
  Body body;
  PVector slingshotOrigin; // Ursprung der Schleuder
  PVector birdPosition; // Aktuelle Position des Vogels in Pixeln
  PVector stretch; // Stretch-Vektor für die Schleuder
  float radius = 25;
  float maxStretch = 100; // Maximale Stretch-Distanz
  boolean isFlying = false; // Gibt an, ob der Vogel fliegt
  boolean isDragging = false; // Gibt an, ob der Vogel gezogen wird

  Bird(Box2DProcessing box2d, PVector slingshotOrigin) {
    this.box2d = box2d;
    this.slingshotOrigin = slingshotOrigin;
    this.birdPosition = slingshotOrigin.copy();
    this.stretch = new PVector(0, 0);

    makeBody(slingshotOrigin.x, slingshotOrigin.y);
  }

  void makeBody(float x, float y) {
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position = box2d.coordPixelsToWorld(x, y);

    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(radius);

    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    fd.density = 3;
    fd.friction = 0.1;
    fd.restitution = 0.8;

    body = box2d.createBody(bd);
    body.createFixture(fd);

    // Initially, the bird is static and locked in place
    body.setType(BodyType.STATIC);
  }

    PVector getPixelPosition() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    return new PVector(pos.x, pos.y);
}

  void handleMousePressed(float mouseX, float mouseY) {
    // Überprüfen, ob die Maus nah genug ist, um den Vogel zu greifen
    PVector pos = getPixelPosition();
    if (dist(mouseX, mouseY, pos.x, pos.y) < radius) {
      isDragging = true;
      body.setType(BodyType.STATIC); // Der Vogel bleibt statisch während des Ziehens
    }
  }

  void handleMouseDragged(float mouseX, float mouseY) {
    if (isDragging) {
      // Berechne die Stretch basierend auf der Mausposition
      stretch = PVector.sub(new PVector(mouseX, mouseY), slingshotOrigin);
      if (stretch.mag() > maxStretch) {
        stretch.setMag(maxStretch); // Begrenze die Dehnung
      }
      // Aktualisiere die Vogelposition basierend auf der Stretch
      birdPosition.set(PVector.add(slingshotOrigin, stretch));
    }
  }
  void startDragging(PVector handPosition) {
    isDragging = true;
    stretch = PVector.sub(new PVector(handPosition.x,handPosition.y), slingshotOrigin);
      if (stretch.mag() > maxStretch) {
        stretch.setMag(maxStretch); // Begrenze die Dehnung
      }
    birdPosition.set(handPosition.x,handPosition.y);
  }

  void handleMouseReleased() {
    if (isDragging) {
        // Berechne die Freigabegeschwindigkeit basierend auf der Dehnung
        float power = 5.0f; // Verstärke die Kraft (Skalierungsfaktor)
        Vec2 releaseVelocity = new Vec2(-stretch.x * power, -stretch.y * power);
        body.setType(BodyType.DYNAMIC); // Der Vogel wird fliegbar gemacht
        body.setLinearVelocity(box2d.vectorPixelsToWorld(releaseVelocity));
        isFlying = true;
        isDragging = false;
        stretch.set(0, 0); // Setze die Dehnung zurück
    }
  }
  void releaseWithPower(float power) {
    Vec2 releaseVelocity = new Vec2(-stretch.x * power, -stretch.y * power);
    body.setType(BodyType.DYNAMIC); // Der Vogel wird fliegbar gemacht
    body.setLinearVelocity(box2d.vectorPixelsToWorld(releaseVelocity));
    isDragging = false;
    isFlying = true;
    stretch.set(0, 0);
  }

  void resetBird() {
    // Setze den Vogel auf die Schleuderposition zurück
    body.setTransform(box2d.coordPixelsToWorld(slingshotOrigin.x, slingshotOrigin.y), 0);
    body.setLinearVelocity(new Vec2(0, 0));
    body.setAngularVelocity(0);
    body.setType(BodyType.STATIC); // Fixiere den Vogel wieder
    isFlying = false;
    isDragging = false;
  }

  void display() {
    // Zeichne den Vogel an seiner aktuellen Position
    birdPosition = getPixelPosition();

    // Zeichne das Schleuderband, wenn der Vogel gezogen wird
    if (isDragging) {
      stroke(0);
      line(slingshotOrigin.x, slingshotOrigin.y, birdPosition.x, birdPosition.y);
    }
    


    pushMatrix();
    translate(birdPosition.x, birdPosition.y);
    image(birdImage, -radius, -radius, radius * 2, radius * 2);
    popMatrix();
  }
  

      float getRadius(){
        return this.radius;
    }
}
