//
//  CHFeedListViewController.swift
//  CHFeedSample
//
//  Created by Charles HARROCH on 03/05/2016.
//  Copyright © 2016 Charles HARROCH. All rights reserved.
//

import UIKit
import AlamofireImage
import CoreData

class CHFeedListViewController: UIViewController {
    
    @IBOutlet weak var tableview : UITableView!
    
    var refreshControl: UIRefreshControl!
    var pageViewController : CHFeedPageViewController!
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Feed")
        let sortDescriptor = NSSortDescriptor(key: "publicationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: NSManagedObjectContext.MR_defaultContext(), sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBarAppearace()
        
        // Add pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(CHFeedListViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        tableview.addSubview(refreshControl)
        
        XMLParserManager.sharedInstance.loadFeed()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        do {
            try self.fetchedResultsController.performFetch()
            self.tableview.reloadData()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    }
    
    private func setNavigationBarAppearace() {
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.barTintColor = Constants.Color.navigationBackgroundColor
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "show_feed_detail") {

            let indexPath = sender as! NSIndexPath
            self.pageViewController = segue.destinationViewController as! CHFeedPageViewController
            self.pageViewController.dataSource = self
            
            let startingViewController = self.viewControllerAtIndex(indexPath.row)
            startingViewController?.currentFeed = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Feed
            var controllers = Array<CHFeedDetailViewController>()
            controllers.append(startingViewController!)
            self.pageViewController.setViewControllers(controllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        }
    }
    
    func refresh(sender:AnyObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            XMLParserManager.sharedInstance.loadFeed()
            dispatch_async(dispatch_get_main_queue(), {
                self.refreshControl.endRefreshing()
            })
        })
    }
}

extension CHFeedListViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CHFeedTableViewCell", forIndexPath: indexPath) as! CHFeedTableViewCell
        configureCell(cell, atIndexPath: indexPath);
        return cell
    }
    
    func configureCell(cell: CHFeedTableViewCell, atIndexPath indexPath: NSIndexPath) {
        // Fetch Record
        let record = fetchedResultsController.objectAtIndexPath(indexPath) as! Feed
        cell.feedTitle.text = record.title
        if (record.imageURL != nil && record.imageURL?.characters.count > 0) {
            cell.feedImage.af_setImageWithURL(NSURL(string: record.imageURL!)!)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("show_feed_detail", sender: indexPath)
    }
}

extension CHFeedListViewController : NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableview.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableview.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tableview.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                tableview.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            if let indexPath = indexPath {
                let cell = tableview.cellForRowAtIndexPath(indexPath) as! CHFeedTableViewCell
                configureCell(cell, atIndexPath: indexPath)
            }
            break;
        case .Move:
            if let indexPath = indexPath {
                tableview.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableview.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break;
        }
    }
}

extension CHFeedListViewController : UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! CHFeedDetailViewController).pageIndex;
        if ((index == 0) || (index == NSNotFound)) {
            return nil;
        }
        index = index - 1
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! CHFeedDetailViewController).pageIndex;
        if (index == NSNotFound) {
            return nil;
        }
        index = index + 1
        if (index == self.fetchedResultsController.fetchedObjects!.count) {
            return nil;
        }
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index : NSInteger) -> CHFeedDetailViewController? {
        if ((self.fetchedResultsController.fetchedObjects!.count == 0) || (index >= self.fetchedResultsController.fetchedObjects!.count)) {
            return nil;
        }
        
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CHFeedDetailViewController") as! CHFeedDetailViewController
        
        pageContentViewController.currentFeed = self.fetchedResultsController.objectAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) as! Feed
        pageContentViewController.pageIndex = index;
        return pageContentViewController;
    }
}



