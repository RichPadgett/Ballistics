//
//  WeatherData.swift
//  DropZero-P3
//
//  Created by Richard Padgett on 10/4/16.
//  Copyright © 2016 Richard-Padgett. All rights reserved.
//
//http://api.openweathermap.org/data/2.5/weather?lat=34.67558593&lon=-82.8350379&&APPID=f876abf1b6b68c7d99b1f283568fb680

//http://maps.googleapis.com/maps/api/elevation/json?locations=39.7391536,-104.9847034&sensor=false
//https://maps.googleapis.com/maps/api/elevation/json?locations=39.7391536,-104.9847034&key=AIzaSyD8xUQrF94KOD_07X9uciOaC7iTfLO_y_M


import Foundation
import MapKit

class WeatherData {
    
    static let sharedInstance = WeatherData()
    
    private init()
    {
        self.humidity = 78/100
        self.temperatureF = 59
        self.pressure = 29.53
        self.windSpeed = 0
        self.windDirection = 0
    }
    
    //JSON Weather DATA Url, UPDated through setURL() function
    var url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=34.67558593&lon=-82.8350379&&APPID=f876abf1b6b68c7d99b1f283568fb680")
    
    //Elevation Of user JSON DATA
    var alturl = URL(string: "http://maps.googleapis.com/maps/api/elevation/json?locations=39.7391536,-104.9847034&sensor=false" )
    
    var OpenWeatherKey = ""
    
    var GoogleElevationKey = ""
    
    //This is the JSON URL CALL Return Value
    var jsonResult: AnyObject!
    
    var latitude = "33.6"
    
    //Keep Track of Target Longitude Data Through This Variable
    var longitude = "78.8"
    
    //feet
    var altitude : Double = 0
    
    var targetAltitude : Double = 0
    
    //Keep Track of Humidity Data Through This Variable
    var humidity : Double //78/100
    
    //Keep Track of Temperature Data Through This Variable
    var temperatureF : Double  //59
    
    //Keep Track of Pressure Data Through This Variable
    var pressure : Double // default 29.53
    
    //Keep Track of WindSpeed Though This Variable
    var windSpeed : Double
    
    //Keep Track of Direction Through This Variable
    var windDirection : Double
    
    //Boolean that allows for constant GPS Update Or Not
    var liveupdate = Bool()
    
    //Serves as a function to call the correct json we
    func setUrl(userLat: String, userLon: String)
    {
        let u = "http://api.openweathermap.org/data/2.5/weather"
        let lat = "?lat="
        let lon = "&lon="
        let key = "&&APPID=f876abf1b6b68c7d99b1f283568fb680"
        _ = "&units=imperial"
        
        self.url = URL(string: u + lat + (userLat) + lon + (userLon) + key + OpenWeatherKey)!
        
        self.latitude = (userLat)
        self.longitude = (userLon)
       
        let alt = "https://maps.googleapis.com/maps/api/elevation/json?locations="
        let sens = "&sensor=false"
        let keyalt = "&key=AIzaSyD8xUQrF94KOD_07X9uciOaC7iTfLO_y_M"
        
        self.alturl = URL(string: alt + userLat + "," + userLon + sens + keyalt)!
    }
    
    //Initialize or set All Global Variables According to the JSON Data NSDictionary
    func initVars(json: [String:AnyObject]){
        
        self.latitude = String(describing: json["coord"]!["lat"]!!)
        self.longitude = String(describing: json["coord"]!["lon"]!!)
        if(json["main"] != nil){
            if (json["main"]!["humidity"] != nil)
            {
                self.humidity = Double(String(describing: json["main"]!["humidity"]!!))!
            }
            else
            {
                self.humidity = 78/100
            }
            
            if (json["main"]!["pressure"] != nil)
            {
                let prs = Double(String(describing: json["main"]!["pressure"]!!))// Conversion to Hg
                self.pressure = prs! * 0.030
            }
            else
            {
                self.pressure = 29.53
            }
            
            if (json["wind"]!["deg"] != nil && json["wind"] != nil && json["wind"]!["deg"]! != nil)
            {
                self.windDirection = Double(String(describing: json["wind"]!["deg"]!!))!
            }
            else
            {
                self.windDirection = 0
            }
            if (json["wind"]!["deg"] != nil && json["wind"] != nil && json["wind"]!["deg"]! != nil)
            {
                self.windSpeed = Double(String(describing: json["wind"]!["speed"]!!))!
            }
            else
            {
                self.windSpeed = 0
            }
            if (json["main"]!["temp"] != nil){
                let str = (String(describing: json["main"]!["temp"]!!))
                let kelvin = Double(str)
                let rankin = kelvin! * 9/5
                let celcius = rankin * 9/5 - 273.15
                let farenheit = rankin - 459.67
                //let far = String(format:"%.2f",farenheit)
                //let cel = String(format:"%.2f",celcius)
                self.temperatureF = farenheit
            }
            else
            {
                self.temperatureF = 59

            }
        }
        else
        {
            initInvalid()
        }
    }
    
    //Initialize or set All Global Variables According to the JSON Data NSDictionary
    func initElevation(json: [String: AnyObject])
    {
        let result = json["results"]! as! NSArray
        let array0 = result[0] as! NSDictionary
        var elevation = (array0["elevation"]!) as! Double
        elevation = (elevation * 1.09361) * 3
        self.altitude = elevation
        
//            let result = json["results"]![0] as! NSDictionary
//            var elevation = (result["elevation"]!) as! Double
//            elevation = (elevation * 1.09361) * 3
//            self.altitude = elevation
    }
    
    //If Weather Data Is Down Send Error Message to App
    func initInvalid(){
        self.humidity = 78/100
        self.pressure = 29.53
        self.windDirection = 0
        self.windSpeed = 0
        self.temperatureF = 59
    }
    
    func initAltInvalid()
    {
       self.altitude = 0
    }
}
