//
//  TestViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 03/12/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var segmentedControl: SegmentedControl!

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mainView: UIView!
    private var lastContentOffset: CGFloat = 0
    
    var segmentedInitialY: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = CGSizeMake(400,1000)
        scrollView.delegate = self
        collectionView.scrollEnabled = false
        
        segmentedInitialY = segmentedControl.frame.origin.y
        segmentedControl.backgroundColor = UIColor.whiteColor()
        
        
        print("INICIAL \(segmentedInitialY)")
        
        
        /*collectionView.frame.size = CGSizeMake(collectionView.frame.width, 300)
        
        mainView.frame.size = CGSizeMake(mainView.frame.width, collectionView.frame.height)*/
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(scrollView==collectionView){
            print("SCROLLING ")
        }
        /*if (self.lastContentOffset > scrollView.contentOffset.y) {
            if(scrollView.contentOffset.y<=segmentedInitialY){
                segmentedControl.frame.origin.y = segmentedInitialY
            }else{
                segmentedControl.frame.origin.y = (scrollView.contentOffset.y)
            }
        }else{
            if(self.lastContentOffset < scrollView.contentOffset.y){
                if(scrollView.contentOffset.y>=segmentedControl.frame.origin.y){
                    segmentedControl.frame.origin.y = (scrollView.contentOffset.y)
                    collectionView.scrollEnabled = true
                }
            }
        }*/
    
    
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
    

       /*if(scrollView.contentOffset.y>=0){
            segmentedControl.frame.origin.y = (scrollView.contentOffset.y)
       }*/
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        return 15
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PromoCell", forIndexPath: indexPath) as UICollectionViewCell
        
        cell.backgroundColor = UIColor.blackColor()

        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = CGSizeMake(185, 230)
        
        return size
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
