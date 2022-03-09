import spout.*;
import netP5.*;
import oscP5.*;

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
int holdFrames = 30;

HashMap < Integer, int[][] > positions;

PGraphics[] valCanvas;
Spout[] valSpout;


int trueFrames, trueState;
String limitMorph = "";

OscP5 oscP5;

void oscEvent(OscMessage msg) {
   if (msg.checkAddrPattern("/deck/limit_morph")) {
       limitMorph = msg.get(0).stringValue();
       println("Limiting morph to " + limitMorph + " cards");
   }
}

PImage[] courtCards;
PFont cardFont;

void setup() {
  oscP5 = new OscP5(this, 5005);
  
  size(550, 770, P3D);
  
  courtCards = new PImage[] {loadImage("no_pip_jack.png"), 
    loadImage("no_pip_queen.png"), 
    loadImage("no_pip_king.png")};
  cardFont = createFont("card_font.ttf", 150);

  textureMode(NORMAL);
  positions = Cards.getPositions();

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

  valCanvas = new PGraphics[13];
  valSpout = new Spout[13];

  for (int i = 0; i < 13; i++) {
    valCanvas[i] = createGraphics(550, 770, P3D);
    valSpout[i] = new Spout(this);
    valSpout[i].setSenderName("MorphCard" + (i + 1));
  }
  
  frameRate(60);
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

void drawMorph(int suit, float morphAmount, float amountFromCenter, int cardVal, PGraphics canvas, boolean singleMorph) {
  int fillColor;
  ArrayList<PVector> morph;
  if (singleMorph) {
     morph = getMorph(suits.get(suit % 4), suits.get((suit + 2) % 4), morphAmount);
    if (limitMorph.equals("red")) {
      fillColor = color(209, 45, 54);
    } else {
      fillColor = color(0,0, 0); 
    }
  } else {
    morph = getMorph(suits.get(suit % 4), suits.get((suit + 1) % 4), morphAmount);
    if (suit % 2 == 1) {
      fillColor = lerpColor(color(209, 45, 54), color(0, 0, 0), morphAmount);
    } else {
      fillColor = lerpColor(color(0, 0, 0), color(209, 45, 54), morphAmount);
    }
  }
  
  int[][] cardSpaces;
  
  
  if (cardVal >= 11) {
    canvas.translate(-550, -770);
    canvas.image(courtCards[cardVal - 11], 20, 30, 550 * 2, 770 * 2);
    canvas.translate(550, 770);
    cardSpaces = new int[][] {{-225, -450, 0}, {240, 450, 180}};
  } else {
    cardSpaces = Cards.getPositions().get(cardVal);
  }
  
  // Draw relative to center
  canvas.strokeWeight(0);
  canvas.fill(fillColor);
  
  
  // Draw index
  canvas.textFont(cardFont);
  String[] index = new String[] {"A", "2", "3", "4", "5", "6", "7", "8", "9", "=", "J", "Q", "K"};
  canvas.text(index[cardVal - 1], -475, -520);
  canvas.rotate(radians(180));
  canvas.text(index[cardVal - 1], -490, -520);
  canvas.rotate(radians(180));
  

  

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

boolean beforeSingleColorMorph() {
  return limitMorph.length() == 0 || (limitMorph.equals("red") && state % 2 == 0) || 
      (limitMorph.equals("black") && state % 2 == 1);
}

void draw() {
  frames += 1;
    
  boolean singleMorph = !beforeSingleColorMorph();


  if (frames >= morphFrames + holdFrames) {
    frames = 0;
    
    if (!singleMorph) {
      state += 1;
    } else {
     state += 2;
    }
  }

  for (int i = 0; i < 13; i++) {
    valCanvas[i].beginDraw();
    valCanvas[i].clear();
    valCanvas[i].fill(255);
    valCanvas[i].rect(0, 0, width, height, corner, corner, corner, corner);
    valCanvas[i].noFill();
    valCanvas[i].translate(550 / 2, 770 / 2);
    valCanvas[i].scale(0.5);
    drawMorph(trueState, Math.min(trueFrames / morphFrames, 1.0), 1.0, i + 1, valCanvas[i], singleMorph);
    valCanvas[i].endDraw();
    valSpout[i].sendTexture(valCanvas[i]);
  }

  if (scaleFactor != 50) {
    if (choseSuit)
      scaleFactor -= 1;
  } else if (transformCompletion != 100) {
    transformCompletion += 2;
  }

}
