//
//  WeatherTests.swift
//  WeatherTests
//
//  Created by Raju on 19/09/24.
//

import XCTest
@testable import Weather

import Combine
import XCTest

// Mock ApiService
class MockApiService: ApiServiceProtocol {
    var shouldReturnError = false
    var mockWeatherModel: WeatherModel?

    func fetchOpenWeater(for city: String) -> AnyPublisher<WeatherModel, Error> {
        if shouldReturnError {
            return Fail(error: NSError(domain: "", code: -1, userInfo: nil)).eraseToAnyPublisher()
        } else {
            return Just(mockWeatherModel!)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}

final class WeatherTests: XCTestCase {
    var viewModel: WeatherViewModel!
    var mockApiService: MockApiService!
    
    override func setUp() {
        super.setUp()
        mockApiService = MockApiService()
        viewModel = WeatherViewModel(apiService: mockApiService)
    }
    
    func testFetchWeatherSuccess() {
        // Given
        let mockWeather = WeatherModel(main: WeatherModel.Main(temp: 15.0, humidity: 80), weather: [WeatherModel.Weather(description: "Rain", icon: "10d")])
        mockApiService.mockWeatherModel = mockWeather
        
        // When
        viewModel.fetchWeather(for: "London")
        
        // Then
        let expectation = self.expectation(description: "Weather fetched successfully")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNil(self.viewModel.errorMessage, "There should be no error message.")
            XCTAssertFalse(self.viewModel.isLoading, "false")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testFetchWeatherFailure() {
        // Given
        mockApiService.shouldReturnError = true
        
        // When
        viewModel.fetchWeather(for: "InvalidCity")
        
        // Then
        let expectation = self.expectation(description: "Weather fetch failed")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNil(self.viewModel.weatherModel, "Weather model should be nil on error.")
            XCTAssertNotNil(self.viewModel.errorMessage, "There should be an error message.")
            XCTAssertFalse(self.viewModel.isLoading, "false")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testFetchWeatherForEmptyCity() {
        // Given
        viewModel.city = ""
        
        // When
        viewModel.fetchWeather(for: nil)
        
        // Then
        XCTAssertNil(viewModel.weatherModel, "Weather model should be nil for empty city.")
        XCTAssertNil(viewModel.errorMessage, "There should be no error message for empty city.")
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false for empty city.")
    }
    
    func testSaveLastSearchedLocation() {
        // Given
        viewModel.fetchWeather(for: "Berlin")
        
        // When
        let lastSearchedLocation = UserDefaults.standard.string(forKey: "lastSearchedLocation")
        
        // Then
        XCTAssertEqual(lastSearchedLocation, "Berlin", "Last searched location should be saved correctly.")
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
