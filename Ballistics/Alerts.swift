//
//  Alerts.swift
//  Ballistics
//
//  Created by Richard Padgett on 1/13/18.
//  Copyright © 2018 Richard-Padgett. All rights reserved.
//

import Foundation
import UIKit

// Alerts
// *************************************************************************
// Distance Missing Alert
func alertEnterDistance(_ sender: ViewController)
{
    let alert = UIAlertController(title: "Distance Setting", message: "Enter a number for distance in menu.", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler:
        {
            action in
            if(sender.leadingC.constant == 0 )
            {
                sender.operateMenuButton()
            }
    }))
    
    sender.present(alert, animated: true)
}

// Distance Missing Alert
func angleAlert(_ sender: ViewController)
{
    let ballisticCalculator = BallisticCalculator.sharedInstance
    var altitudeDesc : String
    if(ballisticCalculator.angleCorrection)
    {
        altitudeDesc = "On"
       // sender.altitudeButton.tintColor = sender.view.tintColor
    }
    else
    {
        altitudeDesc = "Off"
       // sender.altitudeButton.tintColor = UIColor.red
        
    }
    let alert = UIAlertController(title: "", message: "Angle Correction " + altitudeDesc , preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
    
    sender.present(alert, animated: true)
}

// Environment on off Alert
func environmentAlert(_ sender: ViewController)
{
    let ballisticCalculator = BallisticCalculator.sharedInstance
    var environmentDesc : String
    if(ballisticCalculator.environmentOn)
    {
        environmentDesc = "Off"
       // sender.environmentButton.tintColor = sender.view.tintColor
    }
    else
    {
        environmentDesc = "On"
       // sender.environmentButton.tintColor = UIColor.red
    }
    let alert = UIAlertController(title: "", message: "Environment " + environmentDesc , preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
    
    sender.present(alert, animated: true)
}

func windOnOffAlert(_ sender: ViewController)
{
    var windDesc : String
    if(sender.windOn)
    {
        windDesc = "On"
       // sender.windButton.tintColor = sender.view.tintColor
    }
    else
    {
        windDesc = "Off"
       // sender.windButton.tintColor = UIColor.red
    }
    let alert = UIAlertController(title: "", message: "Wind " + windDesc, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
    
    sender.present(alert, animated: true)
}

// Bearing locked unlocked alert
func bearingLockedAlert(_ sender: ViewController)
{
    var bearingDesc : String
    if(sender.lockBearing)
    {
        bearingDesc = "Locked"
       // sender.compassButton.tintColor = UIColor.red
    }
    else
    {
        bearingDesc = "Unlocked"
        //sender.compassButton.tintColor = sender.view.tintColor
    }
    let alert = UIAlertController(title: "", message: "Bearing " + bearingDesc , preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
    
    sender.present(alert, animated: true)
}

// Distance Missing Alert
func microphoneAlert(_ sender: ViewController)
{
    var microphoneDesc : String
    if(sender.microphoneOn)
    {
        microphoneDesc = "On"
       // sender.microphoneButton.tintColor = UIColor.red
    }
    else
    {
        microphoneDesc = "Off"
       // sender.microphoneButton.tintColor = sender.view.tintColor
    }
    let alert = UIAlertController(title: "Microphone " + microphoneDesc, message: "Do not leave microphone on while not in use.\n" +
            "Tap the map to toggle microphone without alerts.", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
    
    sender.present(alert, animated: true)
    
}

// Ballistics data popup alert
func alertBallistics(_ sender: ViewController)
{
    let ballisticCalculator = BallisticCalculator.sharedInstance
    var message : String

    if(!ballisticCalculator.results.isEmpty)
    {
        if(ballisticCalculator.results[0] == 0)
        {
            message = "Target is out of range"
        }
        else
        {
            message = //"(Corrected BC) "       +   String(format: "%.3lf", ballisticCalculator.correctedBallisticCoefficient)
                   "Range (Yds) "       +   String(format: "%d", Int32(ballisticCalculator.results[0]))
                 + "\nHypotenuse (Yds) "       +   String(format: "%d", Int32(ballisticCalculator.hypotenuseYards))
                 + "\nEnergy (ft-lb)"      +   String(format: "%d",(Int(ballisticCalculator.results[9])))
                 + "\nVelocity (ft/s)"     +   String(format: "%.2lf", ballisticCalculator.results[6])
                 + "\nTime (s)"            +   String(format: "%.2lf", ballisticCalculator.results[3])
                 + "\nAngle (\u{00b0})"     +   String(format: "%.2lf", ballisticCalculator.shotAngle)
                 + "\nHeight (yds)"           +   String(format: "%.2lf", ballisticCalculator.riseInElevation)
                 + "\nDrop (in)"           +   String(format: "%.2lf", ballisticCalculator.results[1])
                 + "\nDrop (MoA)"          +   String(format: "%.2lf", ballisticCalculator.results[2])
                 + "\nWind (in)"           +   String(format: "%.2lf", ballisticCalculator.results[4])
                 + "\nWind (MoA)"          +   String(format: "%.2lf", ballisticCalculator.results[5])
           
        }
        let alert = UIAlertController(title: "Ballistics", message: message, preferredStyle: .alert)
    
        alert.addAction(UIAlertAction(title: "Got It", style: .default, handler: nil))
    
        sender.present(alert, animated: true)
    }
}

extension String {
    func stringByLeftPaddingTo(length newLength : Int) -> String {
        let length = self.characters.count
        if length < newLength {
            // Prepend `newLength - length` space characters:
            return String(repeating: " ", count: newLength - length) + self
        } else {
            // Truncate to the rightmost `newLength` characters:
            return self.substring(from: self.index(endIndex, offsetBy: -newLength))
        }
    }
}
