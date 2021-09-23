/*
  Button LED

  This example creates a BLE peripheral with service that contains a
  characteristic to control an LED and another characteristic that
  represents the state of the button.

  The circuit:
  - Arduino MKR WiFi 1010, Arduino Uno WiFi Rev2 board, Arduino Nano 33 IoT,
    Arduino Nano 33 BLE, or Arduino Nano 33 BLE Sense board.
  - Button connected to pin 4

  You can use a generic BLE central app, like LightBlue (iOS and Android) or
  nRF Connect (Android), to interact with the services and characteristics
  created in this sketch.

  This example code is in the public domain.
*/

#include <ArduinoBLE.h>


BLEService HubService("19B10010-E8F2-537E-4F6C-D104768A1214"); // create service


int btn = 4;
int presses = 0;
int buttonValue = 0;

// create button characteristic and allow remote device to get notifications
BLEByteCharacteristic HubCharacteristic("19B10012-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify);
// buttonCharacteristic
void setup() {
  Serial.begin(9600);
  while (!Serial);
  
  pinMode(btn, INPUT);
  
  // begin initialization
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");
    while (1);
  }

  // set the local name peripheral advertises
  BLE.setLocalName("HubOmeter");
  // set the UUID for the service this peripheral advertises:
  BLE.setAdvertisedService(HubService);

  HubService.addCharacteristic(HubCharacteristic);

  // add the service
  BLE.addService(HubService);

  HubCharacteristic.writeValue(0);

  // start advertising
  BLE.advertise();

  Serial.println("Bluetooth device active, waiting for connections...");
}

void loop() {
  // poll for BLE events
  BLE.poll();
  buttonValue = digitalRead(btn);

  // has the value changed since the last read
  boolean buttonChanged = (HubCharacteristic.value() != buttonValue);

  if (buttonChanged) {
    presses = presses + 1;
    HubCharacteristic.writeValue(presses);
  }
}
