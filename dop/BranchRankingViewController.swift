//
//  BranchRankingViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 1/19/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

@objc protocol RankingPageDelegate {
    optional func resizeRankingView(dynamic_height: CGFloat)
}

class BranchRankingViewController: UITableViewController {
    var delegate: RankingPageDelegate?
    
    var parent_view: BranchProfileStickyController!
    
    var cached_images: [String: UIImage] = [:]
    var ranking_array = [PeopleModel]()
    var offset = 5
    var new_data: Bool = false
    var added_values: Int = 0
    
    override func viewDidLoad() {
        self.tableView.alwaysBounceVertical = false
        self.tableView.scrollEnabled = false
        //        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.rowHeight = 60
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if ranking_array.count == 0 {
            getRanking()
        } else { setFrame() }
    }
    
    func setFrame() {
        //self.tableView.frame.size.height = self.tableView.contentSize.height
        delegate?.resizeRankingView!(self.tableView.contentSize.height)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ranking_array.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: PeopleCell = tableView.dequeueReusableCellWithIdentifier("PeopleCell", forIndexPath: indexPath) as! PeopleCell
        
        let model = self.ranking_array[indexPath.row]
        cell.loadItem(model, viewController: self)
        downloadImage(model, cell: cell)
        
        return cell
    }
    
    func getRanking() {

        BranchProfileController.getBranchProfileRankingWithSuccess(parent_view.branch_id, success: { (data) -> Void in
            let json = JSON(data: data)
            
            for (_, subJson): (String, JSON) in json["data"] {
                let names = subJson["names"].string!
                let surnames = subJson["surnames"].string!
                let facebook_key = subJson["facebook_key"].string!
                let user_id = subJson["user_id"].int!
                let company_id = subJson["company_id"].int ?? 0
//                let branch_id =  subJson["branch_id" ].int!
                let birth_date = subJson["birth_date"].string!
                let privacy_status = subJson["privacy_status"].int!
                let main_image = subJson["main_image"].string!
                let total_used = subJson["total_used"].int!
                
                let model = PeopleModel(names: names, surnames: surnames, user_id: user_id, birth_date: birth_date, facebook_key: facebook_key, privacy_status: privacy_status, main_image: main_image, total_used: total_used)
                
                self.ranking_array.append(model)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.ranking_array.sortInPlace({ $0.total_used > $1.total_used })
                self.reload()
                Utilities.fadeInFromBottomAnimation(self.tableView, delay: 0, duration: 1, yPosition: 20)
            });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    //                    self.refreshControl.endRefreshing()
                })
        })
    }
    
    func reload() {
        self.tableView.reloadData()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.setFrame()
        })
    }
    
    func reloadWithOffset(parent_scroll: UICollectionView) {
        if ranking_array.count != 0 {
            BranchProfileController.getBranchProfileRankingOffsetWithSuccess(ranking_array.last!.user_id, branch_id: self.parent_view.branch_id, offset: offset, success: { (data) -> Void in
                let json = JSON(data: data)
                
                for (_, subJson): (String, JSON) in json["data"] {
                    let names = subJson["names"].string!
                    let surnames = subJson["surnames"].string!
                    let facebook_key = subJson["facebook_key"].string!
                    let user_id = subJson["user_id"].int!
                    let company_id = subJson["company_id"].int ?? 0
                    //                let branch_id =  subJson["branch_id" ].int!
                    let birth_date = subJson["birth_date"].string!
                    let privacy_status = subJson["privacy_status"].int!
                    let main_image = subJson["main_image"].string!
                    let total_used = subJson["total_used"].int!
                    
                    let model = PeopleModel(names: names, surnames: surnames, user_id: user_id, birth_date: birth_date, facebook_key: facebook_key, privacy_status: privacy_status, main_image: main_image, total_used: total_used)
                    
                    self.ranking_array.append(model)
                    self.new_data = true
                    self.added_values++
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.reload()
                    if self.new_data { self.offset += self.added_values }
                    parent_scroll.finishInfiniteScroll()
                });
                },
                
                failure: { (error) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        parent_scroll.finishInfiniteScroll()
                    })
            })
        } else { parent_scroll.finishInfiniteScroll() }
    }
    
    func downloadImage(model: PeopleModel, cell: PeopleCell) {
        let url = NSURL(string: model.main_image)
        Utilities.getDataFromUrl(url!) { data in
            dispatch_async(dispatch_get_main_queue()) {
                cell.user_image.image = UIImage(data: data!)
            }
        }
    }
    
}

