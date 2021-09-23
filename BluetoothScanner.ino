/*
  Dit is het bestand voor Olivier om de bluetooth scanner aan toe te voegen  
*/

#include <ArduinoBLE.h>
#include <stdio.h>
#include <string.h>

int maxi = 10;

class Device {
  public:
    int rssi;
    String address;

    int inHub() {
      return rssi < 200;
    }
};

// OLD: Device devices[10];
Device* devices = new Device[maxi];

// This is for indexing the array
int count = 0;
int FoundDeviceIndex;

void BluetoothSetup() {


  // begin met bluetooth initialization
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");
 
    while (1);
  }

  Serial.println("BLE Central scan");
  
  // start scanning for peripheral
  BLE.scan();
}

void BluetoothLoop() {
  // check if a peripheral has been discovered
  BLEDevice peripheral = BLE.available();
  
  if (peripheral) {
    Serial.print("The count is: ");
    Serial.println(count);
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
    Serial.print("Finding: ");
    Serial.println(findingDevice.address);
    for (int i = 0; i < count; i++) {
       if (devices[i].address == findingDevice.address) {
           Serial.println("Found device");
           FoundDeviceIndex = i;
           break;
        }
    } 
    Serial.println("Didn't find device");
    FoundDeviceIndex =  NULL;

    
    if (FoundDeviceIndex != NULL) {
      Serial.print("Found device with RSSI: ");
      Serial.println(peripheral.rssi());
      devices[FoundDeviceIndex].rssi = peripheral.rssi();
      Serial.println();
    } else {
      // Devcies is not indexed yet so indexing 
      Serial.print("The amount of the devices: ");
      Serial.println(count);
      if (count > maxi) {
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

      // print the RSSI
      Serial.print("RSSI: ");
      Serial.println(peripheral.rssi());  
      Serial.println();
      count++;
      devices[count+1] = TheDevice;
      
    }
  }
}
