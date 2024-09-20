//
//  WeatherApp.swift
//  Weather
//
//  Created by Raju on 19/09/24.
//

import SwiftUI

@main
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: WeatherViewModel(apiService: ApiServiceHandler())).environmentObject(LocationManager())
        }
    }
}
