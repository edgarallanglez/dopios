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
    
    @IBOutlet var mainLoader: MMMaterialDesignSpinner!
    var index: Int = 0
    
    //news
    var current_index:Int = 0
    var next_index:Int = 0
    
    var current_pressed_tab: Int = 0
    
    var trophy_view: UIViewController!
    var medal_view: UIViewController!
    
    var identifiers: Array = ["TrophyTableViewController", "MedalTableViewController"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(RewardsViewController.showLoader(_:)),
            name: NSNotification.Name(rawValue: "showLoader"),
            object: nil)
        
        mainLoader.tintColor = Utilities.dopColor
        mainLoader.lineWidth = 3.0
        
        self.rewardsPageViewController =  UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        self.rewardsPageViewController.dataSource = self
        self.rewardsPageViewController.delegate = self
        
        trophy_view = viewControllerAtIndex(0)
//        medal_view = viewControllerAtIndex(1)
        
        let viewControllers: [UIViewController] = [trophy_view]
        
        self.rewardsPageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        
        self.addChildViewController(self.rewardsPageViewController)
        
        self.contentView.addSubview(self.rewardsPageViewController.view)
        self.rewardsPageViewController.didMove(toParentViewController: self)
        
    }
    
    override func viewDidLayoutSubviews() {
        self.rewardsPageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Equal height constraint
        let height_constraint = NSLayoutConstraint(item: self.contentView!, attribute: .height, relatedBy: .equal, toItem: self.rewardsPageViewController.view, attribute: .height, multiplier: 1.0, constant: 0)
        self.view.addConstraint(height_constraint)
        
        // Equal width constraint
        let width_constraint = NSLayoutConstraint(item: self.contentView!, attribute: .width, relatedBy: .equal, toItem: self.rewardsPageViewController.view, attribute: .width, multiplier: 1.0, constant: 0)
        self.view.addConstraint(width_constraint)
        
//        // Equal top constraint
//        let top_constraint = NSLayoutConstraint(item: self.rewards_segmented_controller!, attribute: .bottom, relatedBy: .equal, toItem: self.rewardsPageViewController.view, attribute: .top, multiplier: 1.0, constant: 0)
//        self.view.addConstraint(top_constraint)
        
        self.view.layoutSubviews()
    }
    
    func viewControllerAtIndex(_ index: Int) -> UIViewController?{
        //first view controller = firstViewControllers navigation controller
        
        switch index {
        case 0:
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "TrophyTableViewController") as! TrophyTableViewController
            return viewController
            
        case 1:
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "MedalTableViewController") as! MedalTableViewController
            return viewController
            
        default:
            return UIViewController()
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        switch viewController.title! {
        case "trophyPage": return nil
//        case "medalPage": self.index = 0
        default: return nil
        }
        
        return self.viewControllerAtIndex(self.index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        switch viewController.title! {
            case "trophyPage": return nil //self.index = 1
//            case "medalPage": return nil
            default: return nil
        }
        
        return self.viewControllerAtIndex(self.index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        
        //        rewardsPageViewController.viewControllers.
        //        let identifier = previousViewControllers.last?.restorationIdentifier
        
        if completed {
            self.index = self.next_index
            rewards_segmented_controller.selectedIndex = self.index
        }
        next_index = 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        let controller = pendingViewControllers.first?.restorationIdentifier ?? ""
        self.next_index = self.identifiers.index(of: controller)!
        
        print("IDENTIFICADOR WILL: \(next_index)")
        
    }
    
    @IBAction func setSegmentedController(_ sender: RewardsSegmentedController) {
        var direction:UIPageViewControllerNavigationDirection;
        
        
        if (sender.selectedIndex < self.current_pressed_tab) { direction = .reverse }
        else { direction = .forward }
        
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
    
    func showLoader(_ notification: Foundation.Notification){
        let show = notification.object as! Bool
        
        if show {
            mainLoader.startAnimating()
        }else{
            mainLoader.stopAnimating()
        }
    }
}
