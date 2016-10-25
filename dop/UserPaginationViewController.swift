//
//  UserPaginationViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/23/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

@objc protocol UserPaginationDelegate {
    @objc optional func resizeView(_ new_height: CGFloat)
    
    @objc optional func setSegmentedIndex(_ index: Int)
}

class UserPaginationViewController: UICollectionViewCell, UIPageViewControllerDataSource, UIPageViewControllerDelegate, SetSegmentedPageDelegate, ActivityPageDelegate, BadgePageDelegate, ConnectionsPageDelegate, UIScrollViewDelegate {
    
    var delegate: UserPaginationDelegate?
    var userPageViewController: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    var index: Int = 0
    
    var parentViewController: UserProfileStickyController!
    
    var activity_view: UIViewController!
    var badges_view: UIViewController!
    var connections_view: UIViewController!
    
    var dynamic_height: CGFloat!
    var identifiers: NSArray = ["ActivityPage", "BadgesPage", "ConnectionsPage"]
    
    override func setNeedsLayout() {
        self.userPageViewController.view.frame.size.width = UIScreen.main.bounds.width
        self.userPageViewController.view.frame.size.height = dynamic_height
    }
    
    func resizeActivityView(_ dynamic_height: CGFloat) {
        self.dynamic_height = dynamic_height
        setNeedsLayout()
        delegate?.resizeView!(dynamic_height)
    }
    
    func resizeBadgeView(_ dynamic_height: CGFloat) {
        self.dynamic_height = dynamic_height
        delegate?.resizeView!(dynamic_height)
    }
    
    func resizeConnectionsSize(_ dynamic_height: CGFloat) {
        self.dynamic_height = dynamic_height
        delegate?.resizeView!(dynamic_height)
    }
    
    
    func setPaginator(_ viewController: UserProfileStickyController) {
        
        parentViewController = viewController
        parentViewController.delegate = self
        self.userPageViewController.dataSource = self
        self.userPageViewController.delegate = self
        
        activity_view = viewControllerAtIndex(0)
        dynamic_height = activity_view.view.frame.height
    
        let viewControllers: [UIViewController] = [activity_view]
        
        self.userPageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        
        self.contentView.addSubview(self.userPageViewController.view)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        switch viewController.title! {
            case "activityPage": return nil
            case "badgesPage": self.index = 0
            case "connectionsPage": self.index = 1
        default: return nil
        }

        return self.viewControllerAtIndex(self.index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        switch viewController.title! {
            case "activityPage": self.index = 1
            case "badgesPage": self.index = 2
            case "connectionsPage": return nil
        default: return nil
        }

        return self.viewControllerAtIndex(self.index)

    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
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
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
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

    func viewControllerAtIndex(_ index: Int) -> UIViewController?{
        //first view controller = firstViewControllers navigation controller
        
        switch index {
        case 0:
            let viewController = parentViewController.storyboard!.instantiateViewController(withIdentifier: "ActivityPage") as! ActivityPage
            viewController.delegate = self
            viewController.parent_view = self.parentViewController
            viewController.parent_page_controller = self
            return viewController
        case 1:
            let viewController = parentViewController.storyboard!.instantiateViewController(withIdentifier: "BadgesPage") as! BadgesPage
            viewController.delegate = self
            viewController.parent_view = self.parentViewController
            viewController.parent_page_controller = self
            return viewController
        case 2:
            let viewController = parentViewController.storyboard!.instantiateViewController(withIdentifier: "ConnectionsPage") as! ConnectionsPage
            viewController.delegate = self
            viewController.parent_view = self.parentViewController
            viewController.parent_page_controller = self
            return viewController
            
        default:
            return UIViewController()
        }
    }
    
    func setPage(_ index: Int) {
        var direction: UIPageViewControllerNavigationDirection
        
        if(index < self.index){ direction = .reverse } else { direction = .forward }
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
        default: break
        }
        
        let viewControllers: NSArray = [toViewController!]
        self.userPageViewController.setViewControllers(viewControllers as? [UIViewController], direction: direction, animated: true, completion: nil)
    }
    
    func launchInfiniteScroll(_ parent_scroll: UICollectionView) {
        let viewController = userPageViewController.viewControllers!.first!
        switch viewController.title! {
            case "activityPage": let currentController = viewController as! ActivityPage
                                    currentController.reloadWithOffset(parent_scroll)
            
            case "badgesPage": let currentController = viewController as! BadgesPage
                                    currentController.reloadWithOffset(parent_scroll)
            
            case "connectionsPage": let currentController = viewController as! ConnectionsPage
                                    currentController.reloadWithOffset(parent_scroll)
        default: break
        }
    }

}
