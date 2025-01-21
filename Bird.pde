
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

  boolean AbilityUsed = false; // Neue Variable: Fähigkeit bereits verwendet
  ArrayList<Bird> splitBirds = new ArrayList<>();
  boolean isDirectionSet = false;


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
    bd.type = BodyType.STATIC; // Initially, the bird is static and locked in place
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
    if (dist(mouseX, mouseY, pos.x, pos.y) > radius && isFlying && mouseButton == LEFT && !AbilityUsed) {
      AbilityUsed = true;
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

      // Schusszählung
      shotsFired++;

      float power = 7.5f; // Stärke
      
      PVector stretch = PVector.sub(slingshotOrigin, getPixelPosition());
      Vec2 releaseVelocity = box2d.vectorPixelsToWorld(new Vec2(stretch.x * power, stretch.y * power));

      body.setType(BodyType.DYNAMIC);
      body.setLinearVelocity(releaseVelocity);

      isFlying = true;
    }
  }
  void addMass() {
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
    AbilityUsed = false;
    lifeTime = 20;
    
    // Lösche den Trail
    trail.clear();

    println("Bird fully reset.");
  }







  void display(float Speed) {
    if (!isFlying && AbilityUsed) {
      // Hauptvogel wird nicht mehr angezeigt, wenn der Split-Modus verwendet wurde
      for (Bird splitBird : splitBirds) {
        splitBird.display(Speed); // Anzeige der kleineren Vögel
      }
      return;
    }

    drawTrail();

    if (lifeTime <= 0) {
      body.setLinearVelocity(new Vec2(0, 0));
      body.setAngularVelocity(0);
      bird.resetBird();
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

    if (isFlying && !AbilityUsed) {
      // Erhöhe Größe und Masse des Vogels
      radius *= 1.3;
      updateBodyMass(15);

      // Setze eine starke vertikale Geschwindigkeit
      body.setLinearVelocity(new Vec2(body.getLinearVelocity().x, -35));

      // Markiere Fähigkeit als verwendet
      AbilityUsed = true;

      // Visual Feedback
      println("Heavy mode activated: Increased size and downward velocity!");
    }
  }


  void activateSplitMode() {
    if (isFlying && !AbilityUsed) {
      AbilityUsed = true;

      // Holen Sie die aktuelle Position und Geschwindigkeit des Vogels
      PVector currentPosition = getPixelPosition();
      Vec2 currentVelocity = body.getLinearVelocity();

      // Winkel für die kleinen Vögel
      float angleOffset = PI / 16; // Unterschied in Flugbahnen

      // Erstellen der drei neuen Vögel
      for (int i = -1; i <= 1; i++) {
        Bird splitBird = new Bird(box2d, slingshotOrigin);
        splitBird.radius = this.radius * 0.7f; // Kleinere Vögel
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
    if (isFlying && !AbilityUsed) {
      PVector birdPos = getPixelPosition();
      direction = new PVector(mouseX-birdPos.x, mouseY-birdPos.y);  // Mausposition
      direction.normalize();

      AbilityUsed = false;  // Setze die Fähigkeit zurück
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
  void activateTargetKin2(PVector rightHand) {
    if (isFlying && !AbilityUsed) {
      AbilityUsed = true;
      PVector birdPos = getPixelPosition();
      direction = new PVector(rightHand.x-birdPos.x, rightHand.y-birdPos.y);  // Handposition
      direction.normalize();

      float speed = 1000;  // Geschwindigkeit des Vogels
      Vec2 velocity = box2d.vectorPixelsToWorld(new Vec2(direction.x * speed, direction.y * speed));

      // Setze die Geschwindigkeit des Vogels in Richtung der Maus
      body.setLinearVelocity(velocity);
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
