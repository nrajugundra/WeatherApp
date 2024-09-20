//
//  NetworkManager.swift
//  Weather
//
//  Created by Raju on 19/09/24.
//

import Foundation
import Combine

protocol ApiServiceProtocol {
    func fetchOpenWeater(for city: String)  -> AnyPublisher<WeatherModel, Error>
}

class ApiServiceHandler: ApiServiceProtocol {
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    private let apiKey = "44152e2526c6ed236ccde27af7e80b53"
    private let session: URLSession

    // Initialize with a URLSession instance
    init(session: URLSession = .shared) {
        self.session = session
    }
    //Url encoding with valid address check
    func encodeURLString(_ string: String) -> String? {
        // Define allowed characters; everything except those that need encoding
        let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
        
        // Encode the string using the allowed characters set
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
        
    //API call to Open weather server to fetch live data
    func fetchOpenWeater(for city: String) -> AnyPublisher<WeatherModel, Error> {
        guard let cityName = encodeURLString(city) else {
            return  Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        let urlString = baseURL + "?q=\(cityName)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return self.session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: WeatherModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
