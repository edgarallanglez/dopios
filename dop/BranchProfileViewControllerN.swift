//
//  BranchProfileViewControllerN.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 31/10/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class BranchProfileViewControllerN: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    @IBOutlet var container: UIView!
    @IBOutlet weak var branchCover: UIImageView!
    @IBOutlet weak var branchName: UILabel!
    @IBOutlet weak var branchLogo: UIImageView!

    
    var branchId: Int!
    var logo: UIImage!
    
    var pageViewController: BranchPageViewController!
    
    var index: Int = 0
    
    //news
    var currentIndex:Int = 0
    var nextIndex:Int = 0
    
    var currentPressedTab: Int = 0
    
    var logoString: String!
    var banner:UIImage?
    var dropPin: Annotation!
    var branchPin: CLLocation!
    
    
    var branchDetailView:UIViewController!
    var couponDetailView:UIViewController!
    var reviewsView:UIViewController!

    
    var identifiers: NSArray = ["BranchProfileAboutViewController", "PromoViewController", "ReviewsViewController"]
    @IBOutlet weak var userProfileSegmentedController: SegmentedControl!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        

        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! BranchPageViewController
        
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        //let startVC = self.viewControllerAtIndex(0) as UIViewController
        //let startingViewController = self.viewControllerAtIndex(self.index)
        
        branchDetailView = viewControllerAtIndex(0)
        couponDetailView = viewControllerAtIndex(1)
        reviewsView = viewControllerAtIndex(2)
        
        let viewControllers: NSArray = [branchDetailView]
        
        self.pageViewController.setViewControllers(viewControllers as! [UIViewController], direction: .Forward, animated: true, completion: nil)
        
        self.addChildViewController(self.pageViewController)
        
        self.container.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
        
        branchLogo.image = self.logo
        
        if(self.banner==nil){
            branchCover.backgroundColor = Utilities.dopColor
        }else{
            branchCover.image = self.banner?.applyLightEffect()
        }
        
        
        

        getBranchProfile()
        
    }
    
    override func viewDidLayoutSubviews() {
        self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Equal height constraint
        let constraint = NSLayoutConstraint(item: self.container!, attribute: .Height, relatedBy: .Equal, toItem: self.pageViewController.view, attribute: .Height, multiplier: 1.0, constant: 0)
        self.view.addConstraint(constraint)
        
        // Equal width constraint
        let constraint1 = NSLayoutConstraint(item: self.container!, attribute: .Width, relatedBy: .Equal, toItem: self.pageViewController.view, attribute: .Width, multiplier: 1.0, constant: 0)
        self.view.addConstraint(constraint1)
        
        // Equal top constraint
        let constraint2 = NSLayoutConstraint(item: self.container!, attribute: .Top, relatedBy: .Equal, toItem: self.pageViewController.view, attribute: .Top, multiplier: 1.0, constant: 0)
        self.view.addConstraint(constraint2)
        
        self.view.layoutSubviews()
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController?{

        //first view controller = firstViewControllers navigation controller
        
        
        if index == 0 {

            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("BranchProfileAboutViewController")
            
            return vc
            
        }
        
        if index == 1 {
            
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("PromoViewController") as! BranchProfilePromoViewController
            
            vc.branch_id = self.branchId
            
            return vc
            
        }
        if index == 2 {
            
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("ReviewsViewController")
            
            return vc
            
        }
        
        
        
        return UIViewController()
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        
        let identifier = viewController.restorationIdentifier

        let index = self.identifiers.indexOfObject(identifier!)
        
        if(index<0){
            return nil
        }
        

        self.index = index - 1
        
        self.pageViewController.idx = self.index
        
        self.currentIndex = index-1

        return self.viewControllerAtIndex(self.currentIndex)
        
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        
        let identifier = viewController.restorationIdentifier

        let index = self.identifiers.indexOfObject(identifier!)
        

        
   
        if index == identifiers.count - 1 {

            return nil
        }
        
        self.index = index + 1
        
        self.pageViewController.idx = self.index

        self.currentIndex = index + 1
        
        return self.viewControllerAtIndex(self.currentIndex)
    }
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        

        //pageViewController.viewControllers.
        //let identifier = previousViewControllers.last?.restorationIdentifier
        
        if completed {
            currentIndex = self.nextIndex
            userProfileSegmentedController.selectedIndex = currentIndex
        }
        
        nextIndex = 0

        
    }
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        let controller = pendingViewControllers.first?.restorationIdentifier
        self.nextIndex = self.identifiers.indexOfObject(controller!)
        
        print("IDENTIFICADOR WILL: \(nextIndex)")

    }
    

    
    @IBAction func changeTab(sender: AnyObject) {
            var direction:UIPageViewControllerNavigationDirection;
            
            
            if(sender.selectedIndex < self.currentPressedTab){
                direction = .Reverse
            }else{
                direction = .Forward
            }
            var startingViewController = self.viewControllerAtIndex(0)
            
            switch sender.selectedIndex {
                case 0:
                    startingViewController = self.branchDetailView
                    //slideToPage(0, completion: {})
                    currentPressedTab = 0
                case 1:
                    startingViewController = self.couponDetailView
                    //slideToPage(0, completion: {})
                    currentPressedTab = 1
                case 2:
                    startingViewController = self.reviewsView
                    //slideToPage(0, completion: {})
                    currentPressedTab = 2
                default:
                    print("Default t")
            }
            
            let viewControllers: NSArray = [startingViewController!]
            
            
            
            
            self.pageViewController.setViewControllers(viewControllers as! [UIViewController], direction: direction, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getBranchProfile() {
        BranchProfileController.getBranchProfileWithSuccess(branchId, success: { (branchData) -> Void in
            let data = JSON(data: branchData)
            var json = data["data"]
            json = json[0]
            let latitude = json["latitude"].double
            let longitude = json["longitude"].double
            
            self.branchPin = CLLocation(latitude: latitude!, longitude: longitude!)
            let newLocation = CLLocationCoordinate2DMake(latitude!, longitude!)
            //self.aboutView.branchPin = self.branchPin
            
            dispatch_async(dispatch_get_main_queue(), {
                self.branchName.text = json["name"].string
                self.dropPin = Annotation(coordinate: newLocation, title: json["name"].string!, subTitle: "nada")
                if json["category_id"].int! == 1 {
                    self.dropPin.typeOfAnnotation = "marker-food-icon"
                } else if json["category_id"].int! == 2 {
                    self.dropPin.typeOfAnnotation = "marker-services-icon"
                } else if json["category_id"].int! == 3 {
                    self.dropPin.typeOfAnnotation = "marker-entertainment-icon"
                }
                //                self.headerTopView.setImages(self.logo, company_id: json["company_id"].int!)
                
            })
        })
    }
    
    private func slideToPage(index: Int, completion: (() -> Void)?) {
        let count = 2
        if index < count {
            if index > self.index {
                let vc = viewControllerAtIndex(index)
                    self.pageViewController.setViewControllers([vc!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: { (complete) -> Void in
                        self.index = index
                        completion?()
                    })
            } else if index < self.index {
                let vc = viewControllerAtIndex(index)
                    self.pageViewController.setViewControllers([vc!], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: { (complete) -> Void in
                        self.index = index
                        completion?()
                    })
            }
        }
    }
   

}
