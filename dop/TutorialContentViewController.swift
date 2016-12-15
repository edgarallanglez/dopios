//
//  TutorialContentViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/8/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class TutorialContentViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var tutorial_page_control: UIPageControl!
    
    var identifiers: Array = ["page_0", "page_1", "page_2", "page_3", "page_4", "page_5", "page_6"]
    var index: Int!
    var pageViewController : UIPageViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .default
        
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        
        let start_viewcontroller: UIViewController = self.viewControllerAtIndex(0)!
        let viewControllers: [UIViewController] = [start_viewcontroller]
        
        self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParentViewController: self)
        
        setupPageControl()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        switch viewController.title! {
            case "page_0": return nil
            case "page_1": self.index = 0
            case "page_2": self.index = 1
            case "page_3": self.index = 2
            case "page_4": self.index = 3
            case "page_5": self.index = 4
            case "page_6": self.index = 5
            
        default: return nil
        }
        
        return self.viewControllerAtIndex(self.index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        switch viewController.title! {
            case "page_0": self.index = 1
            case "page_1": self.index = 2
            case "page_2": self.index = 3
            case "page_3": self.index = 4
            case "page_4": self.index = 5
            case "page_5": self.index = 6
            case "page_6": return nil
            
        default: return nil
        }
        
        return self.viewControllerAtIndex(self.index)
        
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 7
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func viewControllerAtIndex(_ index: Int) -> UIViewController?{
        //first view controller = firstViewControllers navigation controller
        
        switch index {
        case 0:
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "Page_0")

            return viewController
        case 1:
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "Page_1")
            
            return viewController
        case 2:
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "Page_2")
            
            return viewController
        case 3:
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "Page_3")
            
            return viewController
        case 4:
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "Page_4")
            
            return viewController
        case 5:
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "Page_5")
            
            return viewController
        
        case 6:
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "Page_6")
            
            return viewController
        default:
            return UIViewController()
        }
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.lightGray
        appearance.currentPageIndicatorTintColor = UIColor.darkGray
        appearance.backgroundColor = UIColor.clear
    }
    
}
