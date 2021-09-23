import SwiftUI
import Foundation
import UIKit
import CoreBluetooth

class BLEConnection: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate, ObservableObject {

  private var centralManager: CBCentralManager! = nil
  private var peripheral: CBPeripheral!

  public static let bleServiceUUID = CBUUID.init(string: "19B10010-E8F2-537E-4F6C-D104768A1214")
  public static let bleCharacteristicUUID = CBUUID.init(string: "19B10012-E8F2-537E-4F6C-D104768A1214")


  // Array to contain names of BLE devices to connect to.
  // Accessable by ContentView for Rendering the SwiftUI Body on change in this array.
  @Published var NumPeople: Int


  func startCentralManager() {
    self.centralManager = CBCentralManager(delegate: self, queue: nil)
    print("Central Manager State: \(self.centralManager.state)")
  }

  // Handles BT Turning On/Off
  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
      if central.state == .poweredOn {
          central.scanForPeripherals(withServices: [bleServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
          print("Scanning...")
      } else {
        print("HELPPPPPPPPPP")
      }
    }

  // Handles the result of the scan
  public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    guard peripheral.name != nil else { return }
    logger.log("peripheral name: \(peripheral.name, privacy: .public)")
     if peripheral.name == "HubOmeter" {
        print("Arduino Found!")
        self.centralManager.stopScan()
        self.centralManager.connect(peripheral, options: nil)
        self.peripheral = peripheral
        self.peripheral.delegate = self
    }
  }


  // The handler if we do connect successfully
  public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    if peripheral == self.peripheral {
      print("Connected to the HubOmeter")
      peripheral.discoverServices([BLEConnection.bleServiceUUID])
      //peripheral.discoverServices(nil)
    }
  }


  // Handles discovery event
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    if let services = peripheral.services {
      for service in services {
        print("Found services UUID: \(service.uuid), uuidstring:\(service.uuid.uuidString)")

        if service.uuid == BLEConnection.bleServiceUUID {
          print("BLE Service found")
          // find the good chars
          peripheral.discoverCharacteristics([BLEConnection.bleCharacteristicUUID], for: service)
          return
        }
      }
    }
  }

  // Handling discovery of characteristics
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    if let characteristics = service.characteristics {
      for characteristic in characteristics {
        let uuidString = characteristic.uuid.uuidString
        print("The Characteristic: \(uuidString)")
        print(characteristic)
        peripheral.setNotifyValue(true, for: characteristic)

        if characteristic.uuid == BLEConnection.bleCharacteristicUUID {
            print("BLE service characteristic \(BLEConnection.bleCharacteristicUUID) found")
            self.NumPeople = peripheral.readValue(for: characteristic)
        } else {
            print("Characteristic not found.")
        }
      }
    }
  }


  public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

    if characteristic.uuid.uuidString == "19B10012-E8F2-537E-4F6C-D104768A1214" {
       if let data = characteristic.value {
         self.NumPeople = data
      }
    }
  }

}
