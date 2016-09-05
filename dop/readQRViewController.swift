//
//  readQRViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 20/11/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import AVFoundation

class readQRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, ModalDelegate{
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var captureMetadataOutput:AVCaptureMetadataOutput?
    @IBOutlet var problems_button: UIButton!
    
    @IBOutlet var qr_instructions_view: UIView!
    @IBOutlet var qr_image: UIImageView!
    var qr_detected:Bool = false
    var loader:CustomInfiniteIndicator?
    var alert_array = [AlertModel]()
    var coupon_id:Int?
    var coupon: Coupon!
    var branch_id:Int?
    var spinner: MMMaterialDesignSpinner!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /*self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.translucent = true*/

        
        problems_button.layer.borderColor = UIColor.whiteColor().CGColor
        problems_button.layer.borderWidth = 1.0
        problems_button.layer.cornerRadius = 3
        //problems_button.backgroundColor = UIColor.clearColor()
        
        
        spinner = MMMaterialDesignSpinner(frame: CGRectMake(0, 0, 50, 50))
        spinner.center.x = self.view.center.x
        spinner.center.y = self.view.center.y
        spinner.layer.cornerRadius = spinner.frame.width / 2
        spinner.lineWidth = 3.0
        spinner.startAnimating()
        spinner.tintColor = Utilities.dopColor
        spinner.backgroundColor = UIColor.whiteColor()

        
        self.title = coupon.name
        
        let input: AnyObject?
        
        do {
            let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType( AVMediaTypeVideo )
            input = try AVCaptureDeviceInput.init( device: captureDevice )
        } catch {
            if let error = error as NSError?
            {
                print( "<error>", error.code, error.domain, error.localizedDescription )
            }
            return
        }
        
        if let input = input as! AVCaptureInput? {
            let queue = dispatch_queue_create("camera", nil)
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input )
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            
            captureMetadataOutput!.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            captureMetadataOutput!.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            //qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
            qrCodeFrameView?.backgroundColor = Utilities.dopColor
            qrCodeFrameView?.alpha = 0
            //qrCodeFrameView?.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView!)
            view.bringSubviewToFront(qrCodeFrameView!)
            
            self.view.addSubview(spinner)
            spinner.alpha = 0

            //view.bringSubviewToFront(blurView)
            //blurView.bringSubviewToFront(loader!)
            
            

           print("EL CODIGO ES \(branch_id)")
        }
        
        
        //self.blurViewLeadingConstraint.constant = UIScreen.mainScreen().bounds.size.width
        
    
        
        self.view.layoutIfNeeded()
        
        self.qr_image.alpha = 0
        self.qr_instructions_view.alpha = 0

    }


    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if(!self.qr_detected){
            // Check if the metadataObjects array is not nil and it contains at least one object.
            if metadataObjects == nil || metadataObjects.count == 0 {
                self.qrCodeFrameView?.frame = CGRectZero
                print("No QR code is detected")
                return
            }
            
            // Get the metadata object.
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if metadataObj.type == AVMetadataObjectTypeQRCode {
                // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
                let barCodeObject = self.videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
                self.qrCodeFrameView?.frame = barCodeObject.bounds;
                
                if metadataObj.stringValue != nil {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    //captureSession?.stopRunning()
                    self.qr_detected = true
                    
                    if let qrInt =  Int(metadataObj.stringValue) {
                        if(qrInt == self.branch_id){
                            
                            self.sendQR(qrInt)
                        } else {
                            let modal: ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
                            modal.willPresentCompletionHandler = { vc in
                                let navigation_controller = vc as! AlertModalViewController
                                
                                self.alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: "Ha ocurrido un error, al parecer el QR no es el correcto"))
                                navigation_controller.setAlert(self.alert_array)
                    
                            }
                            modal.didDismissCompletionHandler = { vc in
                                self.qr_detected = false
                            }
                            modal.presentAnimated(true, completionHandler: nil)

                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            let modal: ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
                            modal.delegate = self
                            modal.willPresentCompletionHandler = { vc in
                                let navigation_controller = vc as! AlertModalViewController
                                
                                self.alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: "Ha ocurrido un error, al parecer el QR no es válido :("))
                                
                                navigation_controller.setAlert(self.alert_array)
                            }
                            modal.didDismissCompletionHandler = { vc in
                                self.qr_detected = false
                            }
                            modal.presentAnimated(true, completionHandler: nil)
                        })

                    }
                }
            }
        }
    }
    
    func sendQR(qr_code:Int){
        Utilities.fadeInViewAnimation(self.spinner, delay: 0, duration: 0.3)
        Utilities.fadeOutViewAnimation(self.qr_image, delay: 0, duration: 0.3)
        spinner?.startAnimating()

        /*UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.loader!.alpha = 1
            }, completion: nil)*/
        
        let params:[String: AnyObject] = [
            "qr_code" : qr_code,
            "coupon_id": self.coupon_id!,
            "branch_id": self.branch_id!,
            "latitude": User.coordinate.latitude ?? 0,
            "longitude": User.coordinate.longitude ?? 0 ]
        
        
        readQRController.sendQRWithSuccess(params,
            success: { (couponsData) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let json = JSON(data: couponsData)
                    print(json)
                    if let message = json["message"].string {
                            Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)
                            let error_modal: ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
                        
                            var error_message = "Esta promoción se ha terminado :("
                            if let recently_used = json["minutes"].string {
                                error_message = "Recientemente usaste esta promoción, intenta más tarde"
                            }
                            error_modal.willPresentCompletionHandler = { vc in
                                let navigation_controller = vc as! AlertModalViewController
                                
                                var alert_array = [AlertModel]()
                                
                                alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: error_message))
                                
                                navigation_controller.setAlert(alert_array)
                                
                            }
                            error_modal.didDismissCompletionHandler = { vc in
                                self.qr_detected = false
                            }
                             error_modal.presentAnimated(true, completionHandler: nil)
                        
                        
                    }else{
                        let name = json["data"]["name"].string
                        print(json)

                        let modal: ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)

                            modal.willPresentCompletionHandler = { vc in
                                let navigation_controller = vc as! AlertModalViewController
                                
                                
                                self.alert_array.append(AlertModel(alert_title: "¡Felicidades!", alert_image: "success", alert_description: "Has redimido tu promoción con éxito en \(name!)"))
                                
                                if json["reward"]["badges"].count != 0 {
                                    let badges = json["reward"]["badges"].array!
                                    let badge_name: String = badges[0]["name"].string!
                                    print(badge_name)
                                    
                                    self.alert_array.append(AlertModel(alert_title: "¡Felicidades!", alert_image: "\(badge_name)", alert_description: "Has desbloqueado una nueva medalla \(badge_name)"))
                                }
                                
                                navigation_controller.setAlert(self.alert_array)
                                
                            }
                            modal.willDismissCompletionHandler = { vc in
                                let alert_modal = vc as! AlertModalViewController
                                if alert_modal.alert_flag <= 1 {
                                    self.navigationController?.popViewControllerAnimated(true)
                                }
                            }
                            modal.presentAnimated(true, completionHandler: nil)
                            self.coupon?.available = (self.coupon?.available)! - 1
                        }
                    }
                })
                
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)

                    let modal: ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
                    
                    modal.willPresentCompletionHandler = { vc in
                        let navigation_controller = vc as! AlertModalViewController
                    
                        self.alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: "Ha ocurrido un error, al parecer es nuestra culpa :("))
                        
                        navigation_controller.setAlert(self.alert_array)
                        
                        modal.didDismissCompletionHandler = { vc in
                            self.qr_detected = false
                        }
                       
                    }
                    modal.presentAnimated(true, completionHandler: nil)
                })
            }
    
        )
        
    }

    func pressActionButton(modal: ModalViewController) {
        modal.didDismissCompletionHandler = { vc in
            Utilities.fadeInViewAnimation(self.qr_image, delay: 0, duration: 0.3)
            self.qr_detected = false
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*@IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {
            self.removeFromParentViewController()
        })
    }*/
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        Utilities.permanentBounce(qr_image, delay: 0.5, duration: 0.8)
        Utilities.fadeInFromTopAnimation(qr_instructions_view, delay: 0, duration: 1, yPosition: 15)
    }

    /*
    override func viewWillDisappear(animated: Bool) {
        UIAppliºcation.sharedApplication().statusBarHidden = false

    }*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
