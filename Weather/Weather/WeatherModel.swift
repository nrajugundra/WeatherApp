//
//  WeatherModel.swift
//  Weather
//
//  Created by Raju on 19/09/24.
//

import Foundation

struct WeatherModel: Codable {
    let main: Main
    let weather: [Weather]

    struct Main: Codable {
        let temp: Double
        let humidity: Double
    }

    struct Weather: Codable {
        let description: String
        let icon: String
    }
}
