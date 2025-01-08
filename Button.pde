class Button {
  PVector position;
  PVector size;
  PImage imageNormal;
  PImage imageHover;
  boolean isHovered = false;
  float hoverTime = 0; // Zeit, die die Hand über dem Knopf bleibt
  float hoverThreshold = 2.0; // Sekunden, die zum Aktivieren benötigt werden

  Button(PVector position, PVector size, PImage imageNormal, PImage imageHover) {
    this.position = position;
    this.size = size;
    this.imageNormal = imageNormal;
    this.imageHover = imageHover;
  }

  void display() {
    if (isHovered) {
      image(imageHover, position.x, position.y, size.x, size.y);
    } else {
      image(imageNormal, position.x, position.y, size.x, size.y);
    }
  }

  void update(PVector rightHand, PVector leftHand) {
    boolean isHoveredByRightHand = rightHand.x >= position.x && rightHand.x <= position.x + size.x &&
                                   rightHand.y >= position.y && rightHand.y <= position.y + size.y;
    boolean isHoveredByLeftHand = leftHand.x >= position.x && leftHand.x <= position.x + size.x &&
                                  leftHand.y >= position.y && leftHand.y <= position.y + size.y;
  
    if (isHoveredByRightHand || isHoveredByLeftHand) {
      isHovered = true;
      hoverTime += 1.0 / frameRate; // Zeit erhöhen basierend auf der Framerate
    } else {
      isHovered = false;
      hoverTime = 0; // Reset, wenn keine Hand über dem Knopf ist
    }
  }


  boolean isActivated() {
    return hoverTime >= hoverThreshold; // Knopf wird aktiviert, wenn die Zeit überschritten ist
  }
}
