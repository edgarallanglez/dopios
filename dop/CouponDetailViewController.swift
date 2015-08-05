//
//  CouponDetailViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/08/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class CouponDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //var CouponDetailNib = UINib(nibName: "CouponDetailView", bundle: nil)

        var nib = UINib(nibName: "NewsfeedCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "NewsfeedCell")
        
        
        /*branch_logo.layer.borderColor = UIColor.whiteColor().CGColor
        
        branch_name.layer.shadowOffset = CGSize(width: 1, height: 3)
        branch_name.layer.shadowOpacity = 1
        branch_name.layer.shadowRadius = 3
        branch_name.layer.shadowColor = UIColor.blackColor().CGColor
        
        branch_category.layer.shadowOffset = CGSize(width: 1, height: 3)
        branch_category.layer.shadowOpacity = 1
        branch_category.layer.shadowRadius = 3
        branch_category.layer.shadowColor = UIColor.blackColor().CGColor

        
        
        branch_cover.image = branch_cover.image?.applyLightEffect()

        branch_logo.alpha = 0*/
        
        //self.navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = UIColor.yellowColor()
        
        
        
        //visualEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    
    override func viewDidAppear(animated: Bool) {
       /* UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: {
           self.branch_logo.alpha = 1
           var logoTopFrame = self.branch_logo.frame
            logoTopFrame.origin.y -= logoTopFrame.size.height/8
            
            
            self.branch_logo.frame = logoTopFrame
            }, completion: { finished in

        })*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:NewsfeedCell = tableView.dequeueReusableCellWithIdentifier("NewsfeedCell", forIndexPath: indexPath) as! NewsfeedCell
      
        let model = NewsfeedNote(friend_id: "1", user_id: 1, branch_id: 1, coupon_name: "Cupon prueba", branch_name: "Starbax", names: "Jose Eduardo", surnames: "Quintero Gutierrez", user_image: "http://jsequeiros.com/sites/default/files/imagen-cachorro-comprimir.jpg?1399003306" , branch_image: "http://jsequeiros.com/sites/default/files/imagen-cachorro-comprimir.jpg?1399003306")

        
          cell.loadItem(model, viewController: NewsfeedViewController())
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 568
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var customView :UIView = UIView()
        
        
        customView = (NSBundle.mainBundle().loadNibNamed("CouponDetailView", owner: self, options: nil)[0] as? UIView)!

        return customView
    }
    

}
