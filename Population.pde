class Population {
  Board[] pop;
  int size;
  int gen=1;
  Board bestSoFar;
  PrintWriter generationData;
  int bestGen=1;

  Population(int len) {
    size=len;
    pop=new Board[len];
    for (int i=0; i<len; ++i) {
      pop[i]=new Board();
    }
    bestSoFar=pop[0];
    generationData=createWriter("data/generationData.txt");
  }

  void beginGames() {
    for (Board b : pop) {
      b.beginGame();
    }
  }

  void show() {
    for (Board b : pop) {
      b.show();
    }
  }

  boolean isOver() {
    for (Board b : pop) {
      if (b.gO==0) return false;
    }
    return true;
  }

  void calcFitnesses() {
    int sum=0;
    for (Board b : pop) {
      b.calcScore();
      sum+=exp(b.score/2000);
    }
    for (Board b : pop) {
      b.fitness=(float)exp(b.score/2000)/sum;
    }
  }

  Board getBest() {
    Board b = pop[0];
    for (Board brd : pop) {
      if (brd.score>b.score) {
        b=brd;
      }
    }
    return b;
  }

  void move() {
    for (Board b : pop) {
      if (b.gO==0) {
        b.move();
      }
    }
  }

  Board pickOne() {
    float r=random(1);
    int index=0;
    while (r>0) {
      r-=pop[index].fitness;
      index++;
    }
    index--;
    return pop[index];
  }

  void newGeneration() {
    Board[] newPop=new Board[size];
    for (int i=0; i<size; ++i) {
      Board temp=pickOne();
      Network n=temp.nn.mutate(0.1);
      temp=new Board(n);
      newPop[i]=temp;
    }
    pop=newPop;
    gen++;
  }

  void calcGeneration() {
    beginGames();
    while (!isOver()) {
      move();
    }
    calcFitnesses();
    Board b=getBest();
    if (b.score>bestSoFar.score) {
      bestSoFar=b;
      bestGen=gen;
    }
    background(0);
    b.show();
    textAlign(LEFT);
    textSize(12);
    text("score: "+b.score+"  Total Steps: "+b.totalSteps, 10, 350);
    textSize(15);
    textAlign(CENTER);
    text("Generation: "+gen, width/2, 390);
    pushMatrix();
    translate(350, 0);
    bestSoFar.show();
    textSize(12);
    text("gen: "+bestGen+" score: "+bestSoFar.score+"  Total Steps: "+bestSoFar.totalSteps, 175, 350);
    popMatrix();
    println(b.score+"  "+b.totalSteps);
    JSONObject json=bestSoFar.nn.getJSON();
    saveJSONObject(json, "data/bestSoFar.json");
    generationData.println(b.score+"  "+b.totalSteps+" "+b.getMaxTile());
    generationData.flush();
  }
}
