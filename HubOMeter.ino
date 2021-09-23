/*
 * Dit is het main bestand met de setup en loop functie deze geld voor ons beiden
 */

void setup() {
  // Zorgen dat we output hebben op de setial monitor
  Serial.begin(115200);
  while (!Serial);

  BluetoothSetup();
  //PakeerSetup();
}

void loop() {
  BluetoothLoop();
  //PakeerLoopThuis();
}
