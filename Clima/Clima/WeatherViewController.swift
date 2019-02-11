//
//  ViewController.swift
//  WeatherApp

import UIKit
import Alamofire
import SVProgressHUD
import SwiftyJSON
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {

    enum Constans {
        static let weatherUrl = "http://api.openweathermap.org/data/2.5/weather"
        static let appId = "3f8cc1706786b03b7085930ef9bb5772"
    }

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization() //this method displays pop up - ask for user permission
        locationManager.startUpdatingLocation()

    }

    // MARK: - Networking
    /***************************************************************/

    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters: [String: String]) {

        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print("Success! Weather data received")
                let weatherJSON: JSON = JSON(response.result.value!)
                //print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
            } else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection issues"
            }
        }
    }

    // MARK: - JSON Parsing
    /***************************************************************/

    //Write the updateWeatherData method here:

    func updateWeatherData(json: JSON) {
        if let tempResult = json["main"]["temp"].double {

            weatherDataModel.temperature = Int(tempResult - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWheaterData()

        } else {
            cityLabel.text = "Weather unavailable"
        }
    }

    // MARK: - UI Updates
    /***************************************************************/

    //Write the updateUIWithWeatherData method here:
    func updateUIWithWheaterData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }

    // MARK: - Location Manager Delegate Methods
    /***************************************************************/

    //Write the didUpdateLocations method here:
    func  locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]// last record is the best
        if location.horizontalAccuracy > 0 {        // check if result is correct
            locationManager.stopUpdatingLocation() // stop updating GPS coordinates to save battery

            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")

            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params: [String: String] = ["lat": latitude, "lon": longitude, "appid": Constans.appId] // dictionary for API's params
            getWeatherData(url: Constans.weatherUrl, parameters: params)
        }
    }

    //Write the didFailWithError method here:

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location unavailable!"
    }

    // MARK: - Change City Delegate methods
    /***************************************************************/

    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCity(city: String) {
        print(city)
        let params: [String : String] = ["q": city, "appid": Constans.appId]
        getWeatherData(url: Constans.weatherUrl, parameters: params)
    }

    //Write the PrepareForSegue Method here

    override  func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == "changeCityName",
            let destinationVC = segue.destination as? ChangeCityViewController
        else {
            return
     }
        destinationVC.delegate = self
    }
}
