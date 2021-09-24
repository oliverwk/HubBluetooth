//
//  ContentView.swift
//  Shared
//
//  Created by Maarten Wittop Koning on 24/09/2021.
//

import SwiftUI
import os

struct ContentView: View {
   private let logger = Logger(
        subsystem: "nl.wittopkoning.HubOmeter",
        category: "ContentView"
   )
   @StateObject private var HubOMeter = HubOMeterManger();
    var body: some View {
        NavigationView {
        VStack {
            Text("Number off people:")
            Text("\(HubOMeter.NumPeople)")
        }
    }.onAppear(perform: HubOMeter.startCentralManager)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
