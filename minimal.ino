/*
  Dit is het bestand voor Olivier om de bluetooth scanner aan toe te voegen
*/

#include <ArduinoBLE.h>

int maxi = 150;

class Device {
  public:
    int rssi;
    String address;

    int inHub() {
      return rssi > -20;
    }
};


Device* devices = new Device[maxi];

// This is for indexing the array
int count = 0;
int FoundDeviceIndex;


BLEService HubService("19B10010-E8F2-537E-4F6C-D104768A1214"); // create service
BLEByteCharacteristic HubCharacteristic("19B10012-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify);

void setup() {
  Serial.begin(9600);
  while (!Serial);
  pinMode(LED_BUILTIN, OUTPUT);

  // begin met bluetooth initialization
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");

    while (1);
  }
  BLE.setLocalName("HubOmeter");
  BLE.setAdvertisedService(HubService);

  HubService.addCharacteristic(HubCharacteristic);

  BLE.addService(HubService);

  HubCharacteristic.writeValue(1);

  BLE.advertise();

  Serial.println("Starting scan");

  // start scanning for peripheral
  BLE.scan();
  
  // Scan for een batterij uuid zodat het alleen ipads zijn
  // TOOD: BLE.scanForUuid("180F");
}

void loop() {
  // check if a peripheral has been discovered
  digitalWrite(LED_BUILTIN, HIGH);
  BLEDevice peripheral = BLE.available();

  if (peripheral) {
    Serial.print("The count is: ");
    Serial.println(count);
    Serial.print("Devices: \n");
    for (int i = 0; i < count; i++) {
      Serial.print(i);
      Serial.print(" ");
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
    Device d;
    d.rssi = peripheral.rssi();
    d.address = peripheral.address();
    Serial.print("Finding: ");
    Serial.println(d.address);
    for (int i = 0; i < count; i++) {
      if (devices[i].address == peripheral.address()) {
        Serial.println("Found device");
        FoundDeviceIndex = i;
        break;
      }
    }
    if (FoundDeviceIndex != (float)(int)FoundDeviceIndex) {
      Serial.println("Didn't find device");
      FoundDeviceIndex = NULL;
    }

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
        maxi = maxi + 10;            // double the previous size
        Device* temp = new Device[maxi]; // create new bigger array.
        for (int i = 0; i < maxi - 10; i++) {
          temp[i] = devices[i];       // copy values to new array.
        }
        delete [] devices;              // free old array memory.
        devices = temp;                 // now a point to the new array.
      }
    // print the advertised service UUIDs, if present
      if (peripheral.hasAdvertisedServiceUuid()) {
        Serial.print("Service UUIDs: ");
        for (int l = 0; l < peripheral.advertisedServiceUuidCount(); l++)  {
          Serial.print("uuid: ");
          Serial.println(peripheral.advertisedServiceUuid());
          // Voeg alleen toe als het de tijd uuid heeft dan is het wrs een ipad
          if (peripheral.advertisedServiceUuid(l) == "180F") {
              d.rssi = peripheral.rssi();
              d.address =  peripheral.address() ? peripheral.address() : "WTF IS HAPPING";        
              // print the RSSI
              Serial.print("RSSI: ");
              Serial.println(peripheral.rssi());
              count++;
              devices[count + 1] = d;
              Serial.print("Writing the value to ble: ");
              Serial.print(count - 1);
              HubCharacteristic.writeValue(count - 1); // Want je begint met nul bij tellen en er is nog een bug
          }
        }
        Serial.println();
      }
     }
  }
  digitalWrite(LED_BUILTIN, LOW);
}
