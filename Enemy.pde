import org.jbox2d.dynamics.*;
import org.jbox2d.common.*;
import org.jbox2d.collision.shapes.*;

class Enemy {
    Box2DProcessing box2d;
    ArrayList<Body> enemies; // Liste der Gegnerkörper
    ArrayList<Float> radii;  // Liste der Radien der Gegner
    ArrayList<Boolean> alive; // Liste, ob ein Gegner noch lebt (true = lebt)
    PImage enemyImage; // Bild für die Gegner
    float impactThreshold = 8f; // Schwelle für zu starken Treffer

    Enemy(Box2DProcessing box2d) {
        this.box2d = box2d;
        this.enemies = new ArrayList<>();
        this.radii = new ArrayList<>();
        this.alive = new ArrayList<>();
    }

    void setEnemyImage(PImage img) {
        this.enemyImage = img;
    }

    void addEnemy(float x, float y, float radius) {
        println("Adding enemy at: " + x + ", " + y + " with radius: " + radius);

        BodyDef bd = new BodyDef();
        bd.type = BodyType.DYNAMIC;
        bd.position = box2d.coordPixelsToWorld(x, y);

        CircleShape cs = new CircleShape();
        cs.m_radius = box2d.scalarPixelsToWorld(radius);

        FixtureDef fd = new FixtureDef();
        fd.shape = cs;
        fd.density = 4.0f; 
        fd.friction = 0.7f; 
        fd.restitution = 0.2f;

        Body enemyBody = box2d.createBody(bd);
        enemyBody.createFixture(fd);

        enemies.add(enemyBody);
        radii.add(radius);
        alive.add(true);

        //println("Enemy added: " + enemyBody);
    }

    void display() {
        for (int i = 0; i < enemies.size(); i++) {
            if (!alive.get(i)) continue;

            Body enemy = enemies.get(i);
            float radius = radii.get(i);

            Vec2 pos = box2d.getBodyPixelCoord(enemy);
            float angle = enemy.getAngle();

            pushMatrix();
            translate(pos.x, pos.y);
            rotate(-angle);

            if (enemyImage != null) {
                image(enemyImage, -radius, -radius, radius * 2, radius * 2); // Zeichne das Bild
            } else {
                fill(255, 0, 0);
                ellipseMode(CENTER);
                ellipse(0, 0, radius * 2, radius * 2); // Zeichne den Kreis, wenn kein Bild gesetzt ist
            }

            popMatrix();
        }
    }

    void checkForBirdCollision(PVector birdPosition, float birdRadius) {
        //println("Checking collisions...");
        for (int i = 0; i < enemies.size(); i++) {
            if (!alive.get(i)) continue;

            Body enemy = enemies.get(i);
            Vec2 enemyPos = box2d.getBodyPixelCoord(enemy);
            float enemyRadius = radii.get(i);

            float distance = dist(enemyPos.x, enemyPos.y, birdPosition.x, birdPosition.y);

            // Debugging-Logs
            //println("Enemy " + i + " position: " + enemyPos + ", Bird position: " + birdPosition);
            //println("Distance to Enemy " + i + ": " + distance + ", Combined Radius: " + (enemyRadius + birdRadius));

            if (distance <= enemyRadius + birdRadius) {
                //println("Enemy " + i + " was hit by the bird!");
                killEnemy(i);
            }
        }
    }

void checkForImpact(ArrayList<Body> towerBlocks) {
    for (int i = 0; i < enemies.size(); i++) {
        if (!alive.get(i)) continue;

        Body enemy = enemies.get(i);

        // Get enemy's velocity and mass
        Vec2 enemyVelocity = enemy.getLinearVelocity();
        float enemyMass = enemy.getMass();
        float kineticEnergy = 0.5f * enemyMass * enemyVelocity.lengthSquared(); // Kinetische Energie

        for (Body towerBlock : towerBlocks) {
            // Check distance to see if the enemy is near a block
            Vec2 towerPos = box2d.getBodyPixelCoord(towerBlock);
            Vec2 enemyPos = box2d.getBodyPixelCoord(enemy);

            // Check if the enemy is close enough to interact with the block
            if (dist(enemyPos.x, enemyPos.y, towerPos.x, towerPos.y) <= radii.get(i) + 20) {
                // Check collision energy threshold
                if (kineticEnergy > impactThreshold * 1000) { // Adjust scaling factor as needed
                    println("Enemy " + i + " died due to high kinetic energy!");
                    killEnemy(i);
                    break;
                }
            }
        }
    }
}


    boolean allEnemiesDefeated() {
      for (boolean aliveState : alive) {
          if (aliveState) {
              return false; // Es gibt noch lebende Gegner
          }
      }
      return true; // Alle Gegner sind tot
  }

  void killEnemy(int index) {
      if (index >= 0 && index < enemies.size() && alive.get(index)) {
          Body enemy = enemies.get(index);
          alive.set(index, false);
          box2d.destroyBody(enemy);
          enemyDeathSound.trigger(); // Kollision-Sound abspielen

          // Punkte für das Töten des Gegners vergeben
          score += 100; // 100 Punkte pro Gegner
          println("Enemy killed! Score: " + score);
      }
  }
}
