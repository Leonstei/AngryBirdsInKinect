// Variablen für den "Vogel" (ein Kreis in diesem Fall)

double DT = 0.06;  // time increment
double MASS = 1.0;
double g_acc = +9.8;  // gravity constant
double times;    // time since start
double birdX, birdX;    // actual position 
double vx, vy;    // actual velocity 
double ax, ay;    // acceleration, currently constant = (0,+9.8)

   // Y-Position des Vogels
float birdSize = 20; // Größe des Vogels




// Zustand des Vogels (bewegt sich der Vogel oder ruht er?)
boolean isFlying = false;

void setup() {
  fullScreen();
  resetBird();
  frameRate(5);
}

void draw() {
  //background(255);

  // Vogel nur bewegen, wenn er "fliegt"
  if (isFlying) {
    
    vx = velocityX+schritweite*beschleunigungX;
    vy = velocityY+schritweite*gravity;

    // Geschwindigkeit auf Position anwenden
    birdX += velocityX;
    birdY += velocityY;
    
    // Begrenzung am Boden (simple Boden-Kollision)
    if (birdY > height - birdSize / 2) {
      birdY = height - birdSize / 2;
      velocityY = 0.0;
      velocityX = 0.0;
      isFlying = false; // Flug beenden, wenn Boden erreicht
    }
  }
  
  // Vogel zeichnen
  fill(255, 0, 0);
  ellipse(birdX, birdY, birdSize, birdSize);
}

// Funktion zum Neustarten des Vogels
void resetBird() {
  birdX = 50;            // Startposition in X
  birdY = height - 50;   // Startposition in Y (über dem Boden)
  velocityX = 8;         // Startgeschwindigkeit in X
  velocityY = -15;       // Startgeschwindigkeit in Y
  isFlying = true;       // Setzt den Zustand auf "fliegend"
}

// Funktion zum Auslösen des Vogels mit der Maus (oder Kinect später)
void mousePressed() {
  if (!isFlying) {
    resetBird(); // Nur neu starten, wenn der Vogel am Boden ist
  }
}
