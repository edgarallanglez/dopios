//
//  FilterSideViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 8/26/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class FilterSideViewController: UIViewController {
    @IBOutlet weak var filterSegmented: FilterSegmentedControl!
    
    static var open: Bool = false
    
    //food outlets
    @IBOutlet weak var alitasAndBoneless: UISwitch!
    @IBOutlet weak var bistro: UISwitch!
    @IBOutlet weak var cafeteria: UISwitch!
    @IBOutlet weak var comidaChina: UISwitch!
    @IBOutlet weak var comidaRapida: UISwitch!
    @IBOutlet weak var gourmet: UISwitch!
    @IBOutlet weak var italiana: UISwitch!
    @IBOutlet weak var marisco: UISwitch!
    @IBOutlet weak var mexicana: UISwitch!
    @IBOutlet weak var sushi: UISwitch!
    var foodCategoriesArray: [UISwitch] = []
    
    //services outlets
    @IBOutlet weak var automotriz: UISwitch!
    @IBOutlet weak var educacion: UISwitch!
    @IBOutlet weak var electronica: UISwitch!
    @IBOutlet weak var hogar: UISwitch!
    @IBOutlet weak var moda: UISwitch!
    @IBOutlet weak var viajes: UISwitch!
    @IBOutlet weak var saludAndBelleza: UISwitch!
    var servicesCategoriesArray: [UISwitch] = []
    
    //entertainment outlets
    @IBOutlet weak var bar: UISwitch!
    @IBOutlet weak var cine: UISwitch!
    @IBOutlet weak var clubNocturno: UISwitch!
    @IBOutlet weak var deporte: UISwitch!
    @IBOutlet weak var parques: UISwitch!
    @IBOutlet weak var teatro: UISwitch!
    var entertainmentCategoriesArray: [UISwitch] = []
    
    //Categories
    @IBOutlet weak var entertainmentView: UIView!
    @IBOutlet weak var servicesView: UIView!
    @IBOutlet weak var foodView: UIView!
    
    var activeFilters: [Int] = []
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = .Default
        FilterSideViewController.open = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        FilterSideViewController.open = false
    }
    override func viewDidLoad() {
        self.foodCategoriesArray = [alitasAndBoneless,
                                    bistro,
                                    cafeteria,
                                    comidaChina,
                                    comidaRapida,
                                    gourmet,
                                    italiana,
                                    marisco,
                                    mexicana,
                                    sushi]
        
        self.servicesCategoriesArray = [automotriz,
                                        educacion,
                                        electronica,
                                        hogar,
                                        moda,
                                        viajes,
                                        saludAndBelleza]
        
        self.entertainmentCategoriesArray = [bar,
                                             cine,
                                             clubNocturno,
                                             deporte,
                                             parques,
                                             teatro]
    }
    
    @IBAction func setFoodSubcategories(sender: UIButton) {
        activeFilters.removeAll()
        for item in foodCategoriesArray {
            if item.on {
                activeFilters.append(item.tag)
            }
        }
        self.revealViewController().revealToggleAnimated(true)
        setFilterArray()
    }
    
    @IBAction func setServicesSubcategories(sender: UIButton) {
        activeFilters.removeAll()
        for item in servicesCategoriesArray {
            if item.on {
                activeFilters.append(item.tag)
            }
        }
        self.revealViewController().revealToggleAnimated(true)
        setFilterArray()
    }
    
    @IBAction func setEntertainmentSubcategories(sender: UIButton) {
        activeFilters.removeAll()
        for item in entertainmentCategoriesArray {
            if item.on {
                activeFilters.append(item.tag)
            }
        }
        self.revealViewController().revealToggleAnimated(true)
        setFilterArray()
        
    }
    
    
    func setFilterArray() {
        Utilities.filterArray = activeFilters
        NSNotificationCenter.defaultCenter().postNotificationName("filtersChanged", object: nil)

    }
    
    @IBAction func setViewController(sender: FilterSegmentedControl) {
        switch filterSegmented.selectedIndex {
            case 0:
                foodView.hidden = false
                servicesView.hidden = true
                entertainmentView.hidden = true
            case 1:
                foodView.hidden = true
                servicesView.hidden = false
                entertainmentView.hidden = true
            case 2:
                foodView.hidden = true
                servicesView.hidden = true
                entertainmentView.hidden = false
            default:
                break
            }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        let view = segue.destinationViewController as! NearbyMapViewController
//        view.filterArray = activeFilters
        //view.getNearestBranches(UIButton())
    }

   
    
}
