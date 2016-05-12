//
//  XMLParserManager.swift
//  CHFeedSample
//
//  Created by Charles HARROCH on 03/05/2016.
//  Copyright © 2016 Charles HARROCH. All rights reserved.
//

import Foundation
import Alamofire
import MagicalRecord

class XMLParserManager : NSObject {
    
    static let sharedInstance = XMLParserManager()
    
    private var xmlParser: NSXMLParser!
    private var feeds : Array<(title: String, link: String, detail: String, date: String)>!
    
    private var currentItem : (title: String, link: String, detail: String, date: String)!
    private var currentElement, currentTitle, currentDate, currentdetail, currentLink : String!
    
    func loadFeed() {
        xmlParser = NSXMLParser(contentsOfURL: NSURL(string: Constants.Network.BASE_URL)!)
        xmlParser.delegate = self
        feeds = Array()
        xmlParser.parse()
    }
}

extension XMLParserManager : NSXMLParserDelegate {
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
        // New item find, instanciate new item
        if elementName == "item" {
            self.currentItem = (title: "", link: "", detail: "", date: "")
            currentTitle = String()
            currentdetail = String()
            currentDate = String()
            currentLink = String()
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // update item with data and add to collection
        if elementName == "item" {
            currentItem.title = currentTitle
            currentItem.link = currentLink
            currentItem.detail = currentdetail
            currentItem.date = currentDate
            feeds.append(currentItem)
        }
        
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        // Save the characters for the current item. Filter \n for title and date
        if currentElement == "title" && currentTitle != nil {
            for character in string.characters {
                if (character != "\n") {
                    currentTitle.appendContentsOf("\(character)")
                }
            }
        } else if (currentElement == "link" && currentLink != nil) {
            currentLink.appendContentsOf(string)
        } else if (currentElement == "description" && currentdetail != nil) {
            currentdetail.appendContentsOf(string)
        } else if (currentElement == "pubDate" && currentDate != nil) {
            for character in string.characters {
                if (character != "\n") {
                    currentDate.appendContentsOf("\(character)")
                }
            }
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        for currentFeed in feeds {
            // Save Feeds in CoreData
            MagicalRecord.saveWithBlock({ (context) in
                Feed.initFeed(title: currentFeed.title, date: currentFeed.date, link: currentFeed.link, detail: currentFeed.detail, inContext: context)
            })
        }
    }
}