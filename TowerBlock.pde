import org.jbox2d.dynamics.*;
import org.jbox2d.common.*;
import org.jbox2d.collision.shapes.*;

class TowerBlock {
  Box2DProcessing box2d;
  ArrayList<Body> blocks; // Liste der Blöcke im Tower
  ArrayList<PVector> blockDimensions; // Speichert die Breite und Höhe jedes Blocks
  PImage blockImage; // Bild für die Blöcke 

  ArrayList<Body> getBlocks() {
    return blocks; // Gibt die Liste der Blöcke zurück
  }

  TowerBlock(Box2DProcessing box2d) {
    this.box2d = box2d;
    this.blocks = new ArrayList<Body>();
    this.blockDimensions = new ArrayList<PVector>();
  }

  // Setzt das Bild für die Blöcke
  void setBlockImage(PImage img) {
    this.blockImage = img;
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
    fd.density =  6.0f; // Dichte der Blöcke
    fd.friction = 0.5f; // Reibung für realistische Interaktion
    fd.restitution = 0.075f; // Geringe Rückprallwirkung

    Body block = box2d.createBody(bd);
    block.createFixture(fd);

    blocks.add(block); // Block zur Liste hinzufügen
    blockDimensions.add(new PVector(blockWidth, blockHeight)); // Speichere Breite und Höhe
  }

  void display() {
    for (int i = 0; i < blocks.size(); i++) {
        Body block = blocks.get(i);
        PVector dimensions = blockDimensions.get(i);
        float blockWidth = dimensions.x;
        float blockHeight = dimensions.y;

        Vec2 pos = box2d.getBodyPixelCoord(block);
        float angle = block.getAngle(); // Erhalte die Rotation des Blocks

        pushMatrix();
        translate(pos.x, pos.y); // Verschiebe in die Position des Blocks
        rotate(-angle); // Rotiere um den Winkel des Blocks (Box2D arbeitet mit negativen Winkeln)

        if (blockImage != null) {
            // Zeichne das Bild exakt auf die Größe des Blocks
            image(blockImage, -blockWidth / 2, -blockHeight / 2, blockWidth, blockHeight);
        } else {
            // Fallback: Zeichne ein braunes Rechteck, falls kein Bild verfügbar ist
            fill(139, 69, 19); // Braune Farbe für die Blöcke
            rectMode(CENTER);
            rect(0, 0, blockWidth, blockHeight);
        }

        popMatrix(); // Matrix-Transformation rückgängig machen
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
