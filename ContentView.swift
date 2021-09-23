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
			Text($HubOMeter.NumPeople)
		}
	}.onAppear(perform: HubOMeter.startCentralManager)
    }
}
