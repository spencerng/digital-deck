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

PGraphics boxCanvas;
Spout boxSpout;


int trueFrames, trueState;
String limitMorph = "";
String keepOnly = "";
int chosenVal;

OscP5 oscP5;

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/deck/state")) {
    routineState = msg.get(0).intValue();
    routineStartFrame = frames;
    println("Switching to state " + routineState);
  }
   if (msg.checkAddrPattern("/deck/limit_morph")) {
       limitMorph = msg.get(0).stringValue();
       println("Limiting morph to " + limitMorph + " cards");
   }
   
   if (msg.checkAddrPattern("/deck/chosen_value")) {
       chosenVal = msg.get(0).intValue();
       println("Chose " + chosenVal + " cards");
   }
   
   if (msg.checkAddrPattern("/deck/keep_only")) {
       keepOnly = msg.get(0).stringValue();
       println("Keeping only " + keepOnly + " cards");
   }
   
   
}

PImage[] courtCards;
PImage blueBack, boxImage;

PFont cardFont;

int routineState;

void setup() {
  oscP5 = new OscP5(this, 5005);
  
  routineState = 0;
  
  size(550, 770, P3D);
  
  courtCards = new PImage[] {loadImage("no_pip_jack.png"), 
    loadImage("no_pip_queen.png"), 
    loadImage("no_pip_king.png")};
  cardFont = createFont("card_font.ttf", 150);
  
  blueBack = loadImage("blue_back.jpg");
  boxImage = loadImage("bicycle_box_blue.png");

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
  
  boxCanvas = createGraphics(1600, 1283, P3D);
  boxSpout = new Spout(this);
  boxSpout.setSenderName("BlueCardBox");
  
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

void drawMorph(int suit, float morphAmount, float amountFromCenter, int cardVal, PGraphics canvas, boolean singleMorph, float opacity) {
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
    canvas.tint(0, 255 - opacity);
    canvas.translate(550, 770);
    cardSpaces = new int[][] {{-225, -450, 0}, {240, 450, 180}};
  } else {
    cardSpaces = Cards.getPositions().get(cardVal);
  }
  
  // Draw relative to center
  canvas.strokeWeight(0);
  canvas.fill(fillColor, opacity);
  
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

int routineStartFrame;

void draw() {
  frames += 1;
  
  
  if (routineState == 1) {
    float opacity =  Math.min(255, (frames - routineStartFrame) / 100.0 * 255);
    
    valCanvas[6].beginDraw();
    valCanvas[6].clear();
    valCanvas[6].fill(255, opacity);
    valCanvas[6].rect(0, 0, width, height, corner, corner, corner, corner);
    valCanvas[6].endDraw();
    valSpout[6].sendTexture(valCanvas[6]);
  } else if (routineState == 2) {
    float tintAmount =  Math.max(0, 255 - (frames - routineStartFrame) / 100.0 * 255);
    boxCanvas.beginDraw();
    boxCanvas.clear();
    boxCanvas.image(boxImage, 0, 0);
    boxCanvas.tint(0, tintAmount);
    boxCanvas.endDraw();
    boxSpout.sendTexture(boxCanvas);
    
    valCanvas[6].beginDraw();
    valCanvas[6].clear();
    valCanvas[6].fill(255);
    valCanvas[6].rect(0, 0, width, height, corner, corner, corner, corner);
    valCanvas[6].image(blueBack, 0, 0, 550, 770);
    valCanvas[6].tint(255, 255 - tintAmount);
    valCanvas[6].endDraw();
    valSpout[6].sendTexture(valCanvas[6]);
    

  } else if (routineState == 3 || routineState == 4) {
    boolean singleMorph = !beforeSingleColorMorph();

    float completionAmount = 0.0;
    if (limitMorph.equals("clubs")) {
      state = 0;
    } else if (limitMorph.equals("diamonds")) {
      state = 1;
    } else if (limitMorph.equals("spades")) {
      state = 2;
    } else if (limitMorph.equals("hearts")) {
      state = 3;
    } else {
      if (frames >= morphFrames + holdFrames) {
        frames = 0;
        
        if (!singleMorph) {
          state += 1;
        } else {
         state += 2;
        }
      }
      
       completionAmount = Math.min(frames / morphFrames, 1.0); 
    }
    
    float opacity = 255;

    for (int i = 0; i < 13; i++) {
      valCanvas[i].beginDraw();
      valCanvas[i].clear();
      if (routineState == 4) {
        // Begin fading out cards
        if ((keepOnly.equals("low") && i > 3) || (keepOnly.equals("middle") && (i < 4 || i > 8)) || (keepOnly.equals("high") && i < 9)) {
          opacity =  Math.max(0, 255 - (frames - routineStartFrame) / 100.0 * 255);
        }
      }
      valCanvas[i].fill(255, opacity);
      valCanvas[i].rect(0, 0, width, height, corner, corner, corner, corner);
      valCanvas[i].noFill();
      valCanvas[i].translate(550 / 2, 770 / 2);
      valCanvas[i].scale(0.5);
      drawMorph(state, completionAmount, 1.0, i + 1, valCanvas[i], singleMorph, opacity);
      valCanvas[i].endDraw();
      valSpout[i].sendTexture(valCanvas[i]);
    }
  
    if (scaleFactor != 50) {
      if (choseSuit)
        scaleFactor -= 1;
    } else if (transformCompletion != 100) {
      transformCompletion += 2;
    }
    
  } else if (routineState >= 5) {
    int baseVal = 1;
    int range = 4;
    if (keepOnly.equals("middle")) {
       baseVal = 5;
       range = 5;
    } else if (keepOnly.equals("high")) {
      baseVal = 10; 
    }
    
    int val, nextVal;
    float opacity = 255;
    float nextOpacity = 0;
    float cardOpacity = 255;
    
    if (routineState == 5) {
      // Crossfade = 10 frames
      // Hold = 50 frames
      val = baseVal + ((frames / 60) % range);
      nextVal = (baseVal + (frames / 60) + 1) % range;
      
      if (frames % 60 > 50) {
        cardOpacity = 255 - (frames % 60 - 50) / 10.0 * 255;
        nextOpacity = (frames % 60 - 50) / 10.0 * 255;
        
        boxCanvas.beginDraw();
        boxCanvas.clear();
        boxCanvas.image(boxImage, 0, 0);
        boxCanvas.tint(0, 255 - cardOpacity);
        boxCanvas.endDraw();
        boxSpout.sendTexture(boxCanvas);
      }
    } else {
      val = chosenVal;
      nextVal = chosenVal;
      if (routineState == 7) {
        cardOpacity = Math.max(0, 255 - (frames - routineStartFrame) / 100.0 * 255);
        opacity = Math.max(0, 255 - (frames - routineStartFrame) / 100.0 * 255);
      }
      nextOpacity = 0;
    }
    
    for (int i = 0; i < 13; i++) {
      valCanvas[i].beginDraw();
      valCanvas[i].clear();
      
      if (i == 6) {
        valCanvas[i].fill(255, cardOpacity);
        valCanvas[i].rect(0, 0, width, height, corner, corner, corner, corner);
        valCanvas[i].noFill();
        valCanvas[i].translate(550 / 2, 770 / 2);
        valCanvas[i].scale(0.5);
        
        valCanvas[i].beginDraw();
        valCanvas[i].clear();
        drawMorph(state, 0, 1.0, val, valCanvas[i], true, opacity);
        drawMorph(state, 0, 1.0, nextVal, valCanvas[i], true, nextOpacity);
      }
      valCanvas[i].endDraw();
      valSpout[i].sendTexture(valCanvas[6]);
    }
    
  } 
}
