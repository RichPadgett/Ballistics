//
//  LocationTranslation.swift
//  Ballistics
//
//  Created by Richard Padgett on 1/9/18.
//  Copyright © 2018 Richard-Padgett. All rights reserved.
//

import Foundation
import MapKit

public extension CLLocationCoordinate2D
{
    struct Constant
    {
        static let earthRadius : Double = 6378.1 //km
        
    }
    
    func DegtoRad(deg: Double) -> Double
    {
        return deg*Double.pi / 180
    }
    
    func RadtoDeg(rad: Double) -> Double{
        return rad*180/Double.pi
    }
    
    func translate(bearing: CLLocationDirection, distanceKm: Double) -> CLLocationCoordinate2D
    {
        let bearingDouble = DegtoRad(deg: Double(bearing))
        
        let lat1 = DegtoRad(deg: Double(self.latitude))
        let lon1 = DegtoRad(deg: Double(self.longitude))
        
        let radlat2 = asin(sin(lat1) * cos(distanceKm/Constant.earthRadius) + cos(lat1) * sin(distanceKm/Constant.earthRadius) * cos(bearingDouble))
        
        let radlon2 = lon1 + atan2(sin(bearingDouble) * sin(distanceKm/Constant.earthRadius) * cos(lat1), cos(distanceKm/Constant.earthRadius) - sin(lat1) * sin(radlat2))
        
        let lat2 = RadtoDeg(rad: radlat2)
        let lon2 = RadtoDeg(rad: radlon2)
        
        
        print("Lat2 : " + String(lat2))
        print("Lon2 : " + String(lon2))
        return CLLocationCoordinate2D(latitude: lat2, longitude: lon2)
    }
}
