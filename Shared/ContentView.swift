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
    // @StateObject private var HubOMeter = HubOMeterManger();
    @StateObject private var HubOMeter = HubMeterManger();
    
    var body: some View {
        VStack {
            Text("Number of people:")
            Text("\(HubOMeter.NumPeople)")
        }.onAppear(perform: HubOMeter.startManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
