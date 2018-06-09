class Board {
  int gO;
  // gO = -1 -> GAME OVER
  // gO = 0  -> PLAYING...
  // gO = 1  -> WON THE GAME
  // gO = 2  -> START OF THE GAME
  int totalSteps;
  int score;
  float fitness;
  int field[][];
  int fakeSteps;
  Network nn;

  Board() {
    gO = 2;
    fitness=0;
    field = new int[4][4];
    totalSteps=0;
    fakeSteps=0;
    score=0;
    for (int i=0; i<4; ++i)
      for (int j=0; j<4; ++j) {
        field[i][j] = -1;
      }
    int[] hl={20, 16, 10};
    nn=new Network(16, hl, 4);
  }

  Board(Network n) {
    gO = 2;
    fitness=0;
    field = new int[4][4];
    totalSteps=0;
    fakeSteps=0;
    score=0;
    for (int i=0; i<4; ++i)
      for (int j=0; j<4; ++j) {
        field[i][j] = -1;
      }
    nn=n;
  }

  int isGameOver() {
    for (int i=0; i<4; ++i)
      for (int j=0; j<4; ++j) {
        if (field[i][j] >= 10)
          return 1;
      }
    if (!moveUp(false) && !moveDown(false) && !moveLeft(false) && !moveRight(false))
      return -1;
    return 0;
  }

  int getMaxTile() {
    int max=-1;
    for (int i=0; i<4; ++i) {
      for (int j=0; j<4; ++j) {
        if (max<field[i][j]) max=field[i][j];
      }
    }
    return max;
  }

  void createTile() {
    int x=int(random(0, 4));
    int y=int(random(0, 4));
    while (field[x][y]!=-1) {
      x=int(random(0, 4));
      y=int(random(0, 4));
    }
    float ch = random(0, 1);
    int val;
    if (ch<0.2) {
      val = 1;
    } else {
      val = 0;
    }
    field[x][y] = val;
  }

  void beginGame() {
    totalSteps=0;
    fakeSteps=0;
    for (int i=0; i<4; ++i)
      for (int j=0; j<4; ++j) {
        field[i][j] = -1;
      }
    createTile();
    createTile();
    gO = 0;
  }

  float[] getFlat() {
    float[] ans=new float[16];
    int top=0;
    for (int i=0; i<4; ++i) {
      for (int j=0; j<4; ++j) {
        ans[top++]=(float)field[i][j]/10;
      }
    }
    return ans;
  }

  int getMax(float[] x, boolean[] val) {
    int ans=-1;
    float max=-1000;
    for (int i=0; i<4; ++i) {
      if (val[i] && max<x[i]) {
        max=x[i];
        ans=i;
      }
    }
    return ans;
  }

  void calcScore() {
    score=0;
    for (int x=0; x<4; ++x) {
      for (int y=0; y<4; ++y) {
        if (field[x][y]==-1) score+=10;
        else score+=(field[x][y]+1)*pow(2, field[x][y]+1);
        if (field[x][y]==10) score+=10000;
      }
    }
  }

  void show() {
    imageMode(CORNER);
    for (int x=0; x<4; ++x) {
      for (int y=0; y<4; ++y) {
        float xx = (x*sizeOfTile) + ((x+1)*offset);
        float yy = (y*sizeOfTile) + ((y+1)*offset);
        if (field[x][y] == -1) {
          image(emptyTile, xx, yy, sizeOfTile, sizeOfTile);
        } else {
          image(tiles[field[x][y]], xx, yy, sizeOfTile, sizeOfTile);
        }
      }
    }
  }

  boolean move(int dir) {
    boolean isMove=false;
    switch(dir) {
    case 0:
      isMove=moveUp(true);
      break;
    case 1:
      isMove=moveDown(true);
      break;
    case 2:
      isMove=moveLeft(true);
      break;
    case 3:
      isMove=moveRight(true);
      break;
    }
    return isMove;
  }

  boolean[] getValidMoves() {
    boolean[] val=new boolean[4];
    val[0]=moveUp(false);
    val[1]=moveDown(false);
    val[2]=moveLeft(false);
    val[3]=moveRight(false);
    return val;
  }

  void showMove(int dir, boolean flag) {
    float x=(3*width)/4;
    float y=height/2;
    switch(dir) {
    case 0:
      y-=100;
      break;
    case 1:
      y+=100;
      break;
    case 2:
      x-=100;
      break;
    case 3:
      x+=100;
      break;
    }
    ellipse(x, y, 50, 50);
    if (!flag) {
      fill(255, 0, 0);
      ellipse(x, y, 10, 10);
      fill(255);
    }
  }

  void move() {
    float[] input=getFlat();
    float[] output=nn.predict(input);
    int guess=getMax(output, getValidMoves());
    boolean isMove=false;
    if (guess>=0) {
      isMove=move(guess);
    }
    if (guess==-1) {
      isMove=false;
      gO=-1;
      return;
    }
    //showMove(guess, isMove);
    //boolean fake=false;
    //while (!isMove) {
    //  int r=(int)random(4);
    //  isMove=move(r);
    //  fake=true;
    //}
    //if (fake) fakeSteps++;
    totalSteps++;
    if (isMove) createTile();
    gO=isGameOver();
  }



  boolean moveUp(boolean move) {
    boolean ans=false;
    for (int i=0; i<4; ++i) {
      int newl[] = new int[4];
      int topl=0;
      for (int j=0; j<4; ++j) {
        if (field[i][j]>-1) newl[topl++]=field[i][j];
      }
      int ns=0, ni=0;
      while (ni<topl-1) {
        if (newl[ni]==newl[ni+1]) {
          newl[ns]=newl[ni]+1;
          ni++;
        } else newl[ns]=newl[ni];
        ni++;
        ns++;
      }
      if (ni==topl-1) {
        newl[ns]=newl[ni];
        ns++;
      }
      for (int j=ns; j<topl; ++j) newl[j]=-1;
      while (topl<4) newl[topl++]=-1;
      for (int j=0; j<4; ++j) {
        if (newl[j]!=field[i][j]) {
          ans=true;
          if (move) field[i][j]=newl[j];
        }
      }
    }
    return ans;
  }

  boolean moveDown(boolean move) {
    boolean ans=false;
    for (int i=0; i<4; ++i) {
      int newl[] = new int[4];
      int topl=0;
      for (int j=3; j>=0; --j) {
        if (field[i][j]>-1) newl[topl++]=field[i][j];
      }
      int ns=0, ni=0;
      while (ni<topl-1) {
        if (newl[ni]==newl[ni+1]) {
          newl[ns]=newl[ni]+1;
          ni++;
        } else newl[ns]=newl[ni];
        ni++;
        ns++;
      }
      if (ni==topl-1) {
        newl[ns]=newl[ni];
        ns++;
      }
      for (int j=ns; j<topl; ++j) newl[j]=-1;
      while (topl<4) newl[topl++]=-1;
      for (int j=0; j<4; ++j) {
        if (newl[3-j]!=field[i][j]) {
          ans=true;
          if (move) field[i][j]=newl[3-j];
        }
      }
    }
    return ans;
  }

  boolean moveLeft(boolean move) {
    boolean ans=false;
    for (int i=0; i<4; ++i) {
      int newl[] = new int[4];
      int topl=0;
      for (int j=0; j<4; ++j) {
        if (field[j][i]>-1) newl[topl++]=field[j][i];
      }
      int ns=0, ni=0;
      while (ni<topl-1) {
        if (newl[ni]==newl[ni+1]) {
          newl[ns]=newl[ni]+1;
          ni++;
        } else newl[ns]=newl[ni];
        ni++;
        ns++;
      }
      if (ni==topl-1) {
        newl[ns]=newl[ni];
        ns++;
      }
      for (int j=ns; j<topl; ++j) newl[j]=-1;
      while (topl<4) newl[topl++]=-1;
      for (int j=0; j<4; ++j) {
        if (newl[j]!=field[j][i]) {
          ans=true;
          if (move) field[j][i]=newl[j];
        }
      }
    }
    return ans;
  }

  boolean moveRight(boolean move) {
    boolean ans=false;
    for (int i=0; i<4; ++i) {
      int newl[] = new int[4];
      int topl=0;
      for (int j=3; j>=0; --j) {
        if (field[j][i]>-1) newl[topl++]=field[j][i];
      }
      int ns=0, ni=0;
      while (ni<topl-1) {
        if (newl[ni]==newl[ni+1]) {
          newl[ns]=newl[ni]+1;
          ni++;
        } else newl[ns]=newl[ni];
        ni++;
        ns++;
      }
      if (ni==topl-1) {
        newl[ns]=newl[ni];
        ns++;
      }
      for (int j=ns; j<topl; ++j) newl[j]=-1;
      while (topl<4) newl[topl++]=-1;
      for (int j=0; j<4; ++j) {
        if (newl[3-j]!=field[j][i]) {
          ans=true;
          if (move) field[j][i]=newl[3-j];
        }
      }
    }
    return ans;
  }
}
