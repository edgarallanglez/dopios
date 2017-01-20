//
//  readQRViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 20/11/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import AVFoundation

class ReadQRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, ModalDelegate{
    var captureDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var captureMetadataOutput: AVCaptureMetadataOutput?
    @IBOutlet var problems_button: UIButton!
    @IBOutlet weak var giverView: UIView!
    @IBOutlet weak var qr_image_view: UIView!
    @IBOutlet var qr_instructions_view: UIView!
    @IBOutlet var qr_image: UIImageView!
    var qr_detected: Bool = false
    var loader:CustomInfiniteIndicator?
    var alert_array = [AlertModel]()
    var coupon_id: Int?
    var coupon: Coupon!
    var branch_id: Int?
    var spinner: MMMaterialDesignSpinner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == AVAuthorizationStatus.authorized {
            setCameraConfig()
        } else {
            let background = Utilities.Colors
            background.frame = self.view.bounds
            self.giverView.layer.insertSublayer(background, at: 0)
            self.giverView.alpha = 1
        }
    }


    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if(!self.qr_detected){
            // Check if the metadataObjects array is not nil and it contains at least one object.
            if metadataObjects == nil || metadataObjects.count == 0 {
                self.qrCodeFrameView?.frame = CGRect.zero
                print("No QR code is detected")
                return
            }
            
            // Get the metadata object.
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if metadataObj.type == AVMetadataObjectTypeQRCode {
                // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
                let barCodeObject = self.videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
                self.qrCodeFrameView?.frame = barCodeObject.bounds;
                
                if metadataObj.stringValue != nil {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

                    self.qr_detected = true
                    
                    if let qrInt = Int(metadataObj.stringValue) {
                        if qrInt == self.branch_id {
                            self.sendQR(qrInt)
                        } else {
                            let modal: ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
                            modal.willPresentCompletionHandler = { vc in
                                let navigation_controller = vc as! AlertModalViewController
                                
                                self.alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: "Ha ocurrido un error, al parecer el QR no es el correcto"))
                                navigation_controller.setAlert(self.alert_array)
                    
                            }
                            
                            modal.didDismissCompletionHandler = { view_controller in
                                self.qr_detected = false
                                self.alert_array.removeAll()
                            }
                            modal.present(animated: true, completionHandler: nil)
                        }
                    } else {
                        DispatchQueue.main.async(execute: {
                            let modal: ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
                            modal.delegate = self
                            modal.willPresentCompletionHandler = { vc in
                                let navigation_controller = vc as! AlertModalViewController
                                
                                self.alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: "Ha ocurrido un error, al parecer el QR no es válido ☹️"))
                                
                                navigation_controller.setAlert(self.alert_array)
                            }
                            
                            modal.didDismissCompletionHandler = { vc in
                                self.qr_detected = false
                                self.alert_array.removeAll()
                            }
                            
                            modal.present(animated: true, completionHandler: nil)
                        })

                    }
                }
            }
        }
    }
    
    func sendQR(_ qr_code:Int) {
        Utilities.fadeInViewAnimation(self.spinner, delay: 0, duration: 0.3)
        Utilities.fadeOutViewAnimation(self.qr_image, delay: 0, duration: 0.3)
        spinner?.startAnimating()
        
        var params: [String: AnyObject]
        
        params = [
            "qr_code" : qr_code as AnyObject,
            "coupon_id": self.coupon_id! as AnyObject,
            "branch_id": self.branch_id! as AnyObject,
            "latitude": User.coordinate.latitude as AnyObject? ?? 0 as AnyObject,
            "longitude": User.coordinate.longitude as AnyObject? ?? 0 as AnyObject,
            "first_using": User.first_using as AnyObject ]
        
        /*if User.first_using {
            params = [
                "qr_code" : qr_code as AnyObject,
                "coupon_id": self.coupon_id! as AnyObject,
                "branch_id": self.branch_id! as AnyObject,
                "latitude": User.coordinate.latitude as AnyObject? ?? 0 as AnyObject,
                "longitude": User.coordinate.longitude as AnyObject? ?? 0 as AnyObject,
                "first_using": false as AnyObject ]
        } else {
            params = [
                "qr_code" : qr_code as AnyObject,
                "coupon_id": self.coupon_id! as AnyObject,
                "branch_id": self.branch_id! as AnyObject,
                "latitude": User.coordinate.latitude as AnyObject? ?? 0 as AnyObject,
                "longitude": User.coordinate.longitude as AnyObject? ?? 0 as AnyObject,
                "first_using": true as AnyObject ]
            User.first_using = true
        }*/
        
        
        ReadQRController.sendQRWithSuccess(params,
            success: { (data) -> Void in
                DispatchQueue.main.async(execute: {
                    
                    let json = data!
                    print("JSON ES \(json)")
                    if json["message"].string != nil {
                        User.first_using = true
                        Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)
                        let error_modal: ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
                        
                        var error_message = "Esta promoción se ha terminado ☹️"
                        if json["minutes"].string != nil {
                            error_message = "Recientemente usaste esta promoción, intenta más tarde"
                        }
                        if json["message"].string == "expired" {
                            error_message = "Esta promoción ha caducado"
                        }
                        
                        error_modal.willPresentCompletionHandler = { vc in
                            let navigation_controller = vc as! AlertModalViewController
                            var alert_array = [AlertModel]()
                                
                            alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: error_message))
                            navigation_controller.setAlert(alert_array)
                        }
                        
                        error_modal.didDismissCompletionHandler = { vc in
                            self.qr_detected = false
                            self.alert_array.removeAll()
                        }
                        
                        error_modal.present(animated: true, completionHandler: nil)
                        
                    } else {
                        let name = json["data"]["name"].string!
                        let folio = json["folio"].string!
                        Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)
                        DispatchQueue.main.async(execute: {
                            let modal: ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
                        
                            modal.willPresentCompletionHandler = { vc in
                                let navigation_controller = vc as! AlertModalViewController
                                if self.coupon.adult_branch {
                                    navigation_controller.share_text.text = "  Esto no se compartirá 😏"
                                    navigation_controller.share_view.isHidden = false
                                    navigation_controller.share_activity.isOn = false
                                    navigation_controller.share_activity.isHidden = true
                                    
                                } else {
                                    navigation_controller.share_view.isHidden = false
                                }
                                self.alert_array.append(AlertModel(alert_title: "¡Felicidades!", alert_image: "success", alert_description: "Has redimido tu promoción con éxito en \(name)"))
                                print(json)
//                                
                                let badges_array = json["reward"]["badges"].array ?? []
                                if badges_array.count != 0 {
                                    let badges = json["reward"]["badges"].array!
                                    let badge_name: String = badges[0]["name"].string!
                                    let badge_id: Int = badges[0]["badge_id"].int!
                                    
                                    self.alert_array.append(AlertModel(alert_title: "¡Felicidades!", alert_image: "\(badge_id)", alert_description: "Has desbloqueado una nueva medalla \(badge_name)"))
                                }
                                navigation_controller.setAlert(self.alert_array)
                            }
                            
                            modal.willDismissCompletionHandler = { vc in
                                let alert_modal = vc as! AlertModalViewController
                                let params = ["folio": folio as AnyObject,
                                              "privacy_status": !alert_modal.share_activity.isOn as AnyObject ]
                                ReadQRController.setActivityPrivacy(params,
                                        success: { (data) in
                                            DispatchQueue.main.async {
                                                print("privacy success")
                                            }
                                        },
                                        failure: { (data) in
                                            DispatchQueue.main.async {
                                                print("privacy error")
                                            }
                                        }
                                    )
                                
                                self.alert_array.removeAll()
                                if alert_modal.alert_flag <= 1 {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        
                            modal.present(animated: true, completionHandler: nil)
                            self.coupon?.available = (self.coupon?.available)! - 1
                        })
                    }
                })
                
            },
            failure: { (error) -> Void in
                DispatchQueue.main.async(execute: {
                    Utilities.fadeOutViewAnimation(self.spinner, delay: 0, duration: 0.3)

                    let modal: ModalViewController = ModalViewController(currentView: self, type: ModalViewControllerType.AlertModal)
                    
                    modal.willPresentCompletionHandler = { vc in
                        let navigation_controller = vc as! AlertModalViewController
                    
                        self.alert_array.append(AlertModel(alert_title: "¡Oops!", alert_image: "error", alert_description: "Ha ocurrido un error, al parecer es nuestra culpa 😬"))
                        
                        navigation_controller.setAlert(self.alert_array)
                        
                        modal.didDismissCompletionHandler = { vc in
                            self.qr_detected = false
                            self.alert_array.removeAll()
                        }
                    }
                    modal.present(animated: true, completionHandler: nil)
                })
            }
    
        )
        
    }

    func pressActionButton(_ modal: ModalViewController) {
        modal.didDismissCompletionHandler = { vc in
            Utilities.fadeInViewAnimation(self.qr_image, delay: 0, duration: 0.3)
            self.qr_detected = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setCameraConfig() {
        
        problems_button.layer.borderColor = UIColor.white.cgColor
        problems_button.layer.borderWidth = 1.0
        problems_button.layer.cornerRadius = 3
        //problems_button.backgroundColor = UIColor.clearColor()
        
        spinner = MMMaterialDesignSpinner(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        spinner.center.x = self.view.center.x
        spinner.center.y = self.view.center.y
        spinner.layer.cornerRadius = spinner.frame.width / 2
        spinner.lineWidth = 3.0
        spinner.startAnimating()
        spinner.tintColor = Utilities.dopColor
        spinner.backgroundColor = UIColor.white
        
        self.title = coupon.name
        let input: AnyObject?
        
        do {
             captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo )
            input = try AVCaptureDeviceInput.init(device: captureDevice )
        } catch {
            if let error = error as NSError? {
                print( "<error>", error.code, error.domain, error.localizedDescription )
            }
            return
        }
        
        if let input = input as! AVCaptureInput? {
//            let queue = DispatchQueue(label: "camera", attributes: [])
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input )
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            
            captureMetadataOutput!.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
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
//            qrCodeFrameView?.backgroundColor = Utilities.dopColor
            qrCodeFrameView?.alpha = 0
            //qrCodeFrameView?.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView!)
            Utilities.permanentBounce(self.qr_image, delay: 0.5, duration: 0.8)
            view.bringSubview(toFront: self.qr_instructions_view)
            view.bringSubview(toFront: self.qr_image_view)
            view.bringSubview(toFront: self.problems_button)
            
            self.view.addSubview(spinner)
            spinner.alpha = 0
            
            print("Category is \(self.coupon.categoryId)")
            

        }

        self.view.layoutIfNeeded()
    }
    
    @IBAction func askPermission(_ sender: UIButton) {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .denied {
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }

        } else {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo,
                                          completionHandler: { granted in
                                            if granted {
                                                DispatchQueue.main.async {
                                                    self.giverView.alpha = 0
                                                    self.setCameraConfig()
                                                    
                                                    Utilities.permanentBounce(self.qr_image, delay: 0.5, duration: 0.8)
                                                    Utilities.fadeInFromTopAnimation(self.qr_instructions_view, delay: 0, duration: 1, yPosition: 15)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination_view = segue.destination as! ReadQRHelpViewController
        destination_view.coupon = self.coupon
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == AVAuthorizationStatus.authorized {
//            setCameraConfig()
//        } else {
//            let background = Utilities.Colors
//            background.frame = self.view.bounds
//            self.giverView.layer.insertSublayer(background, at: 0)
//            self.giverView.alpha = 1
//        }
    }
    
    @IBAction func turnLightOn(_ sender: Any) {
        if (captureDevice?.hasTorch)! {
            do {
                try captureDevice?.lockForConfiguration()
                if (captureDevice?.torchMode == AVCaptureTorchMode.on) {
                    captureDevice?.torchMode = AVCaptureTorchMode.off
                    (sender as! UIButton).setBackgroundImage(UIImage(named: "lintern"), for: .normal)
                } else {
                    do {
                        (sender as! UIButton).setBackgroundImage(UIImage(named: "lintern_inverted"), for: .normal)
                        try captureDevice?.setTorchModeOnWithLevel(1.0)
                    } catch {
                        print(error)
                    }
                }
                captureDevice?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.captureSession?.stopRunning()
        self.videoPreviewLayer?.removeFromSuperlayer()
        self.videoPreviewLayer = nil
        self.captureSession = nil
    }
}
