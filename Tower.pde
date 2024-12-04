import org.jbox2d.dynamics.*;
import org.jbox2d.common.*;
import org.jbox2d.collision.shapes.*;

class Tower {
  Box2DProcessing box2d;
  ArrayList<Body> blocks; // Liste der Blöcke im Tower
  ArrayList<PVector> blockDimensions; // Speichert die Breite und Höhe jedes Blocks
  ArrayList<Body> getBlocks() {
    return blocks; // Gibt die Liste der Blöcke zurück
  }
  Tower(Box2DProcessing box2d) {
    this.box2d = box2d;
    this.blocks = new ArrayList<Body>();
    this.blockDimensions = new ArrayList<PVector>();
  }

  // Methode zum Hinzufügen eines einzelnen Blocks
  void addBlock(float x, float y, float blockWidth, float blockHeight, boolean isDynamic) {
    BodyDef bd = new BodyDef();
    bd.type = isDynamic ? BodyType.DYNAMIC : BodyType.STATIC; // Dynamischer oder statischer Block
    bd.position = box2d.coordPixelsToWorld(x, y);

    PolygonShape ps = new PolygonShape();
    ps.setAsBox(box2d.scalarPixelsToWorld(blockWidth / 2), box2d.scalarPixelsToWorld(blockHeight / 2));

    FixtureDef fd = new FixtureDef();
    fd.shape = ps;
    fd.density = 1.0f; // Dichte der Blöcke
    fd.friction = 0.5f; // Reibung für realistische Interaktion
    fd.restitution = 0.1f; // Geringe Rückprallwirkung

    Body block = box2d.createBody(bd);
    block.createFixture(fd);

    blocks.add(block); // Block zur Liste hinzufügen
    blockDimensions.add(new PVector(blockWidth, blockHeight)); // Speichere Breite und Höhe
  }

  // Methode zum Anzeigen aller Blöcke
  void display() {
    fill(139, 69, 19); // Braune Farbe für die Blöcke
    stroke(0); // Schwarzer Rand
    for (int i = 0; i < blocks.size(); i++) {
      Body block = blocks.get(i);
      PVector dimensions = blockDimensions.get(i);
      float blockWidth = dimensions.x;
      float blockHeight = dimensions.y;

      Vec2 pos = box2d.getBodyPixelCoord(block);
      float angle = block.getAngle();

      pushMatrix();
      translate(pos.x, pos.y);
      rotate(-angle); // Box2D nutzt negative Winkel
      rectMode(CENTER);
      rect(0, 0, blockWidth, blockHeight); // Zeichne Rechteck mit Breite und Höhe
      popMatrix();
    }
  }

  // Methode zum Erstellen eines Hauses aus 4 länglichen Blöcken
 void buildSimpleHouse(PVector basePosition, float blockWidth, float blockHeight) {
    // Boden
    addBlock(basePosition.x, basePosition.y, blockWidth * 4, blockHeight, true);
    // Decke
    addBlock(basePosition.x, basePosition.y - blockHeight * 5, blockWidth * 4, blockHeight, true);
    // Linke Wand (länger und dünner)
    addBlock(basePosition.x - blockWidth * 1.8f, basePosition.y - blockHeight * 2.5f, blockWidth / 2, blockHeight * 5, true);
    // Rechte Wand (länger und dünner)
    addBlock(basePosition.x + blockWidth * 1.8f, basePosition.y - blockHeight * 2.5f, blockWidth / 2, blockHeight * 5, true);
}

}
