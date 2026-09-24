#include <Arduino.h>

void setup() {
  Serial.begin(115200);
  while (!Serial) { delay(10); }
  Serial.println("Base ROM Measurement");
}
void loop() {}