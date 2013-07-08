int rectSize = 7;
float glowSpeed = 8;
int widthInBoxes = 100;
int heightInBoxes = 80;
int [] cell = {};
int [] newcell = {};
int CELL_UPDATE_INTERVAL = 100;   // constrain within 0 to 20
int nextCellUpdate = 0;
boolean running = false;

Maxim maxim;
AudioPlayer player;
AudioPlayer player2;

void setup() {
  //size(widthInBoxes*rectSize, heightInBoxes*rectSize);
  size(700,560);
  maxim = new Maxim(this);
  player = maxim.loadFile("atmos1.wav");
  player.setLooping(true);
  player2 = maxim.loadFile("bells.wav");
  player2.setLooping(true);
  player.volume(0.25);

  background(0);
  rectMode(CENTER);
  noStroke();

  initCells();
  //run_tests();
}

void draw() {

  // Map mouse speed to alpha
  float speed = map(mouseX, 0, width, 2, 40);

  //live(floor(mouseY/rectSize),floor(mouseX/rectSize));
  if (running && (nextCellUpdate <= 0)) {
    updateCells();
    drawCells();
    nextCellUpdate = CELL_UPDATE_INTERVAL;
  } else {
    if (running)
      nextCellUpdate = nextCellUpdate - int(speed);
  } 
}

void mouseReleased(){
  running = true;
  player2.ramp(0.,1000);
}

void mouseDragged() {
  running = false;
  player.play();
  player2.play();

  // Map mouse position to colors
  float red = map(mouseX, 0, width, 0, 255);
  float blue = map(mouseY, 0, width, 0, 255);
  float green = dist(mouseX,mouseY,width/2,height/2);
  
  // Map mouse speed to alpha
  float speed = dist(pmouseX, pmouseY, mouseX, mouseY);
  float alpha = map(speed, 0, 20, 0, 10);

  // Fade background to black
  fill(0, alpha);
  rect(width/2, height/2, width, height);
  fill(red, green, blue, 255);

  live(floor(mouseY/rectSize),floor(mouseX/rectSize));

  player.setFilter((float) mouseY/height*5000,mouseX / width);
  //player2.setFilter((float) mouseY/height*5000,mouseX / width);
  
  player2.ramp(1.,1000);
  player2.speed((float) mouseX/width);
}

//********** GAME OF LIFE CODE **********

// Initialize all cells to dead
void initCells() {
  // Inititalize Game of Life
  for(int i = 0; i < widthInBoxes*heightInBoxes; i++) {
     cell = append(cell,0);
     newcell = append(newcell,0);
  }
}

// Reset all cells to dead
void wipeCells() {
  // Inititalize Game of Life
  for(int i = 0; i < widthInBoxes*heightInBoxes; i++)
     cell[i] = 0;
}

// Update cells according to the John Conway's Game of Life
// http://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
// http://rosettacode.org/wiki/Conway%27s_Game_of_Life
void updateCells() {
  int r,c;
  for(int i=0; i<cell.length; i++) {
    r = floor(i/widthInBoxes);
    c = i - r*widthInBoxes; 
    int n = numLiveNeighbours(r,c);
    if ((cell[i] == 1) && (n != 2) && (n != 3)) {
        //println("  @ r:"+r+" c:"+c+" i:"+i+" t0:1 n:"+n+" -> t1:0"); 
        newcell[i] = 0;
    } else if ((cell[i] == 0) && (n == 3)) {
        //println("  @ r:"+r+" c:"+c+" i:"+i+" t0:0 n:"+n+" -> t1:1"); 
        newcell[i] = 1;
    } else {
        newcell[i] = cell[i];
    }        
  }
  for(int i=0; i<cell.length; i++)
    cell[i] = newcell[i];
}

void drawCells() {
  int r,c;
  for(int i=0; i<cell.length; i++) {
    r = floor(i/widthInBoxes);
    c = i - r*widthInBoxes; 
    float red   = map(c, 0, widthInBoxes, 0, 255);
    float blue  = map(r, 0, heightInBoxes, 0, 255);
    float green = dist(c,r,widthInBoxes/2,heightInBoxes/2);
  
    if (cellIsAlive(r,c)) {
      //println("r:"+r+" c:"+c);      
      fill(red,blue,green);
      rect(c*rectSize+rectSize/2,r*rectSize+rectSize/2,rectSize-1,rectSize-1);
    } else {
      fill(0);
      rect(c*rectSize+rectSize/2,r*rectSize+rectSize/2,rectSize-1,rectSize-1);
    } 
  }
}

// Row, Column -> Int
// Given cell row and cell column, return number of neighbours which are alive
public int numLiveNeighbours(int row, int col) {
  int numLive = 0;
  //println("Checking row:"+row+" col:"+col);
  for(int r = row-1; r <= row+1; r++)
    for(int c = col-1; c <= col+1; c++)
      if ((c >= 0) && (c < widthInBoxes) && (r >= 0) && (r < heightInBoxes) &&
          !((c == col) && (r == row)))
        if (cellIsAlive(r,c)) {
          //println("r:"+r+" c:"+c+" is alive.");
          numLive++;
        }
  return numLive;
}

// Row, Column -> Void
// give birth to cell at row, col
void live(int row, int col) {
  if((row*widthInBoxes+col) < cell.length) {
    cell[row*widthInBoxes+col] = 1;
    rect(col*rectSize+rectSize/2,row*rectSize+rectSize/2,rectSize-1,rectSize-1);
  }
}

// Row, Column -> Void
// kill cell at row, col
void dead(int row, int col) {
  cell[row*widthInBoxes+col] = 0;
  //fill(0);
  //rect(col*rectSize+rectSize/2,row*rectSize+rectSize/2,rectSize-1,rectSize-1);
}

// Row, Column -> Boolean
// Given cell row and cell column, return whether cell is alive
//     cell is alive if its brightness is greater than or equal to 127
public boolean cellIsAlive(int row, int col) {
  //println("r:"+row+" c:"+col);
  return (cell[row*widthInBoxes+col] == 1);
}

//********** TEST CODE **********

void test_wipeCells() {
  println("test_wipeCells()");
  int count = 0;
  int i;
  for(i = 0; i < widthInBoxes*heightInBoxes; i++)
     count = cell[i];
  assertTrue(count == 0,"Boxes:"+i+" Exp:0 Got:"+count);
  println("  Boxes:"+i+" Count:"+count);
}

void test_cellIsAlive() {
  println("test_cellIsAlive()");
  boolean act, exp;
  int r,c;

  wipeCells();

  r=1; c=1; live(r,c);
  act = cellIsAlive(r,c);
  exp = true;
  assertTrue(act == exp,"Expect:"+exp+" Got:"+act);
  println("  Cells Alive:1 Got:"+liveCells(cell));

  r=10; c=5; live(r,c);
  act = cellIsAlive(r,c);
  exp = true;
  assertTrue(act == exp,"Expect:"+exp+" Got:"+act);
  println("  Cells Alive:2 Got:"+liveCells(cell));
  
  r=10; c=12; dead(r,c);
  act = cellIsAlive(r,c);
  exp = false;
  assertTrue(act == exp,"Expect:"+exp+" Got:"+act);  

  r=0; c=2;
  act = cellIsAlive(r,c);
  exp = false;
  assertTrue(act == exp,"Expect:"+exp+" Got:"+act);  

  println("  Cells Alive:2 Got:"+liveCells(cell));
  wipeCells();
}

public int liveCells(int [] cell) {
  int count = 0;
  for(int i = 0; i < cell.length; i++)
    count += cell[i];
  return count;
}

void test_numLiveNeighbours() {
  println("test_numLiveNeighbours()");
  int act, exp;

  wipeCells();
  live(0,0);
  live(0,1);
  live(1,0);
  live(1,1);
  act = numLiveNeighbours(0,0);
  exp = 3;
  assertTrue(act == exp,"Expect:"+exp+" Got:"+act);
  act = numLiveNeighbours(1,1);
  exp = 3;
  assertTrue(act == exp,"Expect:"+exp+" Got:"+act);
  act = numLiveNeighbours(2,2);
  exp = 1;
  assertTrue(act == exp,"Expect:"+exp+" Got:"+act);

  println("  Cells Alive:4 Got:"+liveCells(cell));
  wipeCells();
}

void test_updateCells() {
  println("test_updateCells()");
  boolean b;

  wipeCells();
  live(0,0);
  live(0,1);
  live(0,2);
  updateCells();  
  b = cellIsAlive(0,0); 
  assertTrue(b == false,"  t1 - Exp:false Act:"+b);
  b = cellIsAlive(0,1); 
  assertTrue(b == true,"  t2 - Exp:true Act:"+b);
  b = cellIsAlive(0,2); 
  assertTrue(b == false,"  t3 - Exp:false Act:"+b);
  b = cellIsAlive(1,0); 
  assertTrue(b == false,"  t4 - Exp:false Act:"+b);
  b = cellIsAlive(1,1); 
  assertTrue(b == true,"  t5 - Exp:true Act:"+b);
  b = cellIsAlive(1,2); 
  assertTrue(b == false,"  t6 - Exp:false Act:"+b);

  println("  Cells Alive:2 Got:"+liveCells(cell));
  wipeCells();
}

void test_drawCells() {
  println("test_drawCells()");
  wipeCells();
  live(29,30);
  live(25,30);
  drawCells();
  println("  Cells Alive:2 Got:"+liveCells(cell));
  wipeCells();
  println("  Cells Alive:0 Got:"+liveCells(cell));
  drawCells();
}

void run_tests(){
  test_wipeCells();
  test_cellIsAlive();
  test_numLiveNeighbours();
  test_updateCells();
  test_drawCells();
  println("done testing.");
  //exit();
}

public void assertTrue(boolean condition,String msg) {
  if (!condition) {
    println(msg);
  }
}

