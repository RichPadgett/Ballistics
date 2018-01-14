//
//  TargetPin.swift
//  Ballistics
//
//  Created by Richard Padgett on 1/3/18.
//  Copyright © 2018 Richard-Padgett. All rights reserved.
//

import Foundation
import MapKit



class TargetPin: NSObject, MKAnnotation
{
    var markerTintColor: UIColor  {
        switch discipline {
        case "Monument":
            return .red
        case "Mural":
            return .cyan
        case "Target":
            return .blue
        case "Sculpture":
            return .purple
        default:
            return .green
        }
    }
    
    var imageName: String? {
        if discipline == "Sculpture" { return "Statue" }
        return "Flag"
    }
    
    var timerWeather = Timer()
    var timerAltitude = Timer()
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D

    var temperatureFarenheightString: String
    var temperatureFarenheightDouble: Double
    var temperatureCelciusString: String
    var temperatureCelciusDouble: Double
    var relativeHumidityPercentString: String
    var relativeHumidityPercentDouble: Double
    var altitudeFtString: String
    var altitudeFtDouble: Double
    var windVelocityMiHrString: String
    var windVelocityMiHrDouble: Double
    var windAngleDegString: String
    var windAngleDegDouble: Double
    var barometricPressureInHgString: String
    var barometricPressureInHgDouble: Double
    
    init(title: String, locationName: String, discipline: String,
         coordinate: CLLocationCoordinate2D)
    {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        // set variables to standard values
        self.temperatureFarenheightString = "78.6"
        self.temperatureFarenheightDouble = 78.6
        self.temperatureCelciusString = "25.5"
        self.temperatureCelciusDouble = 25.5
        self.relativeHumidityPercentString = "78.0"
        self.relativeHumidityPercentDouble = 78.0
        self.altitudeFtString = "0.0"
        self.altitudeFtDouble = 0.0
        self.windVelocityMiHrString = "0.0"
        self.windVelocityMiHrDouble = 0.0
        self.windVelocityMiHrString = "0.0"
        self.windVelocityMiHrDouble = 29.53
        self.windAngleDegString = "0.0"
        self.windAngleDegDouble = 0.0
        self.barometricPressureInHgString = "0.0"
        self.barometricPressureInHgDouble = 0.0
       
        
        super.init()
        
        // Get specific values
        self.getWeather()
        self.getAltitude()     
    }
    
    var subtitle: String?
    {
        
        return "Wind: " + windAngleDegString + "\u{00B0}" + //"\n" +
        " " + windVelocityMiHrString + "mi/hr" //+ //"\n" +
        //" Hum: " + relativeHumidityPercent + "\u{0025}" + //"\n" +
        //" Temp: " + temperatureFarenheight + "\u{00B0}" + //"\n" +
        //" Alt: " + altitudeFt + "ft" + //"\n" +
       // " Bar: " + barometricPressureInHg + "in/Hg"
        
    }
    
    @objc func getWeather()
    {
        let wlat = String(self.coordinate.latitude)
        let wlon = String(self.coordinate.longitude)

        let u = "http://api.openweathermap.org/data/2.5/weather"
        let lat = "?lat="
        let lon = "&lon="
        let key = "&&APPID=f876abf1b6b68c7d99b1f283568fb680"
        _ = "&units=imperial"

        let OPEN_WEATHER_KEY = ""

        let urlWeather = URL(string: u + lat + (wlat) + lon + (wlon) + key + OPEN_WEATHER_KEY)!

        //http://api.openweathermap.org/data/2.5/weather?lat=34.67558593&lon=-82.8350379&&APPID=f876abf1b6b68c7d99b1f283568fb680

        WeatherData.GlobalData.setUrl(userLat: String(coordinate.latitude),userLon: String(coordinate.longitude))

        let urlRequest = URLRequest(url: urlWeather)

        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        // make the request
        let task = session.dataTask(with: urlRequest)
        {
            (data, response, error) in
            // check for any errors
            guard error == nil
                else
            {
                print("error calling GET on " + String(describing: urlRequest))
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data
                else
            {
                print("Error: did not receive weather data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do
            {
                guard let weather = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers)
                    as? [String: Any]
                    else
                {
                    print("error trying to convert weather data to JSON")
                    return
                }

                self.initVarsWeather(json: weather as [String: AnyObject])
            }
            catch
            {
                print("error trying to convert data to JSON")
                self.initInvalidWeather()
                return
            }
        }
        task.resume()
    }

    @objc func getAltitude()
    {


        let alat = String(self.coordinate.latitude)
        let alon = String(self.coordinate.longitude)

        let alt = "https://maps.googleapis.com/maps/api/elevation/json?locations="
        let sens = "&sensor=false"
        let keyalt = "&key=AIzaSyD8xUQrF94KOD_07X9uciOaC7iTfLO_y_M"

        let GOOGLE_ELEVATION_KEY = ""

        let urlAltitude = URL(string: alt + alat + "," + alon + sens + keyalt + GOOGLE_ELEVATION_KEY)!

        //https://maps.googleapis.com/maps/api/elevation/json?locations=39.7391536,-104.9847034&key=AIzaSyD8xUQrF94KOD_07X9uciOaC7iTfLO_y_M

        let urlRequest = URLRequest(url: urlAltitude)

        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        // make the request
        let task = session.dataTask(with: urlRequest)
        {
            (data, response, error) in
            // check for any errors
            guard error == nil
                else
            {
                print("error calling GET on " + String(describing: urlRequest))
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data
                else
            {
                print("Error: did not receive weather data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do
            {
                guard let weather = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers)
                    as? [String: Any]
                    else
                {
                    print("error trying to convert weather data to JSON")
                    return
                }

                self.initVarsAltitude(json: (weather as [String: AnyObject]))
            }
            catch
            {
                print("error trying to convert data to JSON")
                self.initInvalidAltitude()
                return
            }
        }
        task.resume()
    }

    func initVarsWeather(json: [String: AnyObject]){

        if(json["main"] != nil){
            if (json["main"]!["humidity"] != nil)
            {
                self.relativeHumidityPercentString = String(describing: json["main"]!["humidity"]!!)
                self.relativeHumidityPercentDouble = Double(relativeHumidityPercentString)!
            }
            else
            {
                self.relativeHumidityPercentString = "NaN"
            }

            if (json["main"]!["pressure"] != nil)
            {
                self.barometricPressureInHgString = String(describing: json["main"]!["pressure"]!!)// Conversion to Hg
                self.barometricPressureInHgDouble = (Double(barometricPressureInHgString)! * 0.030)

            }
            else
            {
                self.barometricPressureInHgString = "NaN"
                self.barometricPressureInHgDouble = 0
            }

            if (json["wind"]!["deg"] != nil && json["wind"] != nil && json["wind"]!["deg"]! != nil)
            {
                self.windAngleDegString = String(describing: json["wind"]!["deg"]!!)
                print("stringwind: " + windAngleDegString + String(windAngleDegDouble))
                self.windAngleDegDouble = Double(windAngleDegString)!
                      print("stringwind: " + windAngleDegString + String(windAngleDegDouble))
            }
            else
            {
                self.windAngleDegDouble = 0
            }
            if (json["wind"]!["deg"] != nil && json["wind"] != nil && json["wind"]!["deg"]! != nil)
            {
                 self.windVelocityMiHrString = String(describing: json["wind"]!["speed"]!!)
                 self.windVelocityMiHrDouble = Double(windVelocityMiHrString)!
            }
            else
            {
                self.windVelocityMiHrString = "NaN"
                self.windVelocityMiHrDouble = 0
            }
            if (json["main"]!["temp"] != nil){
                let str = (String(describing: json["main"]!["temp"]!!))
                let kelvin = Double(str)
                let rankin = kelvin! * 9/5
                let celcius = rankin * 9/5 - 273.15
                let farenheit = rankin - 459.67
                let far = String(format:"%.2f",farenheit)
                let cel = String(format:"%.2f",celcius)
                self.temperatureFarenheightString = far
                self.temperatureFarenheightDouble = Double(far)!
                self.temperatureCelciusString = cel
                self.temperatureCelciusDouble = Double(cel)!
            }
            else
            {
                self.temperatureFarenheightString = "NaN"
                self.temperatureFarenheightDouble = 78.3
                self.temperatureCelciusString = "NaN"
                self.temperatureCelciusDouble = 40
            }
        }
        else
        {
            initInvalidWeather()
        }
    }

    func initInvalidWeather()
    {
        print("invalid call in weather ")
    }

    func initVarsAltitude(json: [String: AnyObject])
    {
        let result = json["results"]! as! NSArray
        let array0 = result[0] as! NSDictionary
        var elevation = (array0["elevation"]!) as! Double
        elevation = (elevation * 1.09361) * 3
        self.altitudeFtString = String(format: "%.2f", elevation)
        self.altitudeFtDouble = Double(altitudeFtString)!
    }



    func initInvalidAltitude()
    {
        print("invalid call in altitude")
    }
}
