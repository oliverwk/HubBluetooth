//
//  ViewController.swift
//  Ble-SiliconLab
//
//  Created by Aminjoni Abdullozoda on 7/3/20.
//  Copyright © 2020 Aminjoni Abdullozoda. All rights reserved.
//

import UIKit
import CoreBluetooth
import os


class ViewController: UIViewController {
    
    //MARK:-UI Elements
    @IBOutlet weak var batteryImage : UIImageView!
    @IBOutlet weak var LightImage : UIImageView!
    @IBOutlet weak var lightSwitch : UISwitch!
    @IBOutlet weak var lightSlider : UISlider!
    
    
    
    
    //MARK:- CBluetooth
    var cbCentralManager : CBCentralManager!
    var peripheral : CBPeripheral?
    var connected: Bool = false
    var BtnOn: Bool = true
    var LED_chara: CBCharacteristic?
    //MARK:- Slider
    
    @IBAction func valueSliderChange(_ sender: UISlider, forEvent event: UIEvent) {
                print("Value of the slider Changed: ", sender.value)
                logError("Value of the slider Changed: %{public}@", sender.value)
                logError("Button Status : %{public}@", BtnOn)
                  if connected && BtnOn {
                    self.setDigitalOutput(Int(sender.value), on: BtnOn, characteristic: LED_chara!)
                   BtnOn.toggle()
                  } else if !connected {
                   LightImage.tintColor = .gray
                    }
       }
    //MARK:- Button
    @IBAction func toggled(_ sender: Any, forEvent event: UIEvent) {
               logError("button toggled: %{public}@", BtnOn)
               
               if connected {
                self.setDigitalOutput(1, on: BtnOn, characteristic: LED_chara!)
                BtnOn.toggle()
               } else {
                LightImage.tintColor = .gray
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        LightImage.tintColor = .gray
        lightSlider.isContinuous = false
        
        //Start manager
        cbCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
}


