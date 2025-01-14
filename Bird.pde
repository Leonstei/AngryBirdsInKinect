
class Bird {
  Box2DProcessing box2d;
  Body body;
  PVector slingshotOrigin; // Ursprung der Schleuder
  PVector birdPosition; // Aktuelle Position des Vogels in Pixeln
  PVector stretch; // Stretch-Vektor für die Schleuder
  PVector direction;
  float radius = 25;
  float maxStretch = 100; // Maximale Stretch-Distanz
  float lifeTime = 20;
  boolean isFlying = false; // Gibt an, ob der Vogel fliegt
  boolean isDragging = false; // Gibt an, ob der Vogel gezogen wird
  ArrayList<PVector> trail=new ArrayList<PVector>();
  //boolean heavyModeUsed = false; // Neue Variable: Fähigkeit bereits verwendet
  //boolean splitModeUsed = false; // Track if split mode has been used
  boolean isAbility = false;
  boolean isAbilityLock = false;
  boolean isDirectionSet = false;
  ArrayList<Bird> splitBirds = new ArrayList<>();


  Bird(Box2DProcessing box2d, PVector slingshotOrigin) {
    this.box2d = box2d;
    this.slingshotOrigin = slingshotOrigin;
    this.birdPosition = slingshotOrigin.copy();
    this.stretch = new PVector(0, 0);

    makeBody(slingshotOrigin.x, slingshotOrigin.y);
  }

  void makeBody(float x, float y) {
    if (body != null) {
      println("Warning: A body already exists. Destroying old body.");
      box2d.destroyBody(body);
    }

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

  void drawTrail() {
    float trailSize = radius/2;
    fill(255, 150); // Transparente rote Punkte
    noStroke();
    for (PVector position : trail) {
      ellipse(position.x, position.y, trailSize, trailSize);
    }
  }

  void handleMousePressed(float mouseX, float mouseY) {
    PVector pos = getPixelPosition();
    if (dist(mouseX, mouseY, pos.x, pos.y) < radius && !isFlying) {
      isDragging = true;
      body.setLinearVelocity(new Vec2(0, 0)); // Stop any movement
    }
    if (dist(mouseX, mouseY, pos.x, pos.y) > radius && isFlying && mouseButton == LEFT && isAbilityLock == false) {
      isAbility = true;
    }
  }

  void startDragging(float mouseX, float mouseY) {
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



  void releaseWithPower() {
    if (isDragging) {
      trail.clear();
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
  void addMass(){
    this.radius = this.radius *2;
  }

  void resetBird() {
    // Entferne alle Vogelkörper (inklusive Split-Birds und eventuelle Überbleibsel)
    for (Bird splitBird : splitBirds) {
      if (splitBird.body != null) {
        box2d.destroyBody(splitBird.body);
      }
    }
    splitBirds.clear();

    if (body != null) {
      box2d.destroyBody(body);
      body = null;
    }

    // Erstelle den Hauptvogel neu
    makeBody(slingshotOrigin.x, slingshotOrigin.y);

    // Setze die Eigenschaften des Hauptvogels zurück
    radius = 25; // Ursprüngliche Größe
    updateBodyMass(5); // Ursprüngliches Gewicht
    isFlying = false;
    isDragging = false;
    isAbility = false;
    isAbilityLock = false;
    lifeTime = 20;
    //isAbilityLock = false;
    //heavyModeUsed = false;

    // Lösche den Trail
    trail.clear();

    println("Bird fully reset.");
  }






  void display() {
    if (!isFlying && isAbilityLock) {
      // Hauptvogel wird nicht mehr angezeigt, wenn der Split-Modus verwendet wurde
      for (Bird splitBird : splitBirds) {
        splitBird.display(); // Anzeige der kleineren Vögel
      }
      return;
    }

    drawTrail();

    if (isFlying) {
      lifeTime -= 0.05;
<<<<<<< HEAD
      //println(lifeTime);
      //activateAbility();
=======
      activateAbility();
>>>>>>> dd0c606fb3d47b465d8d333d82b4fc1d34df5739
    }

    if (lifeTime <= 0) {
      body.setLinearVelocity(new Vec2(0, 0));
      body.setAngularVelocity(0);
      isFlying = false;
      isDragging = false;
      return;
    }

    PVector pos = getPixelPosition();

    if (!isDragging) {
      trail.add(pos);
      pushMatrix();
      translate(pos.x, pos.y);
      image(birdImage, -radius, -radius, radius * 2, radius * 2);
      popMatrix();
    }

    if (isDragging) {
      stroke(255, 0, 0);
      float angle = atan2(slingshotOrigin.y - pos.y, slingshotOrigin.x - pos.x);
      float distance = dist(slingshotOrigin.x, slingshotOrigin.y, pos.x, pos.y);

      pushMatrix();
      line(0, releaseHight, width, releaseHight);
      translate(pos.x, pos.y);
      rotate(angle);
      image(rubberBandBackImage, 0 - getRadius(), rubberBandBackImage.height - 1, distance, rubberBandBackImage.height);
      image(birdImage, -radius, -radius, radius * 2, radius * 2);
      image(rubberBandImage, 0 - getRadius(), 0, distance, getRadius() * 0.7);
      popMatrix();
    }
  }


  float getRadius() {
    return this.radius;
  }

  //Fähigeit Heavy Mode
  void activateHeavyMode() {
    if (isFlying && !isAbilityLock) {
      // Erhöhe Größe und Masse des Vogels
      radius *= 1.3;
      updateBodyMass(15);

      // Setze eine starke vertikale Geschwindigkeit
      body.setLinearVelocity(new Vec2(body.getLinearVelocity().x, -35));

      // Markiere Fähigkeit als verwendet
      isAbilityLock = true;

      // Visual Feedback
      println("Heavy mode activated: Increased size and downward velocity!");
    }
  }

  void activateSplitMode() {
    if (isFlying && !isAbilityLock) {
      isAbilityLock = true;

      // Holen Sie die aktuelle Position und Geschwindigkeit des Vogels
      PVector currentPosition = getPixelPosition();
      Vec2 currentVelocity = body.getLinearVelocity();

      // Winkel für die kleinen Vögel
      float angleOffset = PI / 8; // Unterschied in Flugbahnen

      // Erstellen der drei neuen Vögel
      for (int i = -1; i <= 1; i++) {
        Bird splitBird = new Bird(box2d, slingshotOrigin);
        splitBird.radius = this.radius * 0.8f; // Kleinere Vögel
        splitBird.lifeTime = this.lifeTime / 2; // Kürzere Lebensdauer
        splitBird.makeBody(currentPosition.x, currentPosition.y);

        // Setzen der Masse der kleineren Vögel
        splitBird.updateBodyMass(4f); // Weniger Masse für kleinere Vögel

        // Setzen der Geschwindigkeit für jeden Vogel
        float angle = atan2(currentVelocity.y, currentVelocity.x) + (i * angleOffset);
        float speed = currentVelocity.length();
        Vec2 newVelocity = new Vec2(cos(angle) * speed, sin(angle) * speed);

        splitBird.body.setType(BodyType.DYNAMIC);
        splitBird.body.setLinearVelocity(newVelocity);

        // Zur Liste der Split-Vögel hinzufügen
        splitBirds.add(splitBird);
      }

      // Hauptvogel "deaktivieren"
      body.setType(BodyType.STATIC);
      isFlying = false; // Der Hauptvogel ist nicht mehr im Flug
      trail.clear(); // Reset des Trails

      println("Split mode activated: Bird divided into 3 smaller birds!");
    }
  }
  void activateTarget() {
    if (isAbility == true) {
      PVector birdPos = getPixelPosition();
      direction = new PVector(mouseX-birdPos.x, mouseY-birdPos.y);  // Mausposition
      direction.normalize();

      isAbility = false;  // Setze die Fähigkeit zurück
      isAbilityLock = true;
      float speed = 1000;  // Geschwindigkeit des Vogels
      Vec2 velocity = box2d.vectorPixelsToWorld(new Vec2(direction.x * speed, direction.y * speed));

      // Setze die Geschwindigkeit des Vogels in Richtung der Maus
      body.setLinearVelocity(velocity);
      //body.setAngularVelocity(1);  // Wenn der Vogel sich drehen soll, behalte dies bei
      //birdsize *=2;
      //radius.x *=4;
      isFlying = true;
      isDragging = false;
      return;
    }
  }
    void activateTargetKin(PVector rightHand) {
    if (isAbility == true) {
      println(rightHand);
      PVector birdPos = getPixelPosition();
      direction = new PVector(rightHand.x-birdPos.x, rightHand.y-birdPos.y);  // Handposition
      direction.normalize();

      isAbility = false;  // Setze die Fähigkeit zurück
      isAbilityLock = true;
      float speed = 1000;  // Geschwindigkeit des Vogels
      Vec2 velocity = box2d.vectorPixelsToWorld(new Vec2(direction.x * speed, direction.y * speed));

      // Setze die Geschwindigkeit des Vogels in Richtung der Maus
      body.setLinearVelocity(velocity);
      //body.setAngularVelocity(1);  // Wenn der Vogel sich drehen soll, behalte dies bei
      //birdsize *=2;
      //radius.x *=4;
      isFlying = true;
      isDragging = false;
      return;
    }
  }






  void updateBodyMass(float newDensity) {
    // Alte Fixtures entfernen und neue mit erhöhter Dichte hinzufügen
    body.destroyFixture(body.getFixtureList());

    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(radius);

    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    fd.density = newDensity; // Neue Dichte
    fd.friction = 0.1;
    fd.restitution = 0.3;

    body.createFixture(fd);
  }
}
