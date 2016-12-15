//
//  PageTwoViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/10/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit
import AVFoundation

class PageTwoViewController: UIViewController {

    @IBOutlet weak var permission_button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.applyPlainShadow(permission_button)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func askPermission(_ sender: UIButton) {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .denied ||
            AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized {
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
            
        } else {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo,
                                          completionHandler: { granted in
                                            if granted {
                                                DispatchQueue.main.async {
//                                                    self.giverView.alpha = 0
//                                                    self.setCameraConfig()
                                                    
//                                                    Utilities.permanentBounce(self.qr_image, delay: 0.5, duration: 0.8)
//                                                    Utilities.fadeInFromTopAnimation(self.qr_instructions_view, delay: 0, duration: 1, yPosition: 15)
                                                    self.view.layoutIfNeeded()
                                                }
                                            } else {
                                                DispatchQueue.main.async {
                                                    sender.setTitle("😭 NO, CORAL", for: UIControlState.normal)
                                                }
                                            }
            }
            )
        }
    }
    

}
