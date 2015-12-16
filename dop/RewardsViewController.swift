//
//  RewardsViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/15/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import Foundation
import UIKit

class RewardsViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var rewardsPageViewController: UIPageViewController!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var rewards_segmented_controller: RewardsSegmentedController!
    
    var index: Int = 0
    
    //news
    var current_index:Int = 0
    var next_index:Int = 0
    
    var current_pressed_tab: Int = 0
    
    var trophy_view: UIViewController!
    var medal_iew:UIViewController!
    
    var identifiers: NSArray = ["TrophyViewController", "MedalViewController"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rewardsPageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RewardsPageViewController") as! UIPageViewController
        
        self.rewardsPageViewController.dataSource = self
        self.rewardsPageViewController.delegate = self
        
        trophy_view = viewControllerAtIndex(0)
        let viewControllers: [UIViewController] = [trophy_view]
        
        self.rewardsPageViewController.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
        
        self.addChildViewController(self.rewardsPageViewController)
        
        self.contentView.addSubview(self.rewardsPageViewController.view)
        self.rewardsPageViewController.didMoveToParentViewController(self)
        
    }
    
    override func viewDidLayoutSubviews() {
        self.rewardsPageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Equal height constraint
        let height_constraint = NSLayoutConstraint(item: self.contentView!, attribute: .Height, relatedBy: .Equal, toItem: self.rewardsPageViewController.view, attribute: .Height, multiplier: 1.0, constant: 0)
        self.view.addConstraint(height_constraint)
        
        // Equal width constraint
        let width_constraint = NSLayoutConstraint(item: self.contentView!, attribute: .Width, relatedBy: .Equal, toItem: self.rewardsPageViewController.view, attribute: .Width, multiplier: 1.0, constant: 0)
        self.view.addConstraint(width_constraint)
        
        // Equal top constraint
        let top_constraint = NSLayoutConstraint(item: self.rewards_segmented_controller!, attribute: .Bottom, relatedBy: .Equal, toItem: self.rewardsPageViewController.view, attribute: .Top, multiplier: 1.0, constant: 0)
        self.view.addConstraint(top_constraint)
        
        self.view.layoutSubviews()
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController?{
        //first view controller = firstViewControllers navigation controller
        
        switch index {
        case 0:
            let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("TrophyViewController") as! TrophyViewController
            return viewController
            
        case 1:
            let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("MedalViewController") as! MedalViewController
            return viewController
            
        default:
            let defaultViewController = UIViewController()
            return defaultViewController
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let identifier = viewController.restorationIdentifier
        let index = self.identifiers.indexOfObject(identifier!)
        
        self.index = index - 1

        return self.viewControllerAtIndex(self.index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let identifier = viewController.restorationIdentifier
        let index = self.identifiers.indexOfObject(identifier!)
    
        if index == identifiers.count - 1 { return nil }        
        self.index = index + 1

        return self.viewControllerAtIndex(self.index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        
        //pageViewController.viewControllers.
        //let identifier = previousViewControllers.last?.restorationIdentifier
        
//        if completed {
//            currentIndex = self.nextIndex
//            userProfileSegmentedController.selectedIndex = currentIndex
//        }
//        
//        nextIndex = 0
        
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
//        let controller = pendingViewControllers.first?.restorationIdentifier
//        self.nextIndex = self.identifiers.indexOfObject(controller!)
//        
//        print("IDENTIFICADOR WILL: \(nextIndex)")
        
    }
    
}