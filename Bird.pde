
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
    fd.density = 5;
    fd.friction = 0.1;
    fd.restitution = 0.9;

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
    PVector pos = getPixelPosition();
    if (dist(mouseX, mouseY, pos.x, pos.y) < radius) {
      isDragging = true;
      body.setLinearVelocity(new Vec2(0, 0)); // Stop any movement
    }
  }

 void handleMouseDragged(float mouseX, float mouseY) {
    if (isDragging) {
      // Calculate the drag stretch relative to the slingshot origin
      PVector stretch = PVector.sub(new PVector(mouseX, mouseY), slingshotOrigin);
      if (stretch.mag() > maxStretch) {
        stretch.setMag(maxStretch); // Limit the stretch distance
      }
      // Update the bird's position
      PVector newPosition = PVector.add(slingshotOrigin, stretch);
      body.setTransform(box2d.coordPixelsToWorld(newPosition.x, newPosition.y), 0);
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
        isDragging = false;

        // Calculate the release velocity based on stretch
        float power = 7.5f; // Strength multiplier for release
        PVector stretch = PVector.sub(getPixelPosition(), slingshotOrigin);
        Vec2 releaseVelocity = box2d.vectorPixelsToWorld(new Vec2(-stretch.x * power, -stretch.y * power));

        // Set body type to DYNAMIC so it can be affected by physics
        body.setType(BodyType.DYNAMIC);

        // Apply the calculated release velocity to the bird
        body.setLinearVelocity(releaseVelocity);

        // Transition state to flying
        isFlying = true;
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
    // Reset the bird to its initial position
    body.setTransform(box2d.coordPixelsToWorld(slingshotOrigin.x, slingshotOrigin.y), 0);
    body.setLinearVelocity(new Vec2(0, 0));
    body.setAngularVelocity(0);
    isFlying = false;
    isDragging = false;
  }
  


 void display() {
    PVector pos = getPixelPosition();

    pushMatrix();
    translate(pos.x, pos.y);
    image(birdImage, -radius, -radius, radius * 2, radius * 2);
    popMatrix();

    if (isDragging) {
      stroke(0);
      line(slingshotOrigin.x, slingshotOrigin.y, pos.x, pos.y);
    }
  }
  

      float getRadius(){
        return this.radius;
    }
}
