import org.jbox2d.dynamics.*;
import org.jbox2d.common.*;
import org.jbox2d.collision.shapes.*;

class Enemy {
    Box2DProcessing box2d;
    ArrayList<Body> enemies; // Liste der Gegnerkörper
    ArrayList<Float> radii;  // Liste der Radien der Gegner
    ArrayList<Boolean> alive; // Liste, ob ein Gegner noch lebt (true = lebt)
    float impactThreshold = 6.5f; // Schwelle für zu starken Treffer
    PImage enemyImage;

    Enemy(Box2DProcessing box2d) {
        this.box2d = box2d;
        this.enemies = new ArrayList<Body>();
        this.radii = new ArrayList<Float>();
        this.alive = new ArrayList<Boolean>();
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
        fd.density = 3.0f; 
        fd.friction = 0.5f; 
        fd.restitution = 0.2f;

        Body enemyBody = box2d.createBody(bd);
        enemyBody.createFixture(fd);

        enemies.add(enemyBody);
        radii.add(radius);
        alive.add(true);

        println("Enemy added: " + enemyBody);
    }

    void display() {
        fill(255, 0, 0);
        stroke(0);
        for (int i = 0; i < enemies.size(); i++) {
            if (!alive.get(i)) continue;

            Body enemy = enemies.get(i);
            float radius = radii.get(i);

            Vec2 pos = box2d.getBodyPixelCoord(enemy);
            float angle = enemy.getAngle();

            pushMatrix();
            translate(pos.x, pos.y);
            rotate(-angle);
            ellipseMode(CENTER);
            ellipse(0, 0, radius * 2, radius * 2);
            popMatrix();

            // Debug: Kollisionsbereich anzeigen
            noFill();
            stroke(0, 255, 0);
            ellipse(pos.x, pos.y, radius * 2, radius * 2);
        }
    }

    void checkForBirdCollision(PVector birdPosition, float birdRadius) {
        println("Checking collisions...");
        for (int i = 0; i < enemies.size(); i++) {
            if (!alive.get(i)) continue;

            Body enemy = enemies.get(i);
            Vec2 enemyPos = box2d.getBodyPixelCoord(enemy);
            float enemyRadius = radii.get(i);

            float distance = dist(enemyPos.x, enemyPos.y, birdPosition.x, birdPosition.y);

            // Debugging-Logs
            println("Enemy " + i + " position: " + enemyPos + ", Bird position: " + birdPosition);
            println("Distance to Enemy " + i + ": " + distance + ", Combined Radius: " + (enemyRadius + birdRadius));

            if (distance <= enemyRadius + birdRadius) {
                println("Enemy " + i + " was hit by the bird!");
                killEnemy(i);
            }
        }
    }

    void checkForImpact(ArrayList<Body> towerBlocks) {
        for (int i = 0; i < enemies.size(); i++) {
            if (!alive.get(i)) continue;

            Body enemy = enemies.get(i);
            Vec2 velocity = enemy.getLinearVelocity();
            float impactForce = velocity.length();

            for (Body towerBlock : towerBlocks) {
                Vec2 towerPos = box2d.getBodyPixelCoord(towerBlock);
                Vec2 enemyPos = box2d.getBodyPixelCoord(enemy);

                if (dist(enemyPos.x, enemyPos.y, towerPos.x, towerPos.y) <= radii.get(i) + 20) {
                    if (impactForce > impactThreshold) {
                        println("Enemy " + i + " died due to strong Tower impact!");
                        killEnemy(i);
                        break;
                    }
                }
            }
        }
    }

    void killEnemy(int index) {
        if (index >= 0 && index < enemies.size() && alive.get(index)) {
            Body enemy = enemies.get(index);
            alive.set(index, false);
            box2d.destroyBody(enemy);
        }
    }
}
