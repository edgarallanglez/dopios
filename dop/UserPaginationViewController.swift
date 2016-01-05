//
//  UserPaginationViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/23/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class UserPaginationViewController: UICollectionViewCell, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var userPageViewController: UIPageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    
    var index: Int = 0
    
    var parentViewController: UICollectionViewController!
    
    var activity_view: UIViewController!
    var badges_view: UIViewController!
    var connections_view: UIViewController!
    
    var dynamic_height: CGFloat!
    var identifiers: NSArray = ["ActivityPage", "BadgesPage", "ConnectionsPage"]
    
    override func setNeedsLayout() {
        self.userPageViewController.view.frame.size.width = UIScreen.mainScreen().bounds.width
        self.userPageViewController.view.frame.size.height = dynamic_height
    }
    
    func setPaginator(viewController: UICollectionViewController) {
        print("entre al paginator")
        parentViewController = viewController
        
        self.userPageViewController.dataSource = self
        self.userPageViewController.delegate = self
        
        activity_view = viewControllerAtIndex(0)
        badges_view = viewControllerAtIndex(1)
        connections_view = viewControllerAtIndex(2)
        
        dynamic_height = activity_view.view.frame.height
    
        let viewControllers: [UIViewController] = [activity_view]
        
        self.userPageViewController.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
        
        self.contentView.addSubview(self.userPageViewController.view)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setSize:", name: "PageLoaded", object: nil)
        
    }
    
    func setSize(notification: NSNotification) {
        let view = notification.object!
        dynamic_height = view.frame.size.height
        NSNotificationCenter.defaultCenter().postNotificationName("ResizeCell", object: dynamic_height)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        switch viewController.title! {
            case "activityPage": return nil
            case "badgesPage": self.index = 0
            case "connectionsPage": self.index = 1
        default: return nil
        }

        setNeedsLayout()
        return self.viewControllerAtIndex(self.index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        switch viewController.title! {
            case "activityPage": self.index = 1
            case "badgesPage": self.index = 2
            case "connectionsPage": return nil
        default: return nil
        }
        
        setNeedsLayout()
        return self.viewControllerAtIndex(self.index)

    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("InvalidateLayout", object: nil)
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
    }

    func viewControllerAtIndex(index: Int) -> UIViewController?{
        //first view controller = firstViewControllers navigation controller
        
        switch index {
        case 0:
            let viewController = parentViewController.storyboard!.instantiateViewControllerWithIdentifier("ActivityPage") as! ActivityPage
            return viewController
        case 1:
            let viewController = parentViewController.storyboard!.instantiateViewControllerWithIdentifier("BadgesPage") as! BadgesPage
            return viewController
        case 2:
            let viewController = parentViewController.storyboard!.instantiateViewControllerWithIdentifier("ConnectionsPage") as! ConnectionsPage
            return viewController
            
        default:
            return UIViewController()
        }
    }

}
