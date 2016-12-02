//
//  ImageEntity+CoreDataProperties.swift
//  Commute
//
//  Created by Boris Yurkevich on 01/12/2016.
//  Copyright © 2016 Boris Yurkevich. All rights reserved.
//

import Foundation
import CoreData


extension ImageEntity {

    public class func imageFetchRequest() -> NSFetchRequest<ImageEntity> {
        return NSFetchRequest<ImageEntity>(entityName: "ImageEntity");
    }

    @NSManaged public var id: Int64
    @NSManaged public var image: NSData?
    @NSManaged public var type: Int16

}
