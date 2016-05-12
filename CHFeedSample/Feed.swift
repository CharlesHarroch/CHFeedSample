//
//  Feed.swift
//  CHFeedSample
//
//  Created by Charles HARROCH on 03/05/2016.
//  Copyright © 2016 Charles HARROCH. All rights reserved.
//

import Foundation
import CoreData
import MagicalRecord
import SwiftDate

class Feed: NSManagedObject {
    
    static func initFeed(title title: String!, date: String!, link: String!, detail: String!, inContext context: NSManagedObjectContext!) {
        
        let feed = Feed.MR_findFirstOrCreateByAttribute("title", withValue: title, inContext: context)
        
        if let tTitle = title {
            feed.title = tTitle
        }
        
        if var tDate = date {
            
            if (tDate.characters.last == " ") {
                tDate = date.substringToIndex(date.endIndex.predecessor())
            }

            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZZ"
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            feed.publicationDate = dateFormatter.dateFromString(tDate)
        }
        
        if let tLink = link {
            feed.link = tLink
        }
        
        if let tDetail = detail {
            feed.detail = tDetail
        }
        
        extractImages(detail, feed: feed)
    }
    
    static func extractImages(paramhtml: NSString, feed: Feed) {
        
        // Extract images from <img> tag within the <content> cDATA block
        let regex = try? NSRegularExpression(pattern: "(<img\\s[\\s\\S]*?src\\s*?=\\s*?[\'\"](.*?)[\'\"][\\s\\S]*?>)+?", options: .CaseInsensitive)
        
        let nsRange : NSRange = NSRange(location: 0, length: paramhtml.length)
        regex!.enumerateMatchesInString(paramhtml as String, options: NSMatchingOptions.ReportCompletion, range: nsRange) { (result, flags, stop) -> Void in
            if (result != nil){
                let img = paramhtml.substringWithRange(result!.rangeAtIndex(2));
                feed.imageURL = img
            }
        };
        
    }
    
}
