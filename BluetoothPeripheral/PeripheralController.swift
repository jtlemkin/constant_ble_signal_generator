//
//  PeripheralManager.swift
//  BluetoothPeripheral
//
//  Created by James Lemkin on 5/24/20.
//  Copyright © 2020 James Lemkin. All rights reserved.
//

import CoreBluetooth

class PeripheralController : NSObject, CBPeripheralManagerDelegate, ObservableObject {
    let serviceID = CBUUID(string: "ae398894-9df8-11ea-bb37-0242ac130002")
    let characteristicID = CBUUID(string: "844554c2-9df9-11ea-bb37-0242ac130002")
    let peripheralManager : CBPeripheralManager
    let characteristic : CBMutableCharacteristic
    let service : CBMutableService
    
    var updateTimer: Timer?
    var charData : Data? {
        didSet {
            if let data = charData, peripheralManager.state == .poweredOn {
                let didSendValue = peripheralManager.updateValue(data, for: self.characteristic, onSubscribedCentrals: nil)
                
                if !didSendValue {
                    state = "Has unset data"
                }
            }
        }
    }
    
    @Published var currentValue = 0
    @Published var state : String = "Blank"
    
    override init() {
        characteristic = CBMutableCharacteristic(type: characteristicID, properties: [.read, .notify], value: nil, permissions: CBAttributePermissions.readable)
        service = CBMutableService(type: serviceID, primary: true)
        service.characteristics = [characteristic]
        peripheralManager = CBPeripheralManager()
        
        super.init()
        
        peripheralManager.delegate = self
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [unowned self] timer in
            self.currentValue = Int.random(in: 0..<16)
            let data = Data(bytes: &self.currentValue, count: MemoryLayout.size(ofValue: self.currentValue))
            self.charData = data
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            state = "On"
            let advertisementData : [String: Any] = [CBAdvertisementDataLocalNameKey: "sine",
                                                     CBAdvertisementDataServiceUUIDsKey: [serviceID]]
            peripheralManager.add(service)
            peripheralManager.startAdvertising(advertisementData)
        case .poweredOff:
            state = "Off"
        case .resetting:
            state = "Resetting"
        case .unauthorized:
            state = "unauthorized"
        case .unsupported:
            state = "unsupported"
        case .unknown:
            state = "unknown"
        @unknown default:
            fatalError()
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        if (request.characteristic.uuid == characteristic.uuid) {
            if let value = charData {
                guard request.offset < value.count else {
                    peripheralManager.respond(to: request, withResult: CBATTError.invalidOffset)
                    return
                }
                
                let rangeOfValue = request.offset..<(value.count - request.offset)
                request.value = value.subdata(in: rangeOfValue)
                peripheralManager.respond(to: request, withResult: CBATTError.success)
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Connection")
    }
}

