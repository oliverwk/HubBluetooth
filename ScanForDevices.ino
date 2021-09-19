/*
  Scan

  This example scans for BLE peripherals and prints out their advertising details:
  address, local name, advertised service UUID's.

  The circuit:
  - Arduino MKR WiFi 1010, Arduino Uno WiFi Rev2 board, Arduino Nano 33 IoT,
    Arduino Nano 33 BLE, or Arduino Nano 33 BLE Sense board.

  This example code is in the public domain.
*/

#include <ArduinoBLE.h>
#include <stdio.h>
#include <string.h>

        
class Device {
  public:
    String name; // deze optinal maken
    int rssi;
    String address;

    int inHub() {
      return rssi < 200;
    }
};

// 
int maxi = 10;

// Devices array
int FoundDeviceIndex;


// OLD: Device devices[10];
Device* devices = new Device[maxi];

// This is for indexing the array
int count = 0;

void setup() {
  Serial.begin(115200);
  while (!Serial);

  // begin initializationm
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");
 
    while (1);
  }

  Serial.println("BLE Central scan");
  
  // start scanning for peripheral
  BLE.scan();
}

void loop() {
  // check if a peripheral has been discovered
  BLEDevice peripheral = BLE.available();

  if (peripheral) {
    Serial.print("Devices: \n");
    for (int i = 0; i < count; i++) {
      Serial.print("rssi: ");
      Serial.print(devices[i].rssi);
      Serial.print(" and address: ");
      Serial.print(devices[i].address);
      Serial.print("\n");
    }
    // discovered a peripheral
    Serial.println("Discovered a peripheral");
    Serial.println("-----------------------");

    // print address
    Serial.print("Address: ");
    Serial.println(peripheral.address());
    Device findingDevice;
    findingDevice.rssi = peripheral.rssi();
    findingDevice.address = peripheral.address();
    FoundDeviceIndex = find(findingDevice);

    if (FoundDeviceIndex != NULL) {
      Serial.print("Found device with RSSI: ");
      Serial.println(peripheral.rssi());
      devices[FoundDeviceIndex].rssi = peripheral.rssi();
      Serial.println();
    } else {
      // Devcies is not indexed yet so indexing 
      Serial.print("The amount of the devices: ");
      Serial.println(count);
      if (count > sizeof(devices)) {
         Serial.println("Too much devices so making him bigger");
         maxi = maxi * 2;            // double the previous size
         Device* temp = new Device[maxi]; // create new bigger array.
         for (int i = 0; i < maxi/2; i++) {
                  temp[i] = devices[i];       // copy values to new array.
         }
         delete [] devices;              // free old array memory.
         devices = temp;                 // now a points to new array.
      }

      Device TheDevice;
      TheDevice.rssi = peripheral.rssi();
      TheDevice.address = peripheral.address();

      // add the local name, if present
      if (peripheral.hasLocalName()) {
        Serial.print("Local Name: ");
        Serial.println(peripheral.localName());
        TheDevice.name = peripheral.localName();
      } else {
        TheDevice.name = "";
      }
      // print the RSSI
      Serial.print("RSSI: ");
      Serial.println(peripheral.rssi());  
      Serial.println();
      count++;
      devices[count+1] = TheDevice;
    }
  }
}

int find(Device TheDevice) {
  Serial.print("Finding: ");
  Serial.println(TheDevice.name ? TheDevice.address : TheDevice.name);
  for (int i = 0; i < count; i++) {
    Serial.println(i);
   if (devices[i].address == TheDevice.address) {
     Serial.println("Found device");
     return i;
   //  break;
   }
  } 
  Serial.println("Didn't find device");
  return NULL;
}
