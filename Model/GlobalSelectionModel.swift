//
//  GlobalSelectionModel.swift
//  DropZero-P3
//
//  Created by Richard Padgett on 9/30/16.
//  Copyright © 2016 Richard-Padgett. All rights reserved.
//

import UIKit

class GlobalSelectionModel: NSObject {
    
    static var Results : [Double] = []
    static var DragFunctions : [String] = ["G1", "G2", "G5", "G6", "G7", "G8"]
    static var DragFunc : Int = 1
    static var weaponID = 0
    static var ammunitionID = 0
    static var profileID = 0
    static var weaponTypeID = 0
    static var ammunitionTypeID = 0
    static var resetVar = false
    static var loadedA = false
    static var loadedAT = false
    
    static var trueNorth: Double = 0
    
    static var at = Bool()
    static var a = Bool()
    static var wt = Bool()
    static var w = Bool()
    static var aw = Bool()
    
    static var imperial = true
    
    static var timer : Double = 0.0
    
    static var profileName = String()
    static var ammunitionName = String()
    static var ammunitionType = String()
    static var ammunitionWeight = Int()
    static var ballisticCoefficient = Double()
    static var weaponName = String()
    static var weaponType = String()
    static var muzzleVelocity = Int()
    static var zeroRange = Int()
    static var chronograph = Int()
    static var sightHeight = Double()
    
    static var maxDB : Double = 0
    
    static var popUpRangeFinder = "NaN"
    static var popUpDistance = "NaN"
    static var popUpMoA = "NaN"
    static var popUpWMoA = "NaN"
    
    static func reset(){
        ammunitionName = ""
        ammunitionType = ""
        ammunitionWeight = 0
        ballisticCoefficient = 0
        muzzleVelocity = 0
        weaponName = ""
        weaponType = ""
        resetVar = false
        
    }
}
