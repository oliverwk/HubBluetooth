//
//  ContentView.swift
//  Shared
//
//  Created by Olivier Wittop Koning on 24/09/2021.
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
            Button("Refresh") {
                self.logger.log("Refreshing the content")
                HubOMeter.refresh()
            }.keyboardShortcut("r", modifiers: [.command]).padding(.top, 20).buttonStyle(.bordered)
        }.onAppear(perform: HubOMeter.startManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
