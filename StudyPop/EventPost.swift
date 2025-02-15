//
//  EventPost.swift
//  StudyPop
//
//  Created by Nicholas Park on 6/28/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation
import CoreData


class EventPost: NSManagedObject {

    @NSManaged var name: String?
    @NSManaged var pretty: String?
    @NSManaged var thetype: NSNumber?
    @NSManaged var group: String?
    @NSManaged var user: String?
    @NSManaged var created: NSDate?
    @NSManaged var modified: NSDate?
    @NSManaged var likes: NSNumber?
    @NSManaged var flags: NSNumber?
    @NSManaged var seen: NSNumber?
    @NSManaged var safekey: String?
    var createdString:String?
    
    
    struct Keys{
        static let Name = "name"
        static let Info = "info"
        static let Pretty = "pretty"
        static let Created = "created"
        static let Modified = "modified"
        static let Likes = "likes"
        static let Flags = "flags"
        static let Group = "group"
        static let SafeKey = "safekey"
        static let User = "user"
        static let Seen = "seen"
        static let Body = "body"
        static let TheType = "thetype"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("EventPost", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        name = dictionary[Keys.Name] as? String
        pretty = dictionary[Keys.Pretty] as? String
        likes = dictionary[Keys.Likes] as? NSNumber
        seen = dictionary[Keys.Seen] as? NSNumber
        flags = dictionary[Keys.Flags] as? NSNumber
        user = dictionary[Keys.User] as? String
        group = dictionary[Keys.Group] as? String
        thetype = dictionary[Keys.TheType] as? NSNumber
        safekey = dictionary[Keys.SafeKey] as? String
        createdString = dictionary[Keys.Created] as? String
        
        if let startString = dictionary[Keys.Created] as? String{
            if let startDate = StudyPopClient.sharedDateFormatter.dateFromString(startString){
                created = startDate
            }
        }
        if let endString = dictionary[Keys.Modified] as? String{
            if let endDate = StudyPopClient.sharedDateFormatter.dateFromString(endString){
                modified = endDate
            }
        }
    }
    

}
