//
//  HubOMeterManger.swift
//  HubOMeter
//
//  Created by Maarten Wittop Koning on 24/09/2021.
//

import Foundation
import SwiftUI
import CoreBluetooth
import os

class HubOMeterManger: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate, ObservableObject {
    
    private let logger = Logger(
        subsystem: "nl.wittopkoning.HubOmeter",
        category: "HubOMeterManger"
    )
    
    private var centralManager: CBCentralManager! = nil
    private var peripheral: CBPeripheral!
    
    public let bleServiceUUID = CBUUID(string: "00000001-710E-4A5B-8D75-3E5B444BC3CF")
    public let bleCharacteristicUUID = CBUUID(string: "00000002-710E-4A5B-8D75-3E5B444BC3CF")
    
    
    // Array to contain names of BLE devices to connect to.
    // Accessable by ContentView for Rendering the SwiftUI Body on change in this array.
    @Published var NumPeople: Int = 0
    
    func startManager() {
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.logger.log("Central Manager State: \(self.centralManager.state.rawValue, privacy: .public)")
    }
    
    // Handles BT Turning On/Off
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: [self.bleServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
            self.logger.log("Scanning...")
        } else {
            self.logger.log("An other state running in the simulator or don't have permission")
        }
    }
    
    // Handles the result of the scan
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name != nil else { logger.log("The peripheral has no name"); return }
        logger.log("peripheral name: \(peripheral.name!, privacy: .public)")
        if peripheral.name! == "Thermometer" || peripheral.name! == "Arduino"  {
            self.logger.log("Found \(peripheral.name!)!")
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
            peripheral.discoverServices([self.bleServiceUUID])
            //      peripheral.discoverServices(nil)
        }
    }
    
    
    // Handles discovery event
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                self.logger.log("Found services: \(service.debugDescription, privacy: .public), uuidstring:\(service.uuid.uuidString, privacy: .public)")
                
                if service.uuid == self.bleServiceUUID {
                    self.logger.log("BLE Thermo Service found")
                    peripheral.discoverCharacteristics([self.bleCharacteristicUUID], for: service)
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
                
                if uuidString == self.bleCharacteristicUUID.uuidString { // "00000002-710E-4A5B-8D75-3E5B444BC3CF" {
                    self.logger.log("BLE service characteristic \(self.bleCharacteristicUUID, privacy: .public) found")
                    peripheral.readValue(for: characteristic)
                    peripheral.setNotifyValue(true, for: characteristic)
                } else {
                    self.logger.log("Characteristic not found.")
                }
            }
        }
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid.uuidString == self.bleCharacteristicUUID.uuidString { // "00000002-710E-4A5B-8D75-3E5B444BC3CF" {
            if let data = characteristic.value {
                logger.log("New data: \(data.debugDescription, privacy: .public) int: \(String(data: data, encoding: String.Encoding.utf8)!, privacy: .public)")
                self.NumPeople = Int(String(data: data, encoding: String.Encoding.utf8)!) ?? 0
            }
        }
    }
    
}
