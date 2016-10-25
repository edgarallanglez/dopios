//
//  BranchProfilePageController.swift
//  dop
//
//  Created by Edgar Allan Glez on 1/19/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

protocol BranchPaginationDelegate {
    func resizeView(_ new_height: CGFloat)
    func setSegmentedIndex(_ index: Int)
    func setFollowButton(_ branch: Branch)
}

class BranchProfilePageController: UICollectionViewCell, UIPageViewControllerDataSource, UIPageViewControllerDelegate, SetSegmentedBranchPageDelegate, AboutPageDelegate, CampaignPageDelegate, RankingPageDelegate, UIScrollViewDelegate {
    
    var delegate: BranchPaginationDelegate?
    var branchPageViewController: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    var index: Int = 0
    
    var parentViewController: BranchProfileStickyController!
    
    var about_view: UIViewController!
    var campaign_view: UIViewController!
    var ranking_view: UIViewController!
    
    var dynamic_height: CGFloat!
    var identifiers: NSArray = ["AboutPage", "CampaignPage", "RankingPage"]
    
    override func setNeedsLayout() {
        self.branchPageViewController.view.frame.size.width = UIScreen.main.bounds.width
        self.branchPageViewController.view.frame.size.height = dynamic_height
    }
    
    func resizeAboutView(_ dynamic_height: CGFloat) {
        self.dynamic_height = dynamic_height
        setNeedsLayout()
        delegate?.resizeView(dynamic_height)
    }
    
    func resizeCampaignView(_ dynamic_height: CGFloat) {
        self.dynamic_height = dynamic_height
        delegate?.resizeView(dynamic_height)
    }
    
    func resizeRankingView(_ dynamic_height: CGFloat) {
        self.dynamic_height = dynamic_height
        delegate?.resizeView(dynamic_height)
    }
    
    
    func setPaginator(_ viewController: BranchProfileStickyController) {
        
        parentViewController = viewController
        parentViewController.delegate = self
        
        self.branchPageViewController.dataSource = self
        self.branchPageViewController.delegate = self
        
        about_view = viewControllerAtIndex(0)
        dynamic_height = about_view.view.frame.height
        
        let viewControllers: [UIViewController] = [about_view]
        
        self.branchPageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        
        self.contentView.addSubview(self.branchPageViewController.view)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        switch viewController.title! {
        case "aboutPage": return nil
        case "campaignPage": self.index = 0
        case "rankingPage": self.index = 1
        default: return nil
        }
        
        return self.viewControllerAtIndex(self.index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        switch viewController.title! {
        case "aboutPage": self.index = 1
        case "campaignPage": self.index = 2
        case "rankingPage": return nil
        default: return nil
        }
        
        return self.viewControllerAtIndex(self.index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if !completed {
            let viewController = pageViewController.viewControllers!.first!
            var index = 0
            switch viewController.title! {
            case "aboutPage": index = 0
            case "campaignPage": index = 1
            case "rankingPage": index = 2
            default: index = 0
            }
            delegate?.setSegmentedIndex(index)
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let viewController = pendingViewControllers.first!
        var index = 0
        switch viewController.title! {
        case "aboutPage": index = 0
        case "campaignPage": index = 1
        case "rankingPage": index = 2
        default: index = 0
        }
        
        delegate?.setSegmentedIndex(index)
    }
    
    func viewControllerAtIndex(_ index: Int) -> UIViewController?{
        //first view controller = firstViewControllers navigation controller
        
        switch index {
        case 0:
            let viewController = parentViewController.storyboard!.instantiateViewController(withIdentifier: "AboutPage") as! BranchAboutViewController
            viewController.delegate = self
            viewController.parent_view = self.parentViewController
            return viewController
        case 1:
            let viewController = parentViewController.storyboard!.instantiateViewController(withIdentifier: "CampaignPage") as! BranchCampaignCollectionViewController
            viewController.delegate = self
            viewController.parent_view = self.parentViewController
            return viewController
        case 2:
            let viewController = parentViewController.storyboard!.instantiateViewController(withIdentifier: "RankingPage") as! BranchRankingViewController
            viewController.delegate = self
            viewController.parent_view = self.parentViewController
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
        self.branchPageViewController.setViewControllers(viewControllers as? [UIViewController], direction: direction, animated: true, completion: nil)
    }
    
    func launchInfiniteScroll(_ parent_scroll: UICollectionView) {
        let viewController = branchPageViewController.viewControllers!.first!
        switch viewController.title! {
        case "aboutPage": let currentController = viewController as! BranchAboutViewController
        currentController.reloadWithOffset(parent_scroll)
            
        case "campaignPage": let currentController = viewController as! BranchCampaignCollectionViewController
        currentController.reloadWithOffset(parent_scroll)
            
        case "rankingPage": let currentController = viewController as! BranchRankingViewController
        currentController.reloadWithOffset(parent_scroll)
        default: break
        }
    }
    
    func setFollow(_ branch: Branch) {
        delegate?.setFollowButton(branch)
    }
}
