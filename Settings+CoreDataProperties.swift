//
//  Settings+CoreDataProperties.swift
//  Jam
//
//  Created by Henri on 2020-02-12.
//  Copyright © 2020 Henrique Orlandin. All rights reserved.
//
//

import Foundation
import CoreData


extension Settings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Settings> {
        return NSFetchRequest<Settings>(entityName: "Settings")
    }

    @NSManaged public var notificationBandsMusicians: Bool
    @NSManaged public var notificationMessages: Bool
    @NSManaged public var privacyContactInfo: Bool

}
