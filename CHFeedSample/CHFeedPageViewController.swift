//
//  CHFeedPageViewController.swift
//  CHFeedSample
//
//  Created by Charles HARROCH on 03/05/2016.
//  Copyright © 2016 Charles HARROCH. All rights reserved.
//

import UIKit

class CHFeedPageViewController : UIPageViewController {
    var feeds : Array<Feed>!
    var index : NSInteger!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Feed Reader"
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
