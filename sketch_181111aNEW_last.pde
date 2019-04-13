import ddf.minim.*;
import oscP5.*;
import netP5.*;

Minim minim;
AudioSample pingnormal;
AudioSample pongnormal;
AudioSample pingdown;
AudioSample pongdown;
AudioSample pingup;
AudioSample pongup;
AudioSample death;
AudioSample finall;
AudioSample start;

int paddlesx = 10;
int paddlesy = 150;
int righty = 150;

int BallPosX;
int BallPosY;
int BallSize;

boolean downIsDown = false;
boolean upIsDown = false;
boolean wIsDown = false;
boolean sIsDown = false;

int paddleWidth = 20;
int paddleHeightRight = 200;
int paddleHeightLeft = 200;

int speedX;
int speedY;
int speedrectbottomy;
int speedrecttopy;

int scoreLeft = 0;
int scoreRight = 0;

PImage f1, f2;
float f1x, f1y;
//var ALPHALEVEL = 20;S

// settings ellipse
int obstacleWidth = 300;
int obstacleHeight = 500;
int  midpaddlebottomx = 600;
int  midpaddlebottomy = 500;

// NEW SETTINGS
int ballRadius = 25;
boolean movementDown = false;
boolean movementRight = false;
boolean ignoreCentralCollision = true;
int hackTimeout = 10;
int collisionsInsideCenterForm = 0;
int timeoutRestartGame = 0;
boolean isDeathPlayed = false;
int TIMEOUT_BETWEEN_GAMES = 50;
int OFFSET_BALL = 2;
int WIN_POINT_LIMIT = 5;
int TIMEOUT_BETWEEN_ROUNDS = 170;
int TIMEOUT_IDLE_LIMIT = 1000;
boolean startPlayed = false;
boolean resetRound = false;
boolean startRoundPlayed = false;
int timeoutIdle = 0;


OscP5 oscP5;
NetAddress myRemoteLocation;
  
int RANDOM_HIGHER_LIMIT = 600;
int RANDOM_LOWER_LIMIT = 500;
float THRESHOLD_ACTIVITY_IN_PERCENT = 0.2; // percentage difference for ctive sensor has to exceed this value in percent relative to average sensor values.
int posYsensor = 0;
int[] sensorValues = {
  (int)random(RANDOM_LOWER_LIMIT, RANDOM_HIGHER_LIMIT),
  (int)random(RANDOM_LOWER_LIMIT, RANDOM_HIGHER_LIMIT), 
  (int)random(RANDOM_LOWER_LIMIT, RANDOM_HIGHER_LIMIT), 
  (int)random(RANDOM_LOWER_LIMIT, RANDOM_HIGHER_LIMIT), 
  (int)random(RANDOM_LOWER_LIMIT, RANDOM_HIGHER_LIMIT), 
  (int)random(RANDOM_LOWER_LIMIT, RANDOM_HIGHER_LIMIT), 
  (int)random(RANDOM_LOWER_LIMIT, RANDOM_HIGHER_LIMIT), 
  (int)random(RANDOM_LOWER_LIMIT, RANDOM_HIGHER_LIMIT)
};   
int[] sensorValues2 = {
  (int)random(RANDOM_LOWER_LIMIT, RANDOM_HIGHER_LIMIT),
  (int)random(RANDOM_LOWER_LIMIT, RANDOM_HIGHER_LIMIT), 
  (int)random(RANDOM_LOWER_LIMIT, RANDOM_HIGHER_LIMIT), 
  (int)random(RANDOM_LOWER_LIMIT, RANDOM_HIGHER_LIMIT), 
  (int)random(RANDOM_LOWER_LIMIT, RANDOM_HIGHER_LIMIT), 
  (int)random(RANDOM_LOWER_LIMIT, RANDOM_HIGHER_LIMIT), 
  (int)random(RANDOM_LOWER_LIMIT, RANDOM_HIGHER_LIMIT), 
  (int)random(RANDOM_LOWER_LIMIT, RANDOM_HIGHER_LIMIT)
};  
ZensorAnalyser analyser1; 
ZensorAnalyser analyser12;

void setup() { 
  //size(1000, 600);
  frameRate(15);
  fullScreen();
  println(width + ">" + height);
  noCursor();
  fill(255);
  oscP5 = new OscP5(this,4957);
  myRemoteLocation = new NetAddress("127.0.0.1",4957);
  
  f1 = loadImage("mask.jpg");
  f1x = 0;
  f1y = 0;
  //createCanvas(windowWidth-10, windowHeight-10);
  BallPosX = width / 2 + 30;
  BallPosY = height / 2 + 350;
  BallSize = 20;
  //f1 = loadImage("data/fish1.png");  
  //  f2 = loadImage("data/fish1.png");
  //f1x = (width - f1.width)/2;
  // f1y = (height - f1.height)/2;

  speedrecttopy = 7;
  speedrectbottomy = -7;

  speedX = 30;
  speedY = 30;
  
  minim = new Minim(this);

  // load BD.wav from the data folder
  pingnormal = minim.loadSample( "ping normal.wav", 512);
  pongnormal = minim.loadSample( "pong normal.wav", 512);
  //pingdown = minim.loadSample( "ping down.wav", 512);
  //pongdown = minim.loadSample( "pong down.wav", 512);
  pingup = minim.loadSample ("ping up.wav", 512);
  pongup = minim.loadSample ("pong up.wav", 512);
  death = minim.loadSample( "death.wav", 512);
  finall = minim.loadSample ("final.wav", 512);
  start = minim.loadSample ("start.wav", 512);
  for (int i = 0; i < PFont.list().length; i++) {
    println(PFont.list()[i]);
  }                                                                                                                                                                   
  textFont(createFont("Monospaced.bold", 24));
}

void draw() {
  background(0);
  image(f1,f1x,f1y);
  //score
  fill(255);
  text(scoreLeft, 200, 100);
  textSize(100);
  timeoutRestartGame--;
  //println(timeoutRestartGame);
  timeoutIdle++;
  paddleHeightRight = 200;
  paddleHeightLeft = 200;
  
  // ------- SENSORS
  noStroke();
  
  // PADDLE LEFT
  // ------ Analyser 1
  analyser1 = new ZensorAnalyser(sensorValues, THRESHOLD_ACTIVITY_IN_PERCENT, -1);
  
  int activeSensor = analyser1.getActiveSensor();
  float relativePosition = 0;
  if (activeSensor > -1) {
    relativePosition = analyser1.getRelativeSensorPosition();
  }
  
  paddlesy = (activeSensor * height/8) + (int)(relativePosition * height/8); 
  paddlesy -= 100;
  
  
  // PADDLE RIGHT
  // ------ Analyser 1
  analyser12 = new ZensorAnalyser(sensorValues2, THRESHOLD_ACTIVITY_IN_PERCENT, -1);
  
  int activeSensor2 = analyser12.getActiveSensor();
  float relativePosition2 = 0;
  if (activeSensor2 > -1) {
    relativePosition2 = analyser12.getRelativeSensorPosition();
  }
   
  righty = (activeSensor2 * height/8) + (int)(relativePosition2 * height/8); 
  righty -= 100;
  
  // ------- PONG
  
  text(scoreRight, width - 200, 100);
  
   textSize(46);
  text("#lightpong come and play", 350, 80);
  textSize(100);
  //Position of the ball
  if (timeoutRestartGame < 0) {
    if (!startPlayed) {
      start.trigger();
      startPlayed = true;
    }
    BallPosX += speedX;
    BallPosY += speedY + (int)random(2);
    resetRound = false;
  }
  
  
  //restart game
  if (!resetRound && (scoreLeft >= WIN_POINT_LIMIT || scoreRight >= WIN_POINT_LIMIT)) {
    resetRound();
  }
  
  if (timeoutRestartGame > 0 && resetRound) {
    if (!startRoundPlayed) {
      finall.trigger();
      startRoundPlayed = true;
    }
    
    if (random(1) > 0.5) {
      filter(INVERT);
    }
  } else if (scoreLeft >= WIN_POINT_LIMIT || scoreRight >= WIN_POINT_LIMIT) {
    resetRound = false;
    startRoundPlayed = false;
    scoreLeft = 0;
    scoreRight = 0;
  }
  

  //if the ball hits the bottom or the top of the window, it will bounce off
  if (BallPosY > height || BallPosY < 0) {
    movementDown = true;
    speedY = -speedY;
    ignoreCentralCollision = false; // from now on central collision is considered;
  }
  //if the ball goes off to the right, the score on the left will increase and the ball's position will reset
  if (BallPosX > width) {
    scoreLeft += 1;
    BallPosX = width / 2 + 30;
    BallPosY = height / 2 + 350;
    speedX = 30;
    speedY = 30;
    ignoreCentralCollision = true; // ignore central collision till ball touches some external element;
    isDeathPlayed = false;
    
    death.trigger();
    timeoutRestartGame = TIMEOUT_BETWEEN_GAMES;
    startPlayed = false;
    startRoundPlayed = false;
    filter(INVERT);
  }
  //if the ball goes off to the left, the score on the right will increase and the ball's position will reset
  if (BallPosX < 0) {
    scoreRight += 1;
    BallPosX = width / 2 + 30;
    BallPosY = height / 2 + 350;
    speedX = -30;
    speedY = -30;
    ignoreCentralCollision = true; // ignore central collision till ball touches some external element;
    isDeathPlayed = false;
    
    death.trigger();
    timeoutRestartGame = TIMEOUT_BETWEEN_GAMES;
    startPlayed = false;
    startRoundPlayed = false;
    filter(INVERT);
  }
  

  //left paddle
  fill(255);
  rect(paddlesx-20, paddlesy, paddleWidth, paddleHeightLeft); //left paddle
  paddlesy = constrain(paddlesy, 0, height - paddleHeightLeft  );
  //if W(87) is being pressed the left paddle will go up, if S(83) is pressed, then it will go down
  if (wIsDown) {   
    paddlesy -= 20;
    if (timeoutIdle > TIMEOUT_IDLE_LIMIT) {
      resetRound();
    }
    timeoutIdle = 0;
  } 
  if (sIsDown) {   
    paddlesy += 20;
    if (timeoutIdle > TIMEOUT_IDLE_LIMIT) {
      resetRound();
      scoreLeft = 0;
      scoreRight = 0;
    }
    timeoutIdle = 0;
  }
  
  hackTimeout--;
  boolean timeoutOk = hackTimeout < 0;
  
  //if the ball comes into contact with the left paddle, then it will bounce off.
  if ((timeoutOk && (BallPosY > paddlesy) && (BallPosY < (paddlesy + paddleHeightLeft)) 
        && ((BallPosX + BallSize / -2) < (paddlesx-20 + paddleWidth))
        && ((BallPosX + BallSize / -2) > paddlesx-20))
        ) {
    hackTimeout = 10;
    speedX = -speedX;
    speedY = speedY; 
    movementRight = true;
    ignoreCentralCollision = false; // from now on central collision is considered;
    collisionsInsideCenterForm = 0;
    
    if (speedY > 0) {
      pongup.trigger();
    } else {
      pongnormal.trigger();
    }
  }
  //right paddle
  fill(255);
  rect(width - paddlesx, righty, paddleWidth, paddleHeightRight); //right paddle
  righty = constrain(righty, 0, height - paddleHeightRight);
  // if the up and down arrows are being pressed, then the paddle will move in regards to the direction of the arrow
  if (upIsDown) {   
    righty -= 20;
    if (timeoutIdle > TIMEOUT_IDLE_LIMIT) {
      resetRound();
      startRoundPlayed = false;
      scoreLeft = 0;
      scoreRight = 0;
    }
    timeoutIdle = 0;
  } 

  if (downIsDown) {   
    righty += 20;
    if (timeoutIdle > TIMEOUT_IDLE_LIMIT) {
      resetRound();
      startRoundPlayed = false;
      scoreLeft = 0;
      scoreRight = 0;
    }
    timeoutIdle = 0;
  } 
  //if the ball comes into contact with the right paddle, then it will bounce off.
  if ((timeoutOk && BallPosY > righty 
        && BallPosY < righty + paddleHeightRight 
        && BallPosX + BallSize / 2 > width - paddlesx)
        ){
    hackTimeout = 10;
    speedX = -speedX;
    speedY = speedY; 
    movementRight = false;
    ignoreCentralCollision = false; // from now on central collision is considered;
    collisionsInsideCenterForm = 0;
    
    //speedY = speedY; ?
    if (speedY > 0) {
      pingup.trigger();
    } else {
      //pingdown.trigger();
      pingnormal.trigger();
    }
  }

  //ball
  fill(255, 0, 0);
  ellipse(BallPosX, BallPosY, ballRadius, ballRadius);
  //image(f2,BallPosX,BallPosY);

  //central obstacle
  //ellipse(midpaddlebottomx, midpaddlebottomy, obstacleWidth, obstacleHeight);
  
  hackTimeout--;
  timeoutOk = hackTimeout < 0;
  
  if(timeoutOk && !ignoreCentralCollision && pp_collision(f1,f1x,f1y,ballRadius,BallPosX,BallPosY)){
    hackTimeout = 10;
    collisionsInsideCenterForm++;
    if (movementDown) {
      //speedY = -speedY;
      movementDown = false;
      pingnormal.trigger();
      //if (movementRight) {
        speedX = -speedX;
        //speedY = -speedY;
      //}
    } else {
      pongnormal.trigger();
      speedX = -speedX;
    }
  }
  
  if (collisionsInsideCenterForm  > 10) {
    ignoreCentralCollision = true;
  }
}



void resetRound() {
  resetRound = true;
  timeoutRestartGame = TIMEOUT_BETWEEN_ROUNDS;
}



/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  if (theOscMessage.addrPattern().equals("/playerOne")) {
    for (int i = 0; i < 8; i++) {
      sensorValues[i] = Integer.valueOf(theOscMessage.get(i).stringValue());
    }
  }
  if (theOscMessage.addrPattern().equals("/playerTwo")) {
    for (int i = 0; i < 8; i++) {
      sensorValues2[i] = Integer.valueOf(theOscMessage.get(i).stringValue());
    }
  }
}


// A pixel width an alpha level below this value is
// considered transparent.
final int ALPHALEVEL = 20;

boolean pp_collision(PImage imgA, float aix, float aiy, int radius, float bix, float biy) {
  int topA, botA, leftA, rightA;
  int topB, botB, leftB, rightB;
  int topO, botO, leftO, rightO;
  int ax, ay;
  int bx, by;
  int APx, APy, ASx, ASy;
  int BPx, BPy; //, BSx, BSy;

  topA   = (int) aiy;
  botA   = (int) aiy + imgA.height;
  leftA  = (int) aix;
  rightA = (int) aix + imgA.width;
  topB   = (int) biy;
  botB   = (int) biy + radius;
  leftB  = (int) bix;
  rightB = (int) bix + radius;

  if (botA <= topB  || botB <= topA || rightA <= leftB || rightB <= leftA)
    return false;

  // If we get here, we know that there is an overlap
  // So we work out where the sides of the overlap are
  leftO = (leftA < leftB) ? leftB : leftA;
  rightO = (rightA > rightB) ? rightB : rightA;
  botO = (botA > botB) ? botB : botA;
  topO = (topA < topB) ? topB : topA;


  // P is the top-left, S is the bottom-right of the overlap
  APx = leftO-leftA;   
  APy = topO-topA;
  ASx = rightO-leftA;  
  ASy = botO-topA-1;
  BPx = leftO-leftB;   
  BPy = topO-topB;

  int widthO = rightO - leftO;
  boolean foundCollision = false;

  // Images to test
  imgA.loadPixels();
  //imgB.loadPixels();

  // These are widths in BYTES. They are used inside the loop
  //  to avoid the need to do the slow multiplications
  int surfaceWidthA = imgA.width;
  int surfaceWidthB = radius;

  boolean pixelABlack = false;

  // Get start pixel positions
  int pA = (APy * surfaceWidthA) + APx;
  int pB = (BPy * surfaceWidthB) + BPx;

  ax = APx; 
  ay = APy;
  bx = BPx; // remove
  by = BPy; // remove
  for (ay = APy; ay < ASy; ay++) {
    bx = BPx;
    for (ax = APx; ax < ASx; ax++) {
      pixelABlack = brightness(imgA.pixels[pA]) > 230;

      if (pixelABlack) {
        foundCollision = true;
        break;
      }
      pA ++;
      pB ++;
      bx++;// remove
    }
    if (foundCollision) break;
    pA = pA + surfaceWidthA - widthO;
    pB = pB + surfaceWidthB - widthO;
    by++;// remove
  }
  return foundCollision;
}

void keyPressed() {
  if (key == 'w' || key == 'W') {
    wIsDown = true;
  }
  if (key == 's' || key == 'S') {
    sIsDown = true;
  }
  if (key == 'o' || key == 'O') {
    upIsDown = true;
  }
  if (key == 'l' || key == 'l') {
    downIsDown = true;
  }
}

void keyReleased () {
  downIsDown = false;
  upIsDown = false;
  wIsDown = false;
  sIsDown = false;
}
