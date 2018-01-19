//
//  BallisticData.swift
//  Ballistics
//
//  Created by Richard Padgett on 1/19/18.
//  Copyright © 2018 Richard-Padgett. All rights reserved.
//

import Foundation
import CoreData

class BallisticData
{
    var appDeligate : AppDelegate
    var context : NSManagedObjectContext
    var ballisticsEntityDescription : NSEntityDescription?
    var ballisticsEntity : NSManagedObject

    private init()
    {
        self.appDeligate = UIApplication.shared.delegate as! AppDelegate
        self.context = appDeligate.persistentContainer.viewContext
        self.ballisticsEntityDescription = NSEntityDescription.entity(forEntityName: "BallisticSettings", in: context)
        self.ballisticsEntity = NSManagedObject(entity: ballisticsEntityDescription!, insertInto: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BallisticSettings")
        request.returnsObjectsAsFaults = false
        
        getCoreData(request: request)
    }

    func getCoreData(request: NSFetchRequest<NSFetchRequestResult>)
    {
        var list : [NSManagedObject] = []
        do
        {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject]
            {
                list.append(data)
            }
        }
        catch
        {
            print("Failed")
        }
        
        if(list.count > 1)
        {
            let sorted = list.sorted { (first, second) -> Bool in
                if first.value(forKey: "date") as! Double > second.value(forKey: "date") as! Double
                {
                    return true
                }
                return false
            }
            
            print("Sorted: " + String(describing: sorted))
            
            let subarray = sorted[1 ... sorted.count - 1]
            for item in subarray
            {
                context.delete(item)
                appDeligate.saveContext()
            }
            ballisticsEntity = sorted[0]
            appDeligate.saveContext()
            self.distanceYds = ballisticsEntity.value(forKey: "distanceYds") as! Double
            self.distinMeters = distanceYds / 1.09361
            self.bc = ballisticsEntity.value(forKey: "ballisticCoefficient") as! Double
            self.v = ballisticsEntity.value(forKey: "muzzleVelocity") as! Double
            self.sh = ballisticsEntity.value(forKey: "sightHeight") as! Double
            self.projectileWeight = Int(ballisticsEntity.value(forKey: "weight") as! Double)
            self.zero = ballisticsEntity.value(forKey: "zeroRange") as! Double
        }
        else if(list.count != 0)
        {
            ballisticsEntity = list[0]
        }
    }
}
