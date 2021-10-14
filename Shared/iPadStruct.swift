//
//  iPadStruct.swift
//  HubOMeter
//
//  Created by Olivier Wittop Koning on 14/10/2021.
//

import Foundation
import CoreBluetooth

struct iPad {
    let id: UUID
    let name: String
    var rssi: Int? = 0

    init(_ peripheral: CBPeripheral) {
        self.name = peripheral.name!
        self.id = peripheral.identifier
    }
}
