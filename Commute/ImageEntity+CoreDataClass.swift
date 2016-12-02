//
//  ImageEntity+CoreDataClass.swift
//  Commute
//
//  Created by Boris Yurkevich on 01/12/2016.
//  Copyright © 2016 Boris Yurkevich. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(ImageEntity)
public class ImageEntity: NSManagedObject {
    
    func getImage() -> UIImage? {
        return UIImage(data: self.image as! Data)
    }
    
    func set(image: UIImage) {
        self.image = UIImageJPEGRepresentation(image, 1.0) as NSData?
    }
}
