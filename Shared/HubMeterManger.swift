//
//  HubMeterManger.swift
//  HubOMeter
//
//  Created by Olivier Wittop Koning on 14/10/2021.
//

import Foundation
import SwiftUI
import UIKit
import CoreBluetooth
import os

class HubMeterManger: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate, ObservableObject {
    
    private let logger = Logger(
        subsystem: "nl.wittopkoning.HubOmeter",
        category: "HubMeterManger"
    )
    
    
    public let NotificationServiceUUID = CBUUID(string: "7905F431-B5CE-4E99-A40F-4B1E122D00D0")
    private var centralManager: CBCentralManager! = nil
    @Published var NumPeople: Int = 0
    @Published var Devices = [iPad]()
    
    func refresh() -> Void {
        self.NumPeople = 0
        self.Devices = []
        self.centralManager.stopScan()
        self.centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    func startManager() {
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.logger.log("Central Manager State: \(self.centralManager.state.rawValue, privacy: .public)")
    }
    
    // Handles BT Turning On/Off
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
            self.logger.log("Scanning...")
        } else {
            self.logger.log("An other state running in the simulator or don't have permission")
        }
    }
    
    
    // Handles the result of the scan
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name != nil else { logger.log("The peripheral has no name"); return }
        // TODO: Maak hier een better numer van, want het is nu een beetje arbitair gekozen
        guard Int(truncating: RSSI) > -100 else { logger.log("The peripheral isn't in the HUB"); return }
        logger.log("Found named peripheral: \(peripheral.name!, privacy: .public)")

        // TODO: Implement this no idee how want als je nu srevices leest is hij leeg
        let HasNotificationService = true
        
        if peripheral.name!.hasPrefix("iPad") || IsAppleUUID(peripheral: peripheral) && HasNotificationService {
            self.logger.log("Found iPad: \(peripheral.name!) rssi: \(RSSI)")
            if (Devices.firstIndex(where: { $0.id == peripheral.identifier }) != nil) {
                if let index = Devices.firstIndex(where: { $0.id == peripheral.identifier }) {
                    Devices[index].rssi = Int(truncating: RSSI)
                } else {
                    self.logger.log("Not found and not updating the rssi")
                }
            } else {
                // Hier zit hij er nog niet in uds voegen we hem toe
                self.logger.debug("Info: \(peripheral.debugDescription)")
                NumPeople += 1
                Devices.append(iPad(peripheral))
            }
        }
    }
    
    func IsAppleUUID(peripheral: CBPeripheral) -> Bool {
        return HubMeterManger.UUIDS.contains(String(peripheral.identifier.uuidString.prefix(8)))
    }
    
    func HasNotificationService(ser: CBService) -> Bool {
        self.logger.log("deb: \(ser.debugDescription)")
        return false
        //        return ser.debugDescription ? true : false
    }
}

