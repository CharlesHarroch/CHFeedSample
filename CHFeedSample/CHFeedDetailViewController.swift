//
//  CHFeedDetailViewController.swift
//  CHFeedSample
//
//  Created by Charles HARROCH on 03/05/2016.
//  Copyright © 2016 Charles HARROCH. All rights reserved.
//

import UIKit

class CHFeedDetailViewController: UIViewController {
    
    @IBOutlet weak var titleFeed : UILabel!
    @IBOutlet weak var dateFeed : UILabel!
    @IBOutlet weak var detailFeed : UIWebView!
    @IBOutlet weak var imageFeed : UIImageView!
    
    @IBOutlet weak var detailWebviewHeight : NSLayoutConstraint!

    // Constraint to animate header
    @IBOutlet var newsHeaderOffset : NSLayoutConstraint!
    @IBOutlet var newsHeaderHeight : NSLayoutConstraint!
    
    var currentFeed : Feed!
    var pageIndex : NSInteger! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        populateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func populateUI() {
        
        // Apply CSS to format content detail
        let contentString = "<style type='text/css'>img{display: block; margin: auto auto;}body{font-family: 'Helvetica Neue', Helvetica;}</style>" + currentFeed.detail!
        
        // Load Image
        if (currentFeed.imageURL == nil || currentFeed.imageURL?.characters.count == 0 ) {
            self.newsHeaderHeight.constant = 0
            self.view.layoutIfNeeded()
        } else {
            self.imageFeed.af_setImageWithURL(NSURL(string: currentFeed.imageURL!)!)
        }
        
        // Set Story data
        self.titleFeed.text = currentFeed.title
        self.dateFeed.text = currentFeed.publicationDate?.toString(nil, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle, inRegion: nil, relative: true)
        
        // Remove zoom on uiwebview
        self.detailFeed.scrollView.maximumZoomScale = 1.0;
        self.detailFeed.scrollView.minimumZoomScale = 1.0;
        
        self.detailFeed.delegate = self
        self.detailFeed.alpha = 0
        self.detailFeed.loadHTMLString(contentString, baseURL: nil)
    }
    
    deinit {
        self.imageFeed.af_cancelImageRequest()
    }
}

extension CHFeedDetailViewController : UIWebViewDelegate {
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        // Resize UIWebView with content height
        self.detailFeed.scrollView.bounces = false
        self.detailWebviewHeight.constant = self.detailFeed.scrollView.contentSize.height
        self.view.layoutIfNeeded()
        
        UIView.animateWithDuration(0.2) {
            self.detailFeed.alpha = 1
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        // Open touched link in safari
        if navigationType == UIWebViewNavigationType.LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        return true
    }
}

extension CHFeedDetailViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if (offset > 0) {
            self.newsHeaderOffset.constant = -(offset / 4)
            self.imageFeed.layoutIfNeeded()
        } else {
            self.newsHeaderOffset.constant = 0
            self.imageFeed.layoutIfNeeded()
        }
    }
}