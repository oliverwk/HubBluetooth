//
//  BlueUUId.swift
//
//  Created by Maarten Wittop Koning on 21/12/2020.
//  Copyright © 2020 Aminjoni Abdullozoda. All rights reserved.
//

import Foundation

import CoreBluetooth
//Uart Service uuid

let kBLEService_UUID = "19B10000-E8F2-537E-4F6C-D104768A1214"
let  BLELEDSwitchCharacteristic = "19B10001-E8F2-537E-4F6C-D104768A1214"
let MaxCharacters = 20

let BLEService_UUID = CBUUID(string: kBLEService_UUID)
let BLE_Characteristic_uuid = CBUUID(string: BLELEDSwitchCharacteristic)//(Property = Write without response)
