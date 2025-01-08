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
                enemy.addEnemy(900, height - 55, 30); // Position (600, Höhe - 100), Radius 20
                enemy.addEnemy(900, height - 200, 30); // Position (600, Höhe - 100), Radius 20

                tower.buildSimpleHouse(new PVector(900, height - 50), 40, 20); 
                tower.buildSimpleHouse(new PVector(900, height - 150), 40, 20); 
                break;
            case 2:
                println("Loading Level 2");
                enemy.addEnemy(900, height - 55, 30); // Position (600, Höhe - 100), Radius 20
                enemy.addEnemy(900, height - 200, 30); // Position (600, Höhe - 100), Radius 20
                enemy.addEnemy(900, height - 330, 30); // Position (600, Höhe - 100), Radius 20

                tower.buildSimpleHouse(new PVector(900, height - 50), 40, 20); 
                tower.buildSimpleHouse(new PVector(900, height - 150), 40, 20); 
                tower.buildSimpleHouse(new PVector(900, height - 300), 40, 20); 
                break;

            case 3:
                println("Loading Level 3");
                enemy.addEnemy(900, height - 55, 30); // Position (600, Höhe - 100), Radius 20
                enemy.addEnemy(900, height - 200, 30); // Position (600, Höhe - 100), Radius 20
                enemy.addEnemy(900, height - 330, 30); // Position (600, Höhe - 100), Radius 20
                enemy.addEnemy(900, height - 460, 50); // Position (600, Höhe - 100), Radius 20                break;

                tower.buildSimpleHouse(new PVector(900, height - 50), 40, 20); 
                tower.buildSimpleHouse(new PVector(900, height - 150), 40, 20); 
                tower.buildSimpleHouse(new PVector(900, height - 300), 40, 20); 
                tower.buildSimpleHouse(new PVector(900, height - 450), 40, 20); 
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
    }
}
