//
//  MedalViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/15/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class MedalViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIAlertViewDelegate {
    
    @IBOutlet weak var collection_view: UICollectionView!
    
    
    var medal_list = [MedalModel]()
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let size = collection_view.frame.width / 3
        return CGSizeMake(size, size)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("medal_identifier", forIndexPath: indexPath) as! MedalCollectionCell
        
        
        return cell
    }
    
    func launchBadgeAlert() {
        self.presentViewController(AlertClass().launchAlert(), animated: true, completion: nil)
    }
    
}