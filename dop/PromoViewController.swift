//
//  PromoViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/08/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class PromoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIAlertViewDelegate {
    
    @IBOutlet weak var CouponsCollectionView: UICollectionView!
    
    private let reuseIdentifier = "PromoCell"
    var coupons = [Coupon]()
    var cachedImages: [String: UIImage] = [:]
    var refreshControl: UIRefreshControl!
    
    //
    
    
    private let downloadQueue = dispatch_queue_create("ru.codeispoetry.downloadQueue", nil)

    private let apiURL = "https://api.flickr.com/services/feeds/photos_public.gne?nojsoncallback=1&format=json"
    private var photos = [NSURL]()
    private var modifiedAt = NSDate.distantPast() as! NSDate
    private var cache = NSCache()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""
        
        
        
        //self.navigationItem.title = "Promociones";
        self.navigationController?.navigationBar.topItem!.title = "Hoy tenemos"
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.CouponsCollectionView.addSubview(refreshControl)
        
        self.CouponsCollectionView.contentInset = UIEdgeInsetsMake(0,0,49,0)
        
        getCoupons()
        
        
        
        
        
        // Set custom indicator
        self.CouponsCollectionView.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRectMake(0, 0, 24, 24))
        
        // Set custom indicator margin
        CouponsCollectionView.infiniteScrollIndicatorMargin = 40
        
        // Add infinite scroll handler
        CouponsCollectionView.addInfiniteScrollWithHandler { [weak self] (scrollView) -> Void in
            let collectionView = scrollView as! UICollectionView
            
            /*self?.fetchData() {
                scrollView.finishInfiniteScroll()
            }*/
            
            self?.getCoupons()
            
            //scrollView.finishInfiniteScroll()
            
            
        }
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    func refresh(sender:AnyObject) {
        getCoupons()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coupons.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PromoCollectionCell
        
        let model = self.coupons[indexPath.row]
        
        cell.loadItem(model, viewController: self)
        
        let imageUrl = NSURL(string: "\(Utilities.dopImagesURL)\(model.company_id)/\(model.logo)")
        let identifier = "Cell\(indexPath.row)"
        
        cell.backgroundColor = UIColor.whiteColor()
        cell.viewForBaselineLayout()?.sizeThatFits(CGSizeMake(1000, 50))
        
        cell.layer.shadowColor = UIColor.grayColor().CGColor
        cell.layer.shadowOffset = CGSizeMake(0, 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(rect:CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height)).CGPath
        
        cell.heart.image = cell.heart.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        cell.viewForBaselineLayout()?.alpha = 0
        
        if (self.cachedImages[identifier] != nil){
            cell.branch_banner.image = self.cachedImages[identifier]!
        } else {
            cell.branch_banner.alpha = 0
            Utilities.getDataFromUrl(imageUrl!) { photo in
                dispatch_async(dispatch_get_main_queue()) {
                    var imageData: NSData = NSData(data: photo!)
                    if self.CouponsCollectionView.indexPathForCell(cell)?.row == indexPath.row {
                        self.cachedImages[identifier] = UIImage(data: imageData)
                        cell.branch_banner.image = self.cachedImages[identifier]
                        UIView.animateWithDuration(0.5, animations: {
                            cell.branch_banner.alpha = 1
                        })
                    }
                }
            }
        }
        
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {
            cell.viewForBaselineLayout()?.alpha = 1
            }, completion: { finished in
                
        })
        
        

        return cell
    }
  
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = CGSizeMake(180, 200)
        
        return size
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.CouponsCollectionView.cellForItemAtIndexPath(indexPath)
        self.performSegueWithIdentifier("couponDetail", sender: cell)
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 20, 20, 10)
    }

    func getCoupons() {
        //coupons = [Coupon]()
        
  
        CouponController.getAllCouponsWithSuccess(
            success: { (couponsData) -> Void in
                let json = JSON(data: couponsData)
            
                for (index: String, subJson: JSON) in json["data"]{
                    var coupon_id = subJson["coupon_id"].int!
                    let coupon_name = subJson["name"].string!
                    let coupon_description = subJson["description"].string!
                    let coupon_limit = subJson["limit"].string
                    let coupon_exp = "2015-09-30"
                    let coupon_logo = subJson["logo"].string!
                    let branch_id = subJson["branch_id"].int!
                    let company_id = subJson["company_id"].int!
                    let total_likes = subJson["total_likes"].int!
                    let user_like = subJson["user_like"].int!
                    let latitude = subJson["latitude"].double!
                    let longitude = subJson["longitude"].double!
                    

                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude)
                
                    self.coupons.append(model)
                    
                    
                    
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.CouponsCollectionView.reloadData()
                    
                    
                    self.CouponsCollectionView.alwaysBounceVertical = true
                    self.refreshControl.endRefreshing()
                    
                    
                    self.CouponsCollectionView.finishInfiniteScroll()
                });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.refreshControl.endRefreshing()
                    self.CouponsCollectionView.finishInfiniteScroll()
                })
            })
        

        }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? UICollectionViewCell {
            
            let i = self.CouponsCollectionView.indexPathForCell(cell)!.row

            let model = self.coupons[i]
            if segue.identifier == "couponDetail" {
                let view = segue.destinationViewController as! CouponDetailViewController
                view.couponsName = model.name
                view.couponsDescription = model.couponDescription
                view.location = model.location
                view.branchId = model.branch_id
                view.couponId = model.id
            }
        }
    }
    
    
    private func fetchData(handler: (Void -> Void)?) {
        let requestURL = NSURL(string: apiURL)!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(requestURL, completionHandler: {
            (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.handleResponse(data, response: response, error: error, completion: handler)
                //UIApplication.sharedApplication().stopNetworkActivity()
            });
        })
        
        //UIApplication.sharedApplication().startNetworkActivity()
        
        // I run task.resume() with delay because my network is too fast
        let delay = (photos.count == 0 ? 0 : 5) * Double(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(0))
        dispatch_after(time, dispatch_get_main_queue(), {
            task.resume()
        })
    }
    
    private func handleResponse(data: NSData!, response: NSURLResponse!, error: NSError!, completion: (Void -> Void)?) {
        if error != nil {
            showAlertWithError(error)
            completion?()
            return;
        }
        
        var jsonError: NSError?
        var jsonString = NSString(data: data, encoding: NSUTF8StringEncoding)
        
        // Fix broken Flickr JSON
        jsonString = jsonString?.stringByReplacingOccurrencesOfString("\\'", withString: "'")
        let fixedData = jsonString?.dataUsingEncoding(NSUTF8StringEncoding)
        
        let responseDict = NSJSONSerialization.JSONObjectWithData(fixedData!, options: NSJSONReadingOptions.allZeros, error: &jsonError) as? Dictionary<String, AnyObject>
        
        if jsonError != nil {
            showAlertWithError(jsonError)
            completion?()
            return
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        let modifiedAt_ = dateFormatter.dateFromString(responseDict?["modified"] as! String)
        
        if modifiedAt_?.compare(modifiedAt) != NSComparisonResult.OrderedDescending {
            completion?()
            return
        }
        
        var indexPaths = [NSIndexPath]()
        let firstIndex = photos.count
        
        if let items = responseDict?["items"] as? NSArray {
            if let urls = items.valueForKeyPath("media.m") as? [String] {
                for (i, url) in enumerate(urls) {
                    let indexPath = NSIndexPath(forItem: firstIndex + i, inSection: 0)
                    
                    photos.append(NSURL(string: url)!)
                    indexPaths.append(indexPath)
                }
            }
        }
        
        modifiedAt = modifiedAt_!
        
        CouponsCollectionView.reloadData()
        //completion!()
        CouponsCollectionView.finishInfiniteScroll()
       /* CouponsCollectionView?.performBatchUpdates({ () -> Void in
            CouponsCollectionView?.insertItemsAtIndexPaths(indexPaths)
            }, completion: { (finished) -> Void in
                completion?()
        });*/
    }
    
    private func showAlertWithError(error: NSError!) {
        let alert = UIAlertView(
            title: NSLocalizedString("Error fetching data", comment: ""),
            message: error.localizedDescription,
            delegate: self,
            cancelButtonTitle: NSLocalizedString("Dismiss", comment: ""),
            otherButtonTitles: NSLocalizedString("Retry", comment: "")
        )
        alert.show()
    }
    


}
