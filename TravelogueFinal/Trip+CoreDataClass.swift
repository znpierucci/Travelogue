//
//  Trip+CoreDataClass.swift
//  TravelogueFinal
//
//  Created by Zachary Pierucci on 4/11/19.
//  Copyright © 2019 Zachary Pierucci. All rights reserved.
//
//

import UIKit
import CoreData

@objc(Trip)
public class Trip: NSManagedObject {

    convenience init?(name: String?) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let managedContext = appDelegate?.persistentContainer.viewContext,
            let name = name, name != "" else {
                return nil
        }
        self.init(entity: Trip.entity(), insertInto: managedContext)
        self.name = name
    }
    
}
