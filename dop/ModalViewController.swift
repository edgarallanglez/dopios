//
//  ModalViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 28/12/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
enum ModalViewControllerType: String {
    case ConnectionError
    case Share
    case CouponDetail
}
protocol ModalDelegate {
    func pressActionButton(modal:MZFormSheetController)
}
class ModalViewController: MZFormSheetController {
    var delegate:ModalDelegate? = nil
    var type: ModalViewControllerType?
    var simple_modal : SimpleModalViewController?
    var parent_view: UIViewController!
    var action_type: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let simple_modal:UIViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("SimpleModal"))!
        //ModalViewController(viewController: simple_modal)
        /*MZFormSheetBackgroundWindow.appearance().backgroundBlurEffect = true
        MZFormSheetBackgroundWindow.appearance().blurRadius = 1.0
        MZFormSheetBackgroundWindow.appearance().backgroundColor = UIColor.clearColor()
        
        MZFormSheetController.sharedBackgroundWindow().backgroundBlurEffect = true
        MZFormSheetController.sharedBackgroundWindow().blurRadius = 1.0
        MZFormSheetController.sharedBackgroundWindow().backgroundColor = UIColor.clearColor()*/
        self.shouldDismissOnBackgroundViewTap = false
        self.cornerRadius = 8.0
        self.transitionStyle = MZFormSheetTransitionStyle.EaseFromBottom
        self.portraitTopInset = 40.0
        self.landscapeTopInset = 6.0
        
        self.willPresentCompletionHandler = { simple_modal in
            
        }
        
    }
    init(currentView presentedFormSheetViewController: UIViewController, type: ModalViewControllerType) {
        self.type = type
        
        self.parent_view = presentedFormSheetViewController
        var simple_modal : SimpleModalViewController!
        
        if(type == .ConnectionError){
            simple_modal = presentedFormSheetViewController.storyboard?.instantiateViewControllerWithIdentifier("SimpleModal") as? SimpleModalViewController
        }
        if(type == .Share){
            simple_modal = presentedFormSheetViewController.storyboard?.instantiateViewControllerWithIdentifier("ShareModal") as? SimpleModalViewController
        }
        if(type == .CouponDetail){
            simple_modal = presentedFormSheetViewController.storyboard?.instantiateViewControllerWithIdentifier("CouponDetailModal") as? SimpleModalViewController
        }

        super.init(viewController: simple_modal!)
        
        if(type == .ConnectionError){
            self.presentedFormSheetSize = CGSizeMake(350, 271)
            simple_modal.modal_text.text = Utilities.connectionError
        }
        if(type == .Share){
            self.presentedFormSheetSize = CGSizeMake(350, 330)
            simple_modal!.title_label.text = "Compartir"
            simple_modal!.action_button.titleLabel!.text = "Compartir"
            simple_modal!.share_text.contentInset = UIEdgeInsetsMake(0,-5,0,0)
            simple_modal!.twitter_button.addTarget(self, action: "tintButton:", forControlEvents: .TouchUpInside)
            simple_modal!.facebook_button.addTarget(self, action: "tintButton:", forControlEvents: .TouchUpInside)
            simple_modal!.instagram_button.addTarget(self, action: "tintButton:", forControlEvents: .TouchUpInside)
            //simple_modal!.modal_text.text = "Share"
        }
        if(type == .CouponDetail){
            self.presentedFormSheetSize = CGSizeMake(380, 530)
            simple_modal.branch_title.addTarget(self, action: "toBranch", forControlEvents: .TouchUpInside)
        }
        
        if(simple_modal!.action_button != nil){
            simple_modal!.action_button.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        }
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle:nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pressed(sender: UIButton!) {
        self.delegate?.pressActionButton(self)
    }
    
    func toBranch() {
        self.action_type = "profile"
        self.delegate?.pressActionButton(self)
    }
    
    func tintButton(sender: UIButton!) {
        if (sender.selected) {
            sender.selected = false
            sender.tintColor = UIColor.lightGrayColor()
        } else {
            sender.selected = true
            sender.tintColor = Utilities.dopColor
        }
    }

}
