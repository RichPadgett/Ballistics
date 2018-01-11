//
//  MapBrain.swift
//  Ballistics
//
//  Created by Richard Padgett on 1/11/18.
//  Copyright © 2018 Richard-Padgett. All rights reserved.
//

import Foundation

struct MapBrain
{
    func performOperation(buttonTitle: String)
    {
        switch buttonTitle
        {
        case "SetTarget":
            print("pressed target button")
        case "SetEnvironment":
            print("pressed environment button")
        case "SetBearing":
            print("pressed bearing button")
        case "SetAltitude":
            print("pressed altitude button")
        case "SetMicrophone":
            print("pressed microphone button")
        default:
            break
        }
        
        
    }
}
