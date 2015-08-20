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
    
    var customView :CouponDetailView = CouponDetailView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //var CouponDetailNib = UINib(nibName: "CouponDetailView", bundle: nil)

        var nib = UINib(nibName: "NewsfeedCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "NewsfeedCell")
        
        customView = (NSBundle.mainBundle().loadNibNamed("CouponDetailView", owner: self, options: nil)[0] as? CouponDetailView)!
        
//        customView.branch_logo.layer.borderColor = UIColor.whiteColor().CGColor
        
        customView.alpha = 0
        
        customView.layer.borderWidth = 0;
        
        
        customView.branchName.layer.shadowOffset = CGSize(width: 1, height: 3)
        customView.branchName.layer.shadowOpacity = 1
        customView.branchName.layer.shadowRadius = 3
        customView.branchName.layer.shadowColor = UIColor.blackColor().CGColor
        
        customView.loadView(self)
        
        customView.branch_category.layer.shadowOffset = CGSize(width: 1, height: 3)
        customView.branch_category.layer.shadowOpacity = 1
        customView.branch_category.layer.shadowRadius = 3
        customView.branch_category.layer.shadowColor = UIColor.blackColor().CGColor

        
        
        customView.branch_cover.image = customView.branch_cover.image?.applyLightEffect()
        //self.navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = UIColor.yellowColor()
        //visualEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        
        
            }
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.7, delay: 0, options: .CurveEaseInOut, animations: {
            self.customView.alpha = 1
            }, completion: { finished in
                
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:NewsfeedCell = tableView.dequeueReusableCellWithIdentifier("NewsfeedCell", forIndexPath: indexPath) as! NewsfeedCell
      
        let model = NewsfeedNote(client_coupon_id:0,friend_id: "1", user_id: 1, branch_id: 1, coupon_name: "Cupon prueba", branch_name: "Starbax", names: "Jose Eduardo", surnames: "Quintero Gutierrez", user_image: "http://jsequeiros.com/sites/default/files/imagen-cachorro-comprimir.jpg?1399003306" , branch_image: "http://jsequeiros.com/sites/default/files/imagen-cachorro-comprimir.jpg?1399003306",total_likes:0,user_like:0)
        
        
        
        cell.loadItem(model, viewController: NewsfeedViewController())
        
        cell.user_image.alpha = 0
        
        let imageUrl = NSURL(string: model.user_image)

        
        
        Utilities.getDataFromUrl(imageUrl!) { data in
            dispatch_async(dispatch_get_main_queue()) {
                println("Finished downloading \"\(imageUrl!.lastPathComponent!.stringByDeletingPathExtension)\".")

                    var cell_image : UIImage = UIImage()
                    cell_image = UIImage ( data: data!)!
                    cell.user_image.image = cell_image
                    UIView.animateWithDuration(0.5, animations: {
                        cell.user_image.alpha = 1
                    })
                }
            }

        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 568
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return customView
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? CouponCell {
            
//            let i = couponsTableView.indexPathForCell(cell)!.section
//            let model = self.coupons[i]
            if segue.identifier == "branchProfile" {
                let view = segue.destinationViewController as! BranchProfileViewController
//                view.branchId = model.branch_id
                view.logo = cell.branchImage.currentBackgroundImage
//                view.logoString = model.logo
                
            }
        }
        
    }

    
    

    
}
