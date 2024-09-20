//
//  ContentView.swift
//  Weather
//
//  Created by Raju on 19/09/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint: .topLeading, endPoint: .bottomLeading).edgesIgnoringSafeArea(.all)
                VStack {
                    TextField(NSLocalizedString("Enter US City", comment: ""), text: $viewModel.city)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityIdentifier("CityTextField")
                        .onSubmit() {
                            viewModel.fetchWeather(for:  viewModel.city)
                        }
                    Button(NSLocalizedString("Search", comment: "")) {
                        viewModel.fetchWeather(for:  viewModel.city)
                    }
                    .frame(width: 120)
                    .buttonStyle(.borderedProminent)
                    .tint(.cyan)
                    .cornerRadius(3.0)
                    .foregroundColor(.white)
                    .accessibilityIdentifier("SearchButton")
                    .accessibilityLabel(NSLocalizedString("SearchButton", comment: ""))
                    .accessibilityHint(NSLocalizedString("SearchButtonTap", comment: ""))

                    
                    if let weather = viewModel.weatherModel {
                        if let icon = weather.weather.first?.icon {
                            AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png"))
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                        }
                        let temp = (String(format: "%.1f", weather.main.temp))
                        
                        Text(NSLocalizedString("Temperature", comment: "")
                             + ": \(temp)°C")
                            .bold()
                            .accessibilityLabel("Temperature")
                            .accessibilityValue("\(temp) degrees Celsius")
                        
                        let humidity = (String(format: "%.1f", weather.main.humidity))

                        Text(NSLocalizedString("Humidity", comment: "") + ": \(humidity) %")
                            .font(.headline)
                            .accessibilityLabel("Humidity")
                            .accessibilityValue("\(humidity) percent")
                        
                        Text(NSLocalizedString("Condition", comment: "") + ": \(weather.weather.first?.description ?? "")")
                            .bold()
                            .accessibilityLabel("Weather Description")
                            .accessibilityValue(weather.weather.first?.description ?? "No description available")
                        
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .accessibilityIdentifier("ErrorMessage")
                            .accessibilityLabel("Error")
                            .accessibilityValue(errorMessage)
                    }
                    Spacer()
                }
            }
            .navigationTitle("Weather")
            .navigationBarTitleDisplayMode(.inline)
        }.onAppear() {
            loadLastSearchedLocation()
        }
    }
    
    //Stored cityName in local data to access for next time usage.
     func loadLastSearchedLocation() {
        if let cityName = UserDefaults.standard.string(forKey: "lastSearchedLocation"), !cityName.isEmpty {
            viewModel.fetchWeather(for: cityName)
        } else {
            locationManager.setUPDefaultLocation(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView(viewModel: WeatherViewModel(apiService: ApiServiceHandler())).environmentObject(LocationManager())
}
