//
//  CBManagerDelegate.swift
//  Ble-SiliconLab
//
//  Created by Maarten Wittop Koning on 7/3/20.
//  Copyright © 2020 Olivier Wittop Koning. All rights reserved.
//

import Foundation
import CoreBluetooth

import os
func logError(_ msg: StaticString, _ params: Any...) {
    os_log(msg, log: OSLog.default, type: .error, params)
}


let Temperature = CBUUID(string: "0x2A6E")
let Digital = CBUUID(string: "0x2A56")


extension ViewController:  CBCentralManagerDelegate {

       func centralManagerDidUpdateState(_ central: CBCentralManager) {

           if central.state == .poweredOn {
               central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
               print("Scanning...")
           }
       }

       func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
           guard peripheral.name != nil else {return}
           logError("peripheral name: %{public}@",  peripheral.name as Any)
            if peripheral.name! == "Arduino" ||  peripheral.name! == "LED" ||  peripheral.name! == "De spoorbaan"{
               print("Arduino Found!")
               //stopScan
               cbCentralManager.stopScan()
               //connect
               cbCentralManager.connect(peripheral, options: nil)
               self.peripheral = peripheral
           }
       }

       func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
           print("Connected : \(peripheral.name ?? "No Name")")
           connected = true
           logError("Connected: %{public}@",  peripheral.name ?? "No Name")

           //it' discover all service
           //peripheral.discoverServices(nil)

           //discover EnvironmentalSensing,AutomationIO
           peripheral.discoverServices([BLEService_UUID])
           peripheral.delegate = self
       }

       func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
           print("Disconnected : \(peripheral.name ?? "No Name")")
           logError("Disconnected: %{public}@",  peripheral.name ?? "No Name")
           LightImage.tintColor = .gray
           cbCentralManager.scanForPeripherals(withServices: nil, options: nil)
       }
}


//MARK:- CBPeripheralDelegate
extension ViewController : CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        if let services = peripheral.services {
            //discover characteristics of services

            for service in services {
              peripheral.discoverCharacteristics(nil, for: service)
          }
             print("Discovered Services: \(services)")
            //TODO
             logError("Discovered Services: %{public}@", services)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        if let charac = service.characteristics {
            for characteristic in charac {

                //MARK:- Light Value
                if characteristic.uuid == BLE_Characteristic_uuid {
                      //write value
                    LightImage.tintColor = .systemBlue
                    LED_chara = characteristic
                    setDigitalOutput(0, on: false, characteristic: characteristic)
                }

                //MARK:- Temperature Read Value
                else if characteristic.uuid == Temperature {
                    //read value
                    //peripheral.readValue(for: characteristic)
                    peripheral.setNotifyValue(true, for: characteristic)
                }

            }
        }

    }


    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        if characteristic.uuid == Temperature {
                           print("Temp : \(characteristic)")
                let temp = characteristic.tb_uint16Value()

                print(Double(temp!) / 100)
            }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("WRITE VALUE : \(characteristic)")
        logError("WRITE VALUE : %{public}@", characteristic)
    }


     func setDigitalOutput(_ index: Int, on: Bool, characteristic  :CBCharacteristic) {
           var value: UInt8 = 0
           if on {
                value = UInt8(index)
           }
           else if !on {
                value = UInt8(0)
           }

            let data = Data(bytes: [value])
            self.peripheral?.writeValue(data, for: characteristic, type: .withResponse)
       }

}

extension CBCharacteristic  {
   func tb_int16Value() -> Int16? {
        if let data = self.value {
            var value: Int16 = 0
            (data as NSData).getBytes(&value, length: 2)

            return value
        }

        return nil
    }
    func tb_uint16Value() -> UInt16? {
        if let data = self.value {
            var value: UInt16 = 0
            (data as NSData).getBytes(&value, length: 2)

            return value
        }

        return nil
    }
}
