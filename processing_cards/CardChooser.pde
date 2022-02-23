import spout.*;

boolean DEBUG = true;

int choice, number;

int transformCompletion = 0;
int scaleFactor = 100;
boolean choseSuit = false;
ArrayList < ArrayList < PVector >> suits;

// An ArrayList for the vertices we'll be drawing
// in the window
ArrayList < PVector > morph = new ArrayList < PVector > ();

// Current index of the displayed suit
int state = 0;
int frames;

float speed = 0.15;

int priorColor = 0;

int numPoints = 60;
float morphFrames = 30.0;
int holdFrames = 5;

HashMap < Integer, int[][] > positions;

Spout spout;

void setup() {
    size(550, 770, P3D);
    textureMode(NORMAL);
    positions = Cards.getPositions();
    choice = (int) Math.floor(Math.random() * 4);
    number = (int) Math.floor(Math.random() * 10) + 1;

    frames = 0;

    // Create a heart using vectors pointing from center
    for (int i = 0; i < numPoints; i++) {
        morph.add(new PVector());
    }

    suits = new ArrayList < > ();

    suits.add(Cards.getClub(numPoints));
    suits.add(Cards.getDiamond(numPoints));
    suits.add(Cards.getSpade(numPoints));
    suits.add(Cards.getHeart(numPoints));

    for (ArrayList < PVector > suit: suits) {
        System.out.println(suit.size());
    }

    priorColor = color(0, 0, 0);

    spout = new Spout(this);
    String sendername = "CardMorphAnim";
    spout.createSender(sendername, width, height);
    frameRate(60);
}

void draw() {
    frames += 1;
    if (DEBUG) {
      background(255);
      strokeWeight(3);
      noFill();
      rect(width * 0.1, height * 0.1, width * 0.8, height * 0.8, 10, 10, 10, 10);
      
    } else {
      clear();
    }
    
    
    

    if (state < 20 && state > 4) {
        morphFrames -= 0.05;
    }

    int fillColor = priorColor;
    if (!choseSuit && (state < 20 || state % 4 != choice)) {
      
        // Look at each vertex
        ArrayList < PVector > shape = suits.get(state % 4);
        System.out.println(frames / morphFrames);
        for (int i = 0; i < shape.size(); i++) {
            // Get the vertex we will draw
            PVector v1 = shape.get(i);
            // Lerp to the target
            PVector v2 = suits.get((state + 1) % 4).get(i);
            PVector target = PVector.lerp(v1, v2, Math.min(frames / morphFrames, 1.0));
            
            morph.set(i, target);
            
        }

        if (state % 4 == 1 || state % 4 == 3) {
            fillColor = lerpColor(color(209, 45, 54), color(0, 0, 0), Math.min(frames / morphFrames, 1.0));
        } else {
            fillColor = lerpColor(color(0, 0, 0), color(209, 45, 54), Math.min(frames / morphFrames, 1.0));
        }
        priorColor = fillColor;

        // If all the vertices are close, switch shape
        if (frames >= morphFrames) {
            if (frames >= morphFrames + holdFrames) {
              frames = 0;
              state += 1;
            }
        }
    } else {
        choseSuit = true;
        morph = suits.get(state % 4);
    }

    // Draw relative to center
    translate(width / 2, height / 2);
    strokeWeight(0);

    fill(fillColor);
    stroke(0);
    if (scaleFactor != 50) {
        beginShape();

        if (choseSuit) {
            scaleFactor -= 1;
        }
        scale(scaleFactor / 100.0);

        morph.forEach(v -> {
            vertex(v.x, v.y);
        });
        endShape(CLOSE);
    } else {
        scale(scaleFactor / 100.0);
        int[][] cardSpaces = positions.get(number);


        if (transformCompletion != 100) {
            transformCompletion += 2;
        }
        
        for (int[] newCoords : cardSpaces) {
            beginShape();
            
            translate((newCoords[0] * transformCompletion) / 100.0, (newCoords[1] * transformCompletion) / 100.0);
            rotate(radians(newCoords[2] * transformCompletion) / 100.0);

            morph.forEach(v -> {
                vertex(v.x, v.y);
                
            });
            
            endShape(CLOSE);
            rotate(radians(-newCoords[2] * transformCompletion) / 100.0);
            translate(-(newCoords[0] * transformCompletion) / 100.0, -(newCoords[1] * transformCompletion) / 100.0);
            
            
        }
    }
    
    spout.sendTexture();
}
