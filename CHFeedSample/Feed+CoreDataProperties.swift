//
//  Feed+CoreDataProperties.swift
//  CHFeedSample
//
//  Created by Charles HARROCH on 03/05/2016.
//  Copyright © 2016 Charles HARROCH. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Feed {

    @NSManaged var publicationDate: NSDate?
    @NSManaged var link: String?
    @NSManaged var title: String?
    @NSManaged var detail: String?
    @NSManaged var imageURL: String?
    @NSManaged var timeStamp: NSNumber?

}
