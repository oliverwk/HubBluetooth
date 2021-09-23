
#include <ArduinoBLE.h>


BLEService HubService("19B10010-E8F2-537E-4F6C-D104768A1214"); // create service

BLEByteCharacteristic HubCharacteristic("19B10012-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify);

int maxi = 10;

int count = 0;
int* rssis = new int[maxi];

void setup() {
  Serial.begin(9600);
  while (!Serial);

  // begin initialization
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");
    while (1);
  }

  Serial.println("Scanning...");
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
  // start scanning for peripheral
  BLE.scan();
  Serial.println("Scanning");
}

void loop() {
  // check if a peripheral has been discovered
  BLE.poll();
  BLEDevice peripheral = BLE.available();

  if (peripheral) {
    // Found a peripheral
    Serial.println("Found a new peripheral");
    if (count > maxi) {
         Serial.println("Too much devices so making him bigger");
         maxi = maxi * 2;            // double the previous size
         int* temp = new int[maxi]; // create new bigger array.
         for (int i = 0; i < maxi/2; i++) {
                  temp[i] = rssis[i];       // copy values to new array.
         }
         delete [] rssis;              // free old array memory.
         rssis = temp;                 // now a points to new array.
    }
      
    Serial.print("Address: ");
    Serial.println(peripheral.address());

    Serial.print("RSSI: ");
    Serial.println(peripheral.rssi());
    Serial.println();
    
    rssis[count+1] = peripheral.rssi();
    count++;
    HubCharacteristic.writeValue(count);
  }
}
