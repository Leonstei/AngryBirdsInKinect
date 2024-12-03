class Block {
  PImage image;  // Das Bild des Blocks
  PVector position;  // Position des Blocks
  PVector blocksize;
  float speedY = 0;  // Geschwindigkeit in Y-Richtung (für Schwerkraft)
  boolean isFalling = false;  // Ob der Block sich gerade bewegt

  // Konstruktor
  Block(PImage img, PVector pos, PVector size) {
    image = img;
    position = pos;
    blocksize = size;
  }


  // Block zeichnen
  void draw() {
    image(image, position.x, position.y, blocksize.x, blocksize.y);
  }
  // Block als fallend markieren


  // Schwerkraft anwenden
  void blockGravity() {
    if (isFalling) {
      speedY += 0.5;  // Schwerkraft (jeder Block fällt mit einer Geschwindigkeit von 0.5)
      position.y += speedY;  // Position in Y-Richtung anpassen

      // Überprüfen, ob der Block auf einem anderen Block landet
      for (Block other : bildliste) {
        if (this != other) {
          if ( position.x + blocksize.x > other.position.x && position.x < other.position.x + other.blocksize.x) {
            // Prüfen, ob der Block den anderen Block berührt
            if (position.y + blocksize.y > other.position.y && position.y + blocksize.y < other.position.y + other.blocksize.y) {
              position.y = other.position.y - blocksize.y;  // Block auf den anderen Block setzen
              speedY = 0;  // Schwerkraft stoppen
              isFalling = false;  // Block hört auf zu fallen
              break;  // Keine weitere Prüfung, der Block hat bereits Kontakt
            }
          }
          // Kollision in X-Richtung
          if (position.y + blocksize.y > other.position.y && position.y < other.position.y + other.blocksize.y) {
            // Prüfen, ob der Block den anderen Block in der X-Richtung berührt
            if (position.x + blocksize.x > other.position.x && position.x + blocksize.x < other.position.x + other.blocksize.x) {
              position.x = other.position.x - blocksize.x;  // Block auf der linken Seite des anderen Blocks setzen
              speedY = 0;  // Schwerkraft stoppen
              isFalling = false;  // Block hört auf zu fallen
              break;  // Keine weitere Prüfung, der Block hat bereits Kontakt
            }

            if (position.x < other.position.x + other.blocksize.x && position.x > other.position.x) {
              position.x = other.position.x + other.blocksize.x;  // Block auf der rechten Seite des anderen Blocks setzen
              speedY = 0;  // Schwerkraft stoppen
              isFalling = false;  // Block hört auf zu fallen
              break;  // Keine weitere Prüfung, der Block hat bereits Kontakt
            }
          }
        }
      }
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
