//
//  LocationManager.swift
//  Weather
//
//  Created by Raju on 19/09/24.
//

import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var viewModel: WeatherViewModel?
    override init() {
        super.init()
    }
    
    //To setup location
    func setUPDefaultLocation(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("came 2")
        if let last = locations.last {
            reverseGeocode(location: last)
        }
    }
    
    //Fetch cityName from location to retrive weather report for app launch time
    private func reverseGeocode(location: CLLocation) {
        print("came 3")

        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if error != nil {
                print("came 4")
                return
            }
            print("came 5")

            if let placemark = placemarks?.first {
                print("came 6")

                let city = [placemark.locality].compactMap { $0 }.joined(separator: ", ")
                print("came 7")

                print("Raju: \(city) from location manager")
                self.viewModel?.fetchWeather(for: city)
            }
        }
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
