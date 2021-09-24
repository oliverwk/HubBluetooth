//
//  HubOMeterManger.swift
//  HubOMeter
//
//  Created by Maarten Wittop Koning on 24/09/2021.
//

import Foundation
import SwiftUI
import UIKit
import CoreBluetooth
import os

class HubOMeterManger: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate, ObservableObject {
  
  private let logger = Logger(
         subsystem: "nl.wittopkoning.HubOmeter",
         category: "HubOMeterManger"
  )
  override init() {
      self.logger.log("hi")
  }
  private var centralManager: CBCentralManager! = nil
  private var peripheral: CBPeripheral!

  public static let bleServiceUUID = CBUUID.init(string: "19B10010-E8F2-537E-4F6C-D104768A1214")
  public static let bleCharacteristicUUID = CBUUID.init(string: "19B10012-E8F2-537E-4F6C-D104768A1214")


  // Array to contain names of BLE devices to connect to.
  // Accessable by ContentView for Rendering the SwiftUI Body on change in this array.
  @Published var NumPeople: Int = 0


  func startCentralManager() {
    self.centralManager = CBCentralManager(delegate: self, queue: nil)
      self.logger.log("Central Manager State: \(self.centralManager.state.rawValue, privacy: .public)")
  }

  // Handles BT Turning On/Off
  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
      if central.state == .poweredOn {
          central.scanForPeripherals(withServices: [HubOMeterManger.bleServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
          self.logger.log("Scanning...")
      } else {
        self.logger.log("HELPPPPPPPPPP probaly running in the simulator")
      }
    }

  // Handles the result of the scan
  public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    guard peripheral.name != nil else { return }
    logger.log("peripheral name: \(peripheral.name!, privacy: .public)")
     if peripheral.name! == "HubOmeter" || peripheral.name! == "Arduino" {
        self.logger.log("Arduino Found!")
        self.centralManager.stopScan()
        self.centralManager.connect(peripheral, options: nil)
        self.peripheral = peripheral
        self.peripheral.delegate = self
    }
  }


  // The handler if we do connect successfully
  public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    if peripheral == self.peripheral {
      self.logger.log("Connected to the HubOmeter")
      //peripheral.discoverServices([HubOMeterManger.bleServiceUUID])
      peripheral.discoverServices(nil)
    }
  }


  // Handles discovery event
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    if let services = peripheral.services {
      for service in services {
        self.logger.log("Found services: \(service.debugDescription, privacy: .public), uuidstring:\(service.uuid.uuidString, privacy: .public)")

        if service.uuid == HubOMeterManger.bleServiceUUID {
          self.logger.log("BLE Service found")
          // Find the good chars
          peripheral.discoverCharacteristics([HubOMeterManger.bleCharacteristicUUID], for: service)
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
        self.logger.log("The uuid: \(uuidString, privacy: .public) Characteristic: \(characteristic, privacy: .public)")
        peripheral.setNotifyValue(true, for: characteristic)

          if uuidString == "19B10012-E8F2-537E-4F6C-D104768A1214" {
            self.logger.log("BLE service characteristic \(HubOMeterManger.bleCharacteristicUUID, privacy: .public) found")
            peripheral.readValue(for: characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
        } else {
            self.logger.log("Characteristic not found.")
        }
      }
    }
  }


  public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    if characteristic.uuid.uuidString == "19B10012-E8F2-537E-4F6C-D104768A1214" {
       if let data = characteristic.value {
           logger.log("New data: \(data.debugDescription, privacy: .public) int: \(String(data: data, encoding: String.Encoding.utf8)!, privacy: .public)")

           self.NumPeople = Int(String(data: data, encoding: String.Encoding.utf8)!) ?? 0
      }
    }
  }

}
