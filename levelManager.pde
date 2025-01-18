class Level {
    TowerBlock tower;
    Enemy enemy;
    Box2DProcessing box2d;
    Bird bird;

    Level(Box2DProcessing box2d, TowerBlock tower, Enemy enemy, Bird bird) {
        this.box2d = box2d;
        this.tower = tower;
        this.enemy = enemy;
        this.bird = bird;
    }

    void loadLevel(int levelNumber) {
        // Reset all elements
        resetLevel();

        switch (levelNumber) {
            case 1:
                println("Loading Level 1");
                // Gegner für den ersten Turm
                enemy.addEnemy(800, height - 55, 30);
                enemy.addEnemy(800, height - 200, 30);
                enemy.addEnemy(800, height - 330, 30);
                enemy.addEnemy(800, height - 460, 50);
            
                // Erster Turm
                tower.buildSimpleHouse(new PVector(800, height - 50), 40, 20);
                tower.buildSimpleHouse(new PVector(800, height - 150), 40, 20);
                tower.buildSimpleHouse(new PVector(800, height - 300), 40, 20);
                tower.buildSimpleHouse(new PVector(800, height - 450), 40, 20);
            
                // Gegner für den zweiten Turm
                enemy.addEnemy(1000, height - 55, 30);
                enemy.addEnemy(1000, height - 200, 30);
                enemy.addEnemy(1000, height - 330, 30);
            
                // Zweiter Turm
                tower.buildSimpleHouse(new PVector(1000, height - 50), 40, 20);
                tower.buildSimpleHouse(new PVector(1000, height - 150), 40, 20);
                tower.buildSimpleHouse(new PVector(1000, height - 300), 40, 20);
                            break;
            case 2:
                println("Loading Level 2");
                // Gegner und eine höhere Struktur
                enemy.addEnemy(850, height - 55, 30);
                enemy.addEnemy(850, height - 200, 30);
                enemy.addEnemy(850, height - 330, 30);
                enemy.addEnemy(850, height - 460, 50);
            
                tower.buildSimpleHouse(new PVector(850, height - 50), 40, 20);
                tower.buildSimpleHouse(new PVector(850, height - 150), 40, 20);
                tower.buildSimpleHouse(new PVector(850, height - 300), 40, 20);
                tower.buildSimpleHouse(new PVector(850, height - 450), 40, 20);
            
                // Ein zweiter, breiterer Turm mit Gegnern oben
                enemy.addEnemy(1200, height - 55, 30);
                enemy.addEnemy(1200, height - 200, 30);
            
                tower.buildSimpleHouse(new PVector(1200, height - 50), 40, 20);
                tower.buildSimpleHouse(new PVector(1200, height - 150), 40, 20);

                break;

            case 3:
                println("Loading Level 3");
            // Gegner für den ersten Turm
              enemy.addEnemy(850, height - 55, 30);
              enemy.addEnemy(850, height - 200, 30);
              enemy.addEnemy(850, height - 330, 30);
          
              // Erster Turm
              tower.buildSimpleHouse(new PVector(850, height - 50), 40, 20);
              tower.buildSimpleHouse(new PVector(850, height - 150), 40, 20);
              tower.buildSimpleHouse(new PVector(850, height - 300), 40, 20);
          
              // Gegner für den zweiten Turm
              enemy.addEnemy(1100, height - 55, 30);
              enemy.addEnemy(1100, height - 200, 30);
              enemy.addEnemy(1100, height - 330, 30);
              enemy.addEnemy(1100, height - 460, 50);
          
              // Zweiter Turm
              tower.buildSimpleHouse(new PVector(1100, height - 50), 40, 20);
              tower.buildSimpleHouse(new PVector(1100, height - 150), 40, 20);
              tower.buildSimpleHouse(new PVector(1100, height - 300), 40, 20);
              tower.buildSimpleHouse(new PVector(1100, height - 450), 40, 20);
          
              // Gegner für den dritten Turm
              enemy.addEnemy(1300, height - 55, 30);
              enemy.addEnemy(1300, height - 200, 30);
              enemy.addEnemy(1300, height - 330, 30);
          
              // Dritter Turm
              tower.buildSimpleHouse(new PVector(1300, height - 50), 40, 20);
              tower.buildSimpleHouse(new PVector(1300, height - 150), 40, 20);
              tower.buildSimpleHouse(new PVector(1300, height - 300), 40, 20);
          
              // Gegner für den vierten Turm
              enemy.addEnemy(1500, height - 55, 30);
              enemy.addEnemy(1500, height - 200, 30);
              enemy.addEnemy(1500, height - 330, 30);
              enemy.addEnemy(1500, height - 460, 50);
              enemy.addEnemy(1500, height - 590, 30);
          
              // Vierter Turm
              tower.buildSimpleHouse(new PVector(1500, height - 50), 40, 20);
              tower.buildSimpleHouse(new PVector(1500, height - 150), 40, 20);
              tower.buildSimpleHouse(new PVector(1500, height - 300), 40, 20);
              tower.buildSimpleHouse(new PVector(1500, height - 450), 40, 20);
              tower.buildSimpleHouse(new PVector(1500, height - 580), 40, 20);

                break;

            default:
                println("Invalid Level Number");
                break;
        }

        bird.resetBird();
    }

    void resetLevel() {
        // Reset the bird
        bird.resetBird();

        // Clear all tower blocks
        for (Body block : tower.getBlocks()) {
            box2d.destroyBody(block);
        }
        tower.blocks.clear();
        tower.blockDimensions.clear();

        // Clear all enemies
        for (int i = 0; i < enemy.enemies.size(); i++) {
            if (enemy.alive.get(i)) {
                box2d.destroyBody(enemy.enemies.get(i));
            }
        }
        enemy.enemies.clear();
        enemy.radii.clear();
        enemy.alive.clear();
        
         // Punkte und Schüsse zurücksetzen
          score = 0;
          shotsFired = 0;
          gameWon = false; // Win-Screen zurücksetzen
          bonusAwarded = false; // Bonusvergabe zurücksetzen

    }
}
