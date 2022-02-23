import spout.*;

boolean DEBUG = true;

// Corner radius
int corner = 20;

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

PGraphics[] valCanvas;
Spout[] valSpout;

PGraphics animCanvas, aggCanvas;
Spout animSpout, aggSpout;

int trueFrames, trueState;

void setup() {
  size(550, 770, P3D);
  animCanvas = createGraphics(550, 770, P3D);

  textureMode(NORMAL);
  positions = Cards.getPositions();
  choice = (int) Math.floor(Math.random() * 4);
  number = (int) Math.floor(Math.random() * 10) + 1;

  frames = 0;
  trueState = 0;
  trueFrames = 0;

  // Create a heart using vectors pointing from center
  for (int i = 0; i < numPoints; i++) {
    morph.add(new PVector());
  }

  suits = new ArrayList < > ();
  suits.add(Cards.getClub(numPoints));
  suits.add(Cards.getDiamond(numPoints));
  suits.add(Cards.getSpade(numPoints));
  suits.add(Cards.getHeart(numPoints));

  for (ArrayList < PVector > suit : suits) {
    System.out.println(suit.size());
  }

  priorColor = color(0, 0, 0);

  animSpout = new Spout(this);
  animSpout.setSenderName("CardMorphAnim");
  
  aggCanvas = createGraphics(1280, 720, P3D);
  aggSpout = new Spout(this);
  aggSpout.setSenderName("CardAgg");

  valCanvas = new PGraphics[10];
  valSpout = new Spout[10];

  for (int i = 0; i < 10; i++) {
    valCanvas[i] = createGraphics(550, 770, P3D);
    valSpout[i] = new Spout(this);
    valSpout[i].setSenderName("MorphCard" + (i + 1));
  }
  frameRate(30);
}

ArrayList<PVector> getMorph(ArrayList<PVector> from, ArrayList<PVector> to, float amount) {
  ArrayList<PVector> morph = new ArrayList<>();

  for (int i = 0; i < from.size(); i++) {
    // Get the vertex we will draw
    PVector v1 = from.get(i);
    // Lerp to the target
    PVector v2 = to.get(i);
    PVector target = PVector.lerp(v1, v2, amount);

    morph.add(target);
  }

  return morph;
}

void drawMorph(int state, float morphAmount, float amountFromCenter, int cardVal, PGraphics canvas) {
  int fillColor;
  ArrayList<PVector> morph = getMorph(suits.get(state % 4), suits.get((state + 1) % 4), morphAmount);
  if (state % 4 == 1 || state % 4 == 3) {
    fillColor = lerpColor(color(209, 45, 54), color(0, 0, 0), morphAmount);
  } else {
    fillColor = lerpColor(color(0, 0, 0), color(209, 45, 54), morphAmount);
  }

  int[][] cardSpaces = Cards.getPositions().get(cardVal);

  // Draw relative to center
  
  canvas.strokeWeight(0);
  canvas.fill(fillColor);

  for (int[] newCoords : cardSpaces) {
    canvas.beginShape();

    canvas.translate(newCoords[0] * amountFromCenter, newCoords[1] * amountFromCenter);
    canvas.rotate(radians(newCoords[2] * amountFromCenter));

    morph.forEach(v -> {
      canvas.vertex(v.x, v.y);
    }
    );

    canvas.endShape(CLOSE);
    canvas.rotate(radians(-newCoords[2]* amountFromCenter));
    canvas.translate(-(newCoords[0] * amountFromCenter), -(newCoords[1] * amountFromCenter));
  }
}

void draw() {
  frames += 1;
  trueFrames += 1;
  
  
  animCanvas.beginDraw();
  if (DEBUG) {
    animCanvas.background(255);
    //animCanvas.strokeWeight(3);
    animCanvas.noFill();
    animCanvas.rect(width, height, width * 0.8, height * 0.8, 10, 10, 10, 10);
  } else {
    animCanvas.clear();
  }

  if (state < 20 && state > 4) {
    morphFrames -= 0.05;
  }

  int valueToDraw = number;

  if (trueFrames >= morphFrames + holdFrames) {
    frames = 0;
    trueFrames = 0;
    state += 1;
    trueState += 1;
  }

  for (int i = 0; i < 10; i++) {
    valCanvas[i].beginDraw();
    valCanvas[i].clear();
    valCanvas[i].fill(255);
    valCanvas[i].rect(0, 0, width, height, corner, corner, corner, corner);
    valCanvas[i].noFill();
    valCanvas[i].translate(550 / 2, 770 / 2);
    valCanvas[i].scale(0.5);
    drawMorph(trueState, Math.min(trueFrames / morphFrames, 1.0), 1.0, i + 1, valCanvas[i]);
    valCanvas[i].endDraw();
    valSpout[i].sendTexture(valCanvas[i]);
  }
  
  aggCanvas.beginDraw();
  aggCanvas.clear();
  aggCanvas.translate(550 / 2, 770 / 2);
  aggCanvas.scale(0.5);
  for (int i = 0; i < 10; i++) {
    int yTranslate = 0, xTranslate = 0;
    if (i == 9 || i == 4) {
      yTranslate = (height + 50);
      if (i == 4) {
        xTranslate = -550 * 4;
      } else {
        xTranslate = -550 * 4 - 50;
      }
    } else  {
      xTranslate = 550;
    }
    aggCanvas.translate(xTranslate , yTranslate);
    
    
    aggCanvas.fill(255);
    aggCanvas.rect(0, 0, 550 * 1.5, 770 * 1.5, corner, corner, corner, corner);
    aggCanvas.noFill();
    drawMorph(trueState, Math.min(trueFrames / morphFrames, 1.0), 1.0, i + 1, aggCanvas);
  }
  aggCanvas.endDraw();
  aggSpout.sendTexture(aggCanvas);

  if (choseSuit || (state > 20 && state % 4 == choice)) {
    morphFrames = 30.0;
    choseSuit = true;
    morph = suits.get(state % 4);
    frames = 0;
    state = choice;
  }

  if (scaleFactor != 50) {
    if (choseSuit)
      scaleFactor -= 1;
  } else if (transformCompletion != 100) {
    transformCompletion += 2;
  }

  animCanvas.translate(550 / 2, 770 / 2);
  animCanvas.scale(scaleFactor / 100.0);
  drawMorph(state, Math.min(frames / morphFrames, 1.0), transformCompletion / 100.0, valueToDraw, animCanvas);

  animCanvas.endDraw();
  animSpout.sendTexture(animCanvas);
}
