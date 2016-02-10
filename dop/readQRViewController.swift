//
//  readQRViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 20/11/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import AVFoundation

class readQRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var captureMetadataOutput:AVCaptureMetadataOutput?
    
    @IBOutlet var qr_instructions_view: UIView!
    @IBOutlet var qr_image: UIImageView!
    var qr_detected:Bool = false
    var loader:CustomInfiniteIndicator?
    
    var coupon_id:Int?
    var branch_id:Int?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /*self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.translucent = true*/

        loader = CustomInfiniteIndicator(frame: CGRectMake(self.view.frame.size.width/2-20, self.view.frame.size.height/2-20, 40, 40))

        loader!.alpha = 0
        
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
            captureSession?.addInput(input as! AVCaptureInput)
            
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
            
            view.addSubview(loader!)
            
            //view.bringSubviewToFront(blurView)
            //blurView.bringSubviewToFront(loader!)
            
            
            loader?.startAnimating()
            
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
                    
                    if let qrInt =  Int(metadataObj.stringValue){
                        if(qrInt == self.branch_id){
                            self.sendQR(qrInt)
                        } else {
                            let modal: ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
                            
                            modal.willPresentCompletionHandler = { vc in
                                let navigation_controller = vc as! AlertModalViewController
                                navigation_controller.setAlert("error", alert_title: "¡Oops!", alert_description: "Ha ocurrido un error, al parecer el QR no es el correcto")
                            }
                            modal.presentAnimated(true, completionHandler: nil)

                        }
                    } else {
                        print("Código Erroneo")
                    }
                }
            }
        }
    }
    
    func sendQR(qr_code:Int){
        
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
                    let name = json["data"]["name"].string

                    let modal: ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        modal.willPresentCompletionHandler = { vc in
                            let navigation_controller = vc as! AlertModalViewController
                            navigation_controller.setAlert("success", alert_title: "¡Felicidades!", alert_description: "Has redimido tu promoción con éxito en \(name!)")
                        }
                        modal.presentAnimated(true, completionHandler: nil)
                    }
                    
                    print(json)
                    print("Éxito")
                })
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    let modal: ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
                    
                    modal.willPresentCompletionHandler = { vc in
                        let navigation_controller = vc as! AlertModalViewController
                        navigation_controller.setAlert("error", alert_title: "¡Oops!", alert_description: "Ha ocurrido un error, al parecer es nuestra culpa :(")
                    }
                    modal.presentAnimated(true, completionHandler: nil)
                })
            }
        )
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
