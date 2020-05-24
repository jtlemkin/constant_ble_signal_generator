//
//  ContentView.swift
//  BluetoothPeripheral
//
//  Created by James Lemkin on 5/24/20.
//  Copyright © 2020 James Lemkin. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var peripheralController = PeripheralController()
    
    var body: some View {
        VStack {
            Text(String(peripheralController.currentValue))
                .padding([.all])
            
            Text(peripheralController.state)
                .padding([.all])
        }.frame(width: 100, height: 100, alignment: .center)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
