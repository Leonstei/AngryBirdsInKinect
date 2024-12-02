class Block {
  PImage image;  // Das Bild des Blocks
  PVector position;  // Position des Blocks
  float speedY = 0;  // Geschwindigkeit in Y-Richtung (für Schwerkraft)
  boolean isFalling = false;  // Ob der Block sich gerade bewegt

  // Konstruktor
  Block(PImage img, PVector pos) {
    image = img;
    position = pos;
  }


  // Block zeichnen
  void draw() {
    image(image, position.x, position.y, 50, 150);  // Größe des Blocks hier anpassen
  }
  // Block als fallend markieren
  

  // Schwerkraft anwenden
  void blockGravity() {
    if (isFalling) {
      speedY += 0.5;  // Schwerkraft (jeder Block fällt mit einer Geschwindigkeit von 0.5)
      position.y += speedY;  // Position in Y-Richtung anpassen

      // Wenn der Block den Boden erreicht, stoppen wir ihn (bodenabsprung mit Dämpfung)
      if (position.y + image.height > height+200) {
        position.y = (height+200) - image.height;  // Bild am Boden fixieren
        speedY *= -0.2;  // Geschwindigkeit umkehren (Bodenabsprung mit Dämpfung)
      }
    }
  }
  void startFalling() {
    isFalling = true;
  }
}
