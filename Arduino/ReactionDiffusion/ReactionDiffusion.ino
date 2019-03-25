const byte WIDTH = 24;
const byte HEIGHT = 16;

const byte ACTIVATOR = 50;
const byte INHIBITOR = 20;
const byte SMALL_AMOUNT = 5;

int8_t sat[WIDTH * HEIGHT],
       activator[WIDTH * HEIGHT],
       inhibitor[WIDTH * HEIGHT],
       result[WIDTH * HEIGHT];

int i;
int8_t maxV, minV, x, y;

unsigned long lastPrint = 0;

void setup() {
  Serial.begin(57600);
  Serial.println(F("Starting...."));

  for (i = 0; i < WIDTH * HEIGHT; i++) {
    result[i] = random(-127, 127);
  }
}

void averageSolutions() {
  // summed-area table
  for (y = 1; y < HEIGHT; y++) {
    for (x = 1, i = y * WIDTH + x; x < WIDTH; x++, i++) {
      sat[i] = result[i] + sat[i - 1] + sat[i - WIDTH] - sat[i - WIDTH - 1];
    }
  }

  // have sums. get averages.
  for (y = 0; y < HEIGHT; y++) {
    for (x = 0, i = y * WIDTH + x; x < WIDTH; x++, i++) {
      byte minxA = max(0, x - ACTIVATOR);
      byte maxxA = min(x + ACTIVATOR, WIDTH - 1);
      byte minyA = max(0, y - ACTIVATOR);
      byte maxyA = min(y + ACTIVATOR, HEIGHT - 1);
      int areaA = (maxxA - minxA) * (maxyA - minyA);

      byte minxI = max(0, x - INHIBITOR);
      byte maxxI = min(x + INHIBITOR, WIDTH - 1);
      byte minyI = max(0, y - INHIBITOR);
      byte maxyI = min(y + INHIBITOR, HEIGHT - 1);
      int areaI = (maxxI - minxI) * (maxyI - minyI);

      activator[i] = (sat[maxyA * WIDTH + maxxA] + sat[minyA * WIDTH + minxA] - sat[minyA * WIDTH + maxxA] - sat[maxyA * WIDTH + minxA]) / areaA;
      inhibitor[i] = (sat[maxyI * WIDTH + maxxI] + sat[minyI * WIDTH + minxI] - sat[minyI * WIDTH + maxxI] - sat[maxyI * WIDTH + minxI]) / areaI;
    }
  }
}


void updateResult() {
  maxV = 0, minV = 0;
  for (i = 0; i < WIDTH * HEIGHT; i++) {
    result[i] += (activator[i] > inhibitor[i]) ? SMALL_AMOUNT : -SMALL_AMOUNT;
    maxV = (result[i] > maxV) ? result[i] : maxV;
    minV = (result[i] < minV) ? result[i] : minV;
  }

  for (i = 0; i < WIDTH * HEIGHT; i++) {
    result[i] = map(result[i], minV, maxV, -127, 127);
  }
}

void printsAndLed() {
  if (millis() - lastPrint > 1000) {
    lastPrint = millis();
    Serial.println(lastPrint);
  }
  digitalWrite(13, (millis() / 500) % 2);
}

void loop() {
  averageSolutions();
  updateResult();
  printsAndLed();
}

