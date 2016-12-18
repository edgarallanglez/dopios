//
//  LastPageViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/12/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

class LastPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        UserDefaults.standard.setValue(true, forKey: "tutorial_checked")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoadingViewController")
        
        self.present(controller, animated: true, completion: nil)
        controller.performSegue(withIdentifier: "showDashboard", sender: self)
        
        /*self.present(controller, animated: true, completion: {
            self.parent?.dismiss(animated: true, completion: nil)
        })*/
    }
}
