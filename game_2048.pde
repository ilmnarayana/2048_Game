import java.util.*;

PImage[] tiles;
PImage emptyTile;
PImage playImg;
PImage gOverImg;
PImage winImg;
float offset;
float sizeOfTile;
float mouseBound[];
boolean viewBoard;
boolean pause;

int scoreFilter[][];

//JSONObject jo;
//Network nn;
//Board b;

Population p;

void setup() {
  size(700, 400);

  String path = "images\\";
  emptyTile = loadImage(path+"null.jpg");
  gOverImg = loadImage(path+"gover.jpg");
  winImg = loadImage(path+"win.jpg");
  playImg = loadImage(path+"play.jpg");

  tiles = new PImage[11];
  for (int i=1; i<12; ++i) {
    tiles[i-1] = loadImage(path+i+".jpg");
  }

  //left, right, top, bottom for mousePressed event
  mouseBound = new float[4];

  offset = 10;
  sizeOfTile = 75;
  viewBoard=false;
  pause=false;

  scoreFilter=new int[4][4];
  for (int i=0; i<4; ++i) {
    for (int j=0; j<4; ++j) {
      if ((i==0||i==3)&&(j==0||j==3)) scoreFilter[i][j]=16;
      else if (i==0||i==3||j==0||j==3) scoreFilter[i][j]=4;
      else scoreFilter[i][j]=1;
    }
  }

  //jo=loadJSONObject("data/bestSoFar.json");
  //nn=networkFromJSON(jo);
  //b=new Board(nn);
  //b.beginGame();
  //b.show();
  //frameRate(3);

  background(0);

  p=new Population(500);
  p.calcGeneration();
}

Matrix matrixFromJSON(JSONObject json) {
  int rows=json.getInt("rows");
  int cols=json.getInt("cols");
  String s=json.getString("data");
  Scanner scan=new Scanner(s);
  float[][] data=new float[rows][cols];
  for (int i=0; i<rows; ++i) {
    for (int j=0; j<cols; ++j) {
      data[i][j]=scan.nextFloat();
    }
  }
  scan.close();
  return new Matrix(rows, cols, data);
}

//Single Hidden Layer
//Network networkFromJSON(JSONObject json) {
//  int numInputs=json.getInt("numInputs");
//  int numHiddens=json.getInt("numHiddens");
//  int numOutputs=json.getInt("numOutputs");
//  Matrix wih=matrixFromJSON(json.getJSONObject("weights_IH"));
//  Matrix who=matrixFromJSON(json.getJSONObject("weights_HO"));
//  Matrix bh=matrixFromJSON(json.getJSONObject("bias_H"));
//  Matrix bo=matrixFromJSON(json.getJSONObject("bias_O"));
//  return new Network(numInputs, numHiddens, numOutputs, wih, who, bh, bo);
//}

//Multi Hidden Layer
Network networkFromJSON(JSONObject json) {
  int numInputs=json.getInt("numInputs");
  int numOutputs=json.getInt("numOutputs");
  Matrix wih=matrixFromJSON(json.getJSONObject("weights_IH"));
  Matrix who=matrixFromJSON(json.getJSONObject("weights_HO"));
  Matrix bo=matrixFromJSON(json.getJSONObject("bias_O"));
  JSONArray hiddenLayers=json.getJSONArray("hiddenLayers");
  int len=hiddenLayers.size();
  int[] numHiddens=new int[len];
  Matrix[] bh=new Matrix[len];
  for (int i=0; i<len; ++i) {
    JSONObject hljson=hiddenLayers.getJSONObject(i);
    numHiddens[i]=hljson.getInt("numHiddens");
    bh[i]=matrixFromJSON(hljson.getJSONObject("bias_H"));
  }
  Matrix[] whh;
  if (len==1) whh=null;
  else {
    whh=new Matrix[len-1];
    JSONArray whharr=json.getJSONArray("weights_HH");
    for (int i=0; i<len-1; ++i) {
      whh[i]=matrixFromJSON(whharr.getJSONObject(i));
    }
  }
  return new Network(numInputs, numHiddens, numOutputs, wih, whh, who, bh, bo);
}

//void keyPressed() {
//  if (p.isOver() && keyCode == ' ') {
//    pause=!pause;
//    if (pause) noLoop();
//    else loop();
//  }
//}

//void keyPressed() {
//  if (b.gO==0 && keyCode == ' ') {
//    background(0);
//    b.move();
//    b.show();
//    b.calcScore();
//    text("score: "+b.score+"  Total Steps: "+b.totalSteps+"  Fake Steps: "+b.fakeSteps, 10, 350);
//  }
//}

void draw() {
  if (p.isOver()) {
    p.newGeneration();
    p.calcGeneration();
  }

  //if (b.gO==0) {
  //  background(0);
  //  b.move();
  //  b.show();
  //  b.calcScore();
  //  text("score: "+b.score+"  Total Steps: "+b.totalSteps+"  Fake Steps: "+b.fakeSteps, 10, 350);
  //}
}
