// following this, but only using 1 level:
//    http://softologyblog.wordpress.com/2011/07/05/multi-scale-turing-patterns/

// for holding the reaction components
float[] activator, inhibitor, result;

// parameters
int ACTIVATOR = 30;
int INHIBITOR = 70;
float SMALL_AMOUNT = 0.05;

void setup() {
  size(800, 600);
  result = new float[width*height];
  activator = new float[width*height];
  inhibitor = new float[width*height];

  // initial random values for solution
  for (int i=0; i<width*height; i++) {
    result[i] = random(-1, 1);
  }
}

// average the solution into inhibitor and activator arrays
void averageSolutions() {
  // summed-area table
  float[] sat = new float[width*height];
  for (int y=1; y<height; y++) {
    for (int x=1,i=y*width+x; x<width; x++,i++) {
      sat[i] = result[i] + sat[i-1] + sat[i-width] - sat[i-width-1];
    }
  }

  // have sums. get averages.
  for (int y=0; y<height; y++) {
    for (int x=0,i=y*width+x; x<width; x++,i++) {
      int minxA = max(0, x-ACTIVATOR);
      int maxxA = min(x+ACTIVATOR, width-1);
      int minyA = max(0, y-ACTIVATOR);
      int maxyA = min(y+ACTIVATOR, height-1);
      int areaA = (maxxA-minxA)*(maxyA-minyA);

      int minxI = max(0, x-INHIBITOR);
      int maxxI = min(x+INHIBITOR, width-1);
      int minyI = max(0, y-INHIBITOR);
      int maxyI = min(y+INHIBITOR, height-1);
      int areaI = (maxxI-minxI)*(maxyI-minyI);

      activator[i] = (sat[maxyA*width+maxxA] + sat[minyA*width+minxA] - sat[minyA*width+maxxA] - sat[maxyA*width+minxA])/areaA;
      inhibitor[i] = (sat[maxyI*width+maxxI] + sat[minyI*width+minxI] - sat[minyI*width+maxxI] - sat[maxyI*width+minxI])/areaI;
    }
  }
}


void updateResult() {
  // compute the new result while tracking max and min values
  float maxV=0, minV=0;
  for (int i=0;i<width*height;i++) {
    result[i] += (activator[i] > inhibitor[i])?SMALL_AMOUNT:-SMALL_AMOUNT;
    maxV = (result[i] > maxV)?result[i]:maxV;
    minV = (result[i] < minV)?result[i]:minV;
  }

  // scale result to [-1,1] and loadPixels into display buffer
  loadPixels();
  for (int i=0;i<width*height;i++) {
    result[i] = map(result[i], minV, maxV, -1, 1);
    pixels[i] = color(result[i]*127+128);
  }
  updatePixels();
}

void draw() {
  averageSolutions();
  updateResult();
  if (frameCount%100 == 1) {
    println(frameRate);
  }

  // sensors
  //ACTIVATOR = (int)(ACTIVATOR*0.9 + map(mouseX, 0, width, 10, 80)*0.1);
  //INHIBITOR = (int)(INHIBITOR*0.9 + map(mouseY, height, 0, 10, 80)*0.1);
}

void mouseDragged() {
  for (int y = mouseY-INHIBITOR/2; y<mouseY+INHIBITOR/2; y++) {
    for (int x = mouseX-INHIBITOR/2; x<mouseX+INHIBITOR/2; x++) {
      if ((y>-1)&&(x>-1)&&(x<width)&&(y<height) && (abs(dist(mouseX, mouseY, x, y))<INHIBITOR/2)) {
        result[y*width+x] = (mouseButton==LEFT)?1:-1;
      }
    }
  }
}

