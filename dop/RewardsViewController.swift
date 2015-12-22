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
    var medal_view: UIViewController!
    
    var identifiers: NSArray = ["TrophyTableViewController", "MedalTableViewController"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rewardsPageViewController =  UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        
        self.rewardsPageViewController.dataSource = self
        self.rewardsPageViewController.delegate = self
        
        trophy_view = viewControllerAtIndex(0)
        medal_view = viewControllerAtIndex(1)
        
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
            let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("TrophyTableViewController") as! TrophyTableViewController
            return viewController
            
        case 1:
            let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("MedalTableViewController") as! MedalTableViewController
            return viewController
            
        default:
            return UIViewController()
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let identifier = viewController.restorationIdentifier
//        if identifier == nil { return self.viewControllerAtIndex(0) }
        let index = self.identifiers.indexOfObject(identifier!)
        
        self.index = index - 1
        
        if index != 0 || index != 1 { return nil }
        return self.viewControllerAtIndex(self.index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let identifier = viewController.restorationIdentifier
        let index = self.identifiers.indexOfObject(identifier!)
    
        if index == identifiers.count - 1 || index < 0 { return nil }
        self.index = index + 1

        return self.viewControllerAtIndex(self.index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        
//        rewardsPageViewController.viewControllers.
//        let identifier = previousViewControllers.last?.restorationIdentifier
        
        if completed {
            self.index = self.next_index
            rewards_segmented_controller.selectedIndex = self.index
        }
        next_index = 0
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        
        let controller = pendingViewControllers.first?.restorationIdentifier ?? ""
        self.next_index = self.identifiers.indexOfObject(controller)
        
        print("IDENTIFICADOR WILL: \(next_index)")
        
    }
    
    @IBAction func setSegmentedController(sender: RewardsSegmentedController) {
        var direction:UIPageViewControllerNavigationDirection;
        
        
        if (sender.selectedIndex < self.current_pressed_tab) { direction = .Reverse }
        else { direction = .Forward }
        
        var starting_view_controller = self.viewControllerAtIndex(0)
        
        switch sender.selectedIndex {
        case 0:
            starting_view_controller = self.trophy_view
            //slideToPage(0, completion: {})
            current_pressed_tab = 0
        case 1:
            starting_view_controller = self.medal_view
            //slideToPage(0, completion: {})
            current_pressed_tab = 1
        default:
            print("Default t")
        }
        
        let viewControllers: [UIViewController] = [starting_view_controller!]
        self.rewardsPageViewController.setViewControllers(viewControllers, direction: direction, animated: true, completion: nil)
    }
    
    
}