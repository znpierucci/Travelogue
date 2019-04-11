//
//  Entry+CoreDataClass.swift
//  TravelogueFinal
//
//  Created by Zachary Pierucci on 4/11/19.
//  Copyright © 2019 Zachary Pierucci. All rights reserved.
//
//

import UIKit
import CoreData

@objc(Entry)
public class Entry: NSManagedObject {

    var modifiedDate: Date? {
        get {
            return date as Date?
        }
        set {
            date = newValue as NSDate?
        }
    }
    
    var imageModified: UIImage? {
        get {
            if let imageData = image as Data? {
                return UIImage(data: imageData)
            } else {
                return nil
            }
        }
        set {
            if let imageModified = newValue {
                image = convertImageToNSData(image: imageModified)
            }
        }
    }
    
    convenience init?(title: String?, content: String?, date: Date, image: UIImage?, trip: Trip) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let managedContext = appDelegate?.persistentContainer.viewContext,
            let title = title, title != "" else {
                return nil
        }
        
        self.init(entity: Entry.entity(), insertInto: managedContext)
        
        self.title = title
        self.content = content
        self.modifiedDate = date
        self.trip = trip
        if let image = image {
            self.image = convertImageToNSData(image: image)
        }
    }
    
    func convertImageToNSData(image: UIImage) -> NSData? {
        return processImage(image: image).pngData() as NSData?
    }
    
    func processImage(image: UIImage) -> UIImage {
        if (image.imageOrientation == .up) {
            return image
        }
        
        UIGraphicsBeginImageContext(image.size)
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size), blendMode: .copy, alpha: 1.0)
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        guard let unwrappedCopy = copy else {
            return image
        }
        
        return unwrappedCopy
    }
    
    func update(title: String, content: String?, date: Date, image: UIImage?, trip: Trip) {
        self.title = title
        self.content = content
        self.modifiedDate = date
        self.trip = trip
        if let image = image {
            self.image = convertImageToNSData(image: image)
        }
    }
    
}
