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
func altitudeAlert(_ sender: ViewController)
{
    var altitudeDesc : String
    if(sender.getBallisticsBrain().altitudeOn)
    {
        altitudeDesc = "On"
        sender.altitudeButton.tintColor = sender.view.tintColor
    }
    else
    {
        altitudeDesc = "Off"
        sender.altitudeButton.tintColor = UIColor.red
        
    }
    let alert = UIAlertController(title: "Altitude On/Off", message: "Altitude is set to " + altitudeDesc , preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
    
    sender.present(alert, animated: true)
}

// Environment on off Alert
func environmentAlert(_ sender: ViewController)
{
    var environmentDesc : String
    if(sender.getBallisticsBrain().environmentOn)
    {
        environmentDesc = "On"
        sender.environmentButton.tintColor = sender.view.tintColor
    }
    else
    {
        environmentDesc = "Off"
        sender.environmentButton.tintColor = UIColor.red
    }
    let alert = UIAlertController(title: "Environment On/Off", message: "Environment is set to " + environmentDesc , preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
    
    sender.present(alert, animated: true)
}

// Bearing locked unlocked alert
func bearingLockedAlert(_ sender: ViewController)
{
    var bearingDesc : String
    if(sender.lockBearing)
    {
        bearingDesc = "Unlocked"
        sender.compassButton.tintColor = sender.view.tintColor
    }
    else
    {
        bearingDesc = "Locked"
        sender.compassButton.tintColor = UIColor.red
    }
    let alert = UIAlertController(title: "Bearing Locked/Unlocked", message: "Bearing is set to " + bearingDesc , preferredStyle: .alert)
    
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
        sender.microphoneButton.tintColor = sender.view.tintColor
    }
    else
    {
        microphoneDesc = "Off"
        sender.microphoneButton.tintColor = UIColor.red
    }
    let alert = UIAlertController(title: "Turn On/Off Microphone", message: "Microphone is set to " + microphoneDesc , preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
    
    sender.present(alert, animated: true)
    
}

// Ballistics data popup alert
func alertBallistics(_ sender: ViewController)
{
    var message : String
    if(!sender.getBallisticsBrain().results.isEmpty)
    {
        if(sender.getBallisticsBrain().results[0] == 0)
        {
            message = "Target is out of range"
        }
        else
        {
            message = String(sender.getBallisticsBrain().bc) + " BC\n"
                +   String(format: "%.2lf", sender.getBallisticsBrain().results[0]) + " Range (Yds)\n"
                +   String(format: "%.2lf", sender.getBallisticsBrain().results[1]) + " Drop  (in)\n"
                +   String(format: "%.2lf", sender.getBallisticsBrain().results[2]) + " Drop  (MoA)\n"
                +   String(format: "%.2lf", sender.getBallisticsBrain().results[6]) + " Velocity  (ft/s)\n"
                +   String(format: "%.2lf", sender.getBallisticsBrain().results[4]) + " Wind  (in)\n"
                +   String(format: "%.2lf", sender.getBallisticsBrain().results[5]) + " Wind  (MoA)\n"
                +   String(format: "%d",(Int(sender.getBallisticsBrain().results[9]))) + " Energy  (ft-lb)\n"
                +   String(format: "%.2lf", sender.getBallisticsBrain().results[3]) + " Time  (s)\n"
        }
        let alert = UIAlertController(title: "Ballistics", message: message, preferredStyle: .alert)
    
        alert.addAction(UIAlertAction(title: "Got It", style: .default, handler: nil))
    
        sender.present(alert, animated: true)
    }
}
