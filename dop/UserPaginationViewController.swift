//
//  UserPaginationViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/23/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

@objc protocol UserPaginationDelegate {
    optional func resizeView(new_height: CGFloat)
    
    optional func setSegmentedIndex(index: Int)
}

class UserPaginationViewController: UICollectionViewCell, UIPageViewControllerDataSource, UIPageViewControllerDelegate, SetSegmentedPageDelegate, ActivityPageDelegate, BadgePageDelegate, ConnectionsPageDelegate, UIScrollViewDelegate {
    
    var delegate: UserPaginationDelegate?
    var userPageViewController: UIPageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    
    var index: Int = 0
    
    var parentViewController: UserProfileStickyController!
    
    var activity_view: UIViewController!
    var badges_view: UIViewController!
    var connections_view: UIViewController!
    
    var dynamic_height: CGFloat!
    var identifiers: NSArray = ["ActivityPage", "BadgesPage", "ConnectionsPage"]
    
    override func setNeedsLayout() {
        self.userPageViewController.view.frame.size.width = UIScreen.mainScreen().bounds.width
        self.userPageViewController.view.frame.size.height = dynamic_height
    }
    
    func resizeActivityView(dynamic_height: CGFloat) {
        self.dynamic_height = dynamic_height
        setNeedsLayout()
        delegate?.resizeView!(dynamic_height)
    }
    
    func resizeBadgeView(dynamic_height: CGFloat) {
        self.dynamic_height = dynamic_height
        delegate?.resizeView!(dynamic_height)
    }
    
    func resizeConnectionsSize(dynamic_height: CGFloat) {
        self.dynamic_height = dynamic_height
        delegate?.resizeView!(dynamic_height)
    }
    
    
    func setPaginator(viewController: UserProfileStickyController) {
        
        parentViewController = viewController
        parentViewController.delegate = self
        self.userPageViewController.dataSource = self
        self.userPageViewController.delegate = self
        
        activity_view = viewControllerAtIndex(0)
        dynamic_height = activity_view.view.frame.height
    
        let viewControllers: [UIViewController] = [activity_view]
        
        self.userPageViewController.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
        
        self.contentView.addSubview(self.userPageViewController.view)

//        self.userPageViewController.scroll
//        self.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRectMake(0, 0, 24, 24))
//        self.tableView.infiniteScrollIndicatorMargin = 40
//        
//        tableView.addInfiniteScrollWithHandler { [weak self] (scrollView) -> Void in
//            if(!self!.activity_array.isEmpty){
//                self!.getActivityWithOffset()
//            }
//        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        switch viewController.title! {
            case "activityPage": return nil
            case "badgesPage": self.index = 0
            case "connectionsPage": self.index = 1
        default: return nil
        }

        return self.viewControllerAtIndex(self.index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        switch viewController.title! {
            case "activityPage": self.index = 1
            case "badgesPage": self.index = 2
            case "connectionsPage": return nil
        default: return nil
        }

        return self.viewControllerAtIndex(self.index)

    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if !completed {
            let viewController = pageViewController.viewControllers!.first!
            var index = 0
            switch viewController.title! {
                case "activityPage": index = 0
                case "badgesPage": index = 1
                case "connectionsPage": index = 2
            default: index = 0
            }
            delegate?.setSegmentedIndex!(index)
        }
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        let viewController = pendingViewControllers.first!
        var index = 0
        switch viewController.title! {
            case "activityPage": index = 0
            case "badgesPage": index = 1
            case "connectionsPage": index = 2
        default: index = 0
        }
        
        delegate?.setSegmentedIndex!(index)
    }

    func viewControllerAtIndex(index: Int) -> UIViewController?{
        //first view controller = firstViewControllers navigation controller
        
        switch index {
        case 0:
            let viewController = parentViewController.storyboard!.instantiateViewControllerWithIdentifier("ActivityPage") as! ActivityPage
            viewController.delegate = self
            viewController.parent_view = self.parentViewController
            return viewController
        case 1:
            let viewController = parentViewController.storyboard!.instantiateViewControllerWithIdentifier("BadgesPage") as! BadgesPage
            viewController.delegate = self
            viewController.parent_view = self.parentViewController
            return viewController
        case 2:
            let viewController = parentViewController.storyboard!.instantiateViewControllerWithIdentifier("ConnectionsPage") as! ConnectionsPage
            viewController.delegate = self
            viewController.parent_view = self.parentViewController
            return viewController
            
        default:
            return UIViewController()
        }
    }
    
    func setPage(index: Int) {
        var direction: UIPageViewControllerNavigationDirection;
        
        if(index < self.index){ direction = .Reverse } else { direction = .Forward }
        var toViewController = self.viewControllerAtIndex(0)
        
        switch index {
        case 0:
            toViewController = self.viewControllerAtIndex(0)
            self.index = 0
        case 1:
            toViewController = self.viewControllerAtIndex(1)
            self.index = 1
        case 2:
            toViewController = self.viewControllerAtIndex(2)
            self.index = 2
        default:
            print("Default t")
        }
        
        let viewControllers: NSArray = [toViewController!]
        self.userPageViewController.setViewControllers(viewControllers as? [UIViewController], direction: direction, animated: true, completion: nil)
    }
    
    func launchInfiniteScroll(parent_scroll: UICollectionView) {
        let viewController = userPageViewController.viewControllers!.first!
//        var currentController: UIViewController?
        switch viewController.title! {
            case "activityPage": var currentController = viewController as! ActivityPage
                                    currentController.reloadWithOffset(parent_scroll)
            
            case "badgesPage": var currentController = viewController as! BadgesPage
                                    currentController.reloadWithOffset()
            
            case "connectionsPage": var currentController = viewController as! ConnectionsPage
                                    currentController.reloadWithOffset()
            
        default: var currentController = viewController as! ActivityPage
        }
    }

}
