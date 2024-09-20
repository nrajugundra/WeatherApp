//
//  WeatherViewModel.swift
//  Weather
//
//  Created by Raju on 19/09/24.
//

import Foundation
import Combine
import CoreLocation


class WeatherViewModel: ObservableObject {
    @Published var weatherModel: WeatherModel?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var city: String = ""

    private var cancellables = Set<AnyCancellable>()
    private let apiService: ApiServiceProtocol

    init(apiService: ApiServiceProtocol) {
        self.apiService = apiService
    }
    
    //API call to weather server to fetch live data
    func fetchWeather(for city: String?) {
        guard let city = city, !city.isEmpty else { return }
        self.city = city
        self.isLoading = true

        apiService.fetchOpenWeater(for: city)
            .map { response in
                response
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(_):
                    self.weatherModel = nil
                    self.errorMessage = NSLocalizedString("ErrorMessage", comment: "")
                }
                self.isLoading = false
            }, receiveValue: { weather in
                self.errorMessage = nil
                self.isLoading = false
                self.saveLastSearchedLocation()
                self.weatherModel = weather //Set up weather data to observable object
            })
            .store(in: &cancellables)
    }
    
    //Stored cityName in local data to access for next time usage.
    private func saveLastSearchedLocation() {
        UserDefaults.standard.set(self.city, forKey: "lastSearchedLocation")
    }
}
