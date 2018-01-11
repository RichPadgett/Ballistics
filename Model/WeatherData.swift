//
//  WeatherData.swift
//  DropZero-P3
//
//  Created by Richard Padgett on 10/4/16.
//  Copyright © 2016 Richard-Padgett. All rights reserved.
//

import Foundation

class WeatherData {
    
    //Access to Weather Data Throughout the App Globally
    struct GlobalData{
        
        //JSON Weather DATA Url, UPDated through setURL() function
        static var url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=34.67558593&lon=-82.8350379&&APPID=f876abf1b6b68c7d99b1f283568fb680")
        
        //Elevation Of user JSON DATA
        static var alturl = URL(string: "http://maps.googleapis.com/maps/api/elevation/json?locations=39.7391536,-104.9847034&sensor=false" )
        
        static var OpenWeatherKey = ""
        
        static var GoogleElevationKey = ""
        
        //This is the JSON URL CALL Return Value
        static var jsonResult: AnyObject!
        
        static var latitude = "33.6"
        
        //Keep Track of Target Longitude Data Through This Variable
        static var longitude = "78.8"
        
        static var altitude = "0.0"
        
        //Keep Track of Humidity Data Through This Variable
        static var humidity = "NaN"
        
        //Keep Track of Temperature Data Through This Variable
        static var temperatureF = "NaN"
        
        //Keep Track of Temperature Data Through This Variable
        static var temperatureC = "NaN"
        
        //Keep Track of Pressure Data Through This Variable
        static var pressure = "NaN"
        
        //Keep Track of visibility Data Through This Variable
        static var visibility = "NaN"
        
        //Keep Track of WindSpeed Though This Variable
        static var windspeed = "NaN"
        
        //Keep Track of Direction Through This Variable
        static var direction = "NaN"
        
        //Keep Track of Degrees as Double
        static var degrees = 0.000
        
        //Boolean that allows for constant GPS Update Or Not
        static var liveupdate = Bool()
        
        //Serves as a function to call the correct json we
        static func setUrl(userLat: String, userLon: String)
        {
            let u = "http://api.openweathermap.org/data/2.5/weather"
            let lat = "?lat="
            let lon = "&lon="
            let key = "&&APPID=f876abf1b6b68c7d99b1f283568fb680"
            _ = "&units=imperial"
            
            GlobalData.url = URL(string: u + lat + (userLat) + lon + (userLon) + key + OpenWeatherKey)!
            
            //http://api.openweathermap.org/data/2.5/weather?lat=34.67558593&lon=-82.8350379&&APPID=f876abf1b6b68c7d99b1f283568fb680
            
            WeatherData.GlobalData.latitude = (userLat)
            WeatherData.GlobalData.longitude = (userLon)
           
            let alt = "https://maps.googleapis.com/maps/api/elevation/json?locations="
            let sens = "&sensor=false"
            let keyalt = "&key=AIzaSyD8xUQrF94KOD_07X9uciOaC7iTfLO_y_M"
            
            GlobalData.alturl = URL(string: alt + userLat + "," + userLon + sens + keyalt)!
            
            //http://maps.googleapis.com/maps/api/elevation/json?locations=39.7391536,-104.9847034&sensor=false
            //https://maps.googleapis.com/maps/api/elevation/json?locations=39.7391536,-104.9847034&key=AIzaSyD8xUQrF94KOD_07X9uciOaC7iTfLO_y_M
        }
        
        //Initialize or set All Global Variables According to the JSON Data NSDictionary
        static func initVars(json: [String:AnyObject]){
            
            WeatherData.GlobalData.latitude = String(describing: json["coord"]!["lat"]!!)
            WeatherData.GlobalData.longitude = String(describing: json["coord"]!["lon"]!!)
            if(json["main"] != nil){
                if (json["main"]!["humidity"] != nil)
                {
                    WeatherData.GlobalData.humidity = String(describing: json["main"]!["humidity"]!!)
                }
                else
                {
                    WeatherData.GlobalData.humidity = "NaN"
                }
                
                if (json["main"]!["pressure"] != nil)
                {
                    let prs = Double(String(describing: json["main"]!["pressure"]!!))// Conversion to Hg
                    WeatherData.GlobalData.pressure = String(prs! * 0.030)
                }
                else
                {
                    WeatherData.GlobalData.pressure = "NaN"
                }
                
                if (json["wind"]!["deg"] != nil && json["wind"] != nil && json["wind"]!["deg"]! != nil)
                {
                    WeatherData.GlobalData.direction = String(describing: json["wind"]!["deg"]!!)
                    WeatherData.GlobalData.degrees = Double(WeatherData.GlobalData.direction)!
                }
                else
                {
                    WeatherData.GlobalData.direction = "NaN"
                }
                if (json["wind"]!["deg"] != nil && json["wind"] != nil && json["wind"]!["deg"]! != nil)
                {
                    WeatherData.GlobalData.windspeed = String(describing: json["wind"]!["speed"]!!)
                }
                else
                {
                    WeatherData.GlobalData.windspeed = "NaN"
                }
                if (json["main"]!["temp"] != nil){
                    let str = (String(describing: json["main"]!["temp"]!!))
                    let kelvin = Double(str)
                    let rankin = kelvin! * 9/5
                    let celcius = rankin * 9/5 - 273.15
                    let farenheit = rankin - 459.67
                    let far = String(format:"%.2f",farenheit)
                    let cel = String(format:"%.2f",celcius)
                    WeatherData.GlobalData.temperatureF = far
                    WeatherData.GlobalData.temperatureC = cel
                }
                else
                {
                    WeatherData.GlobalData.temperatureF = "NaN"
                    WeatherData.GlobalData.temperatureC = "NaN"
                }
            }
            else
            {
                initInvalid()
            }
        }
        
        //Initialize or set All Global Variables According to the JSON Data NSDictionary
        static func initElevation(json: [String: AnyObject])
        {
            let result = json["results"]![0] as! NSDictionary
            var elevation = (result["elevation"]!) as! Double
            elevation = (elevation * 1.09361) * 3
            WeatherData.GlobalData.altitude = String(format: "%.2f", elevation)
        }
        
        //If Weather Data Is Down Send Error Message to App
        static func initInvalid(){
            WeatherData.GlobalData.humidity = "NaN"
            WeatherData.GlobalData.pressure = "NaN"
            WeatherData.GlobalData.direction = "NaN"
            WeatherData.GlobalData.windspeed = "NaN"
            WeatherData.GlobalData.temperatureF = "NaN"
            WeatherData.GlobalData.temperatureC = "NaN"
        }
        
        static func initAltInvalid()
        {
            WeatherData.GlobalData.altitude = "NaN"
        }
    }
}
