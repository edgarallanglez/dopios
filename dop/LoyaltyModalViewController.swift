
//
//  LoyaltyModalViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 7/10/17.
//  Copyright © 2017 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SocketIO

class LoyaltyModalViewController: UIViewController {
    

    
    let socket = SocketIOClient(socketURL: URL(string: "http://45.55.7.118:5000")!, config: [.log(true), .compress])
    
    
    @IBOutlet weak var close_button: UIButton!
    @IBOutlet weak var action_button: WhiteModalButton!
    @IBOutlet weak var loyalty_name: UIButton!
    @IBOutlet weak var loyalty_about: UILabel!
    @IBOutlet weak var loyalty_logo: UIImageView!
    @IBOutlet weak var loyalty_progress: KAProgressLabel!
    
    
    var loyalty: Loyalty!
    var percent: Double!
    var progress: Double!

    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
//        
//        
        if((action_button) != nil) {
            action_button.addTarget(self, action: #selector(LoyaltyModalViewController.buttonPressed(_:)), for: UIControlEvents.touchDown)
            action_button.addTarget(self, action: #selector(LoyaltyModalViewController.buttonReleased(_:)), for: UIControlEvents.touchDragOutside)
            action_button.addTarget(self, action: #selector(LoyaltyModalViewController.actionTouched(_:)), for: UIControlEvents.touchUpInside)
        }
        
        if((close_button) != nil){
            close_button.addTarget(self, action: #selector(LoyaltyModalViewController.closePressed(_:)), for: .touchDown)
        }
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            let data:[String: Any] = ["user_id": User.user_id,
                        "user_image": User.userImageUrl,
                        "user_name": User.userName,
                        "room": "\(self.loyalty.loyalty_id!)\(self.loyalty.owner_id!)",
                        "join_room": true,
                        "visit": self.loyalty.visit!,
                        "goal": self.loyalty.goal!]
            
            
            self.socket.emit("waitingForRedeemUseriOS", data)
        }
        
        socket.on("newAdmin") {data, ack in
            let data:[String: Any] = ["user_id": User.user_id,
                                      "user_image": User.userImageUrl,
                                      "user_name": User.userName,
                                      "room": "\(self.loyalty.loyalty_id!)\(self.loyalty.owner_id!)",
                "join_room": false,
                "visit": self.loyalty.visit!,
                "goal": self.loyalty.goal!]
            
            
            self.socket.emit("waitingForRedeemUseriOS", data)
        }
        socket.on("loyaltyRedeem") { data, ack in
            self.loyalty.visit = self.loyalty.visit+1
            if(self.loyalty.visit>self.loyalty.goal){
                self.loyalty.visit = 0;
            }
            
            self.setProgress()
            ParticleEmmiter.confettiParticle(container: self.loyalty_progress)

            //parent.progress.setText(loyalty.visit + "/" + loyalty.goal);
        }
        socket.on("loyaltyFail"){ data, ack in
            let data_array = data[0] as! NSDictionary
            let string_minutes = String(describing: data_array["minutes"]!)
            print(string_minutes)
            let minutes = Double(string_minutes)
            var rounded_minutes = Int(minutes!)
            
            var time_string = "horas"
            if rounded_minutes>=60 {
                rounded_minutes = rounded_minutes/60
            }else{
                time_string = "minutos"
            }
            
            let alert = UIAlertController(title: "!Oops!", message: "Hiciste válida esta promoción recientemente, debes esperar \(rounded_minutes) \(time_string) para que puedas usarla nuevamente.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: { action in
                switch action.style{
                case .default:
                    self.mz_dismissFormSheetController(animated: true, completionHandler: nil)

                case .cancel:
                    self.mz_dismissFormSheetController(animated: true, completionHandler: nil)

                case .destructive:
                    self.mz_dismissFormSheetController(animated: true, completionHandler: nil)

                }
            }))
            
            self.socket.disconnect()
            
            self.present(alert, animated: true, completion: nil)
        }
       socket.connect()

    }

    func buttonPressed(_ sender: WhiteModalButton){
        sender.isSelected = true
    }
    
    func buttonReleased(_ sender: WhiteModalButton){
        sender.isSelected = false
    }
    
    func cancelTouched(_ sender: WhiteModalButton){
        sender.isSelected = false
        
        self.mz_dismissFormSheetController(animated: true, completionHandler: { (MZFormSheetController) -> Void in
            
        })
    }
    
    func actionTouched(_ sender: WhiteModalButton){
        sender.isSelected = false
    }
    
    func closePressed(_ sender: UIButton){
        self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if loyalty != nil { setModal() }
        if action_button != nil { action_button.layoutIfNeeded() }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setModal() {
        loyalty_name.setTitle(loyalty.name.uppercased(), for: .normal)
        self.loyalty_about.text = loyalty?.about
        Utilities.fadeInFromBottomAnimation(self.loyalty_name, delay: 0, duration: 0.5, yPosition: 30)

        if loyalty.logo_image == nil {
            let image_url = URL(string: "\(Utilities.LOYALTY_URL)\(loyalty.logo!)")
            
            Alamofire.request(image_url!).responseImage { response in
                if let image = response.result.value {
                    self.loyalty_logo.image = image
                    
                    Utilities.fadeInViewAnimation(self.loyalty_logo, delay: 0, duration: 0.7)
                } else {
                    self.loyalty_logo.image = UIImage(named: "dop-logo-transparent")
                    //reward_box.backgroundColor = Utilities.lightGrayColor
                    self.loyalty_logo.alpha = 0.3
                }
                //Utilities.fadeInViewAnimation(coupon_box.logo, delay:0, duration:1)
            }
        } else {
            self.loyalty_logo.image = loyalty.logo_image
            Utilities.fadeInViewAnimation(self.loyalty_logo, delay: 0, duration: 0.7)
        }
        
        setProgress()
        
    }
    
    func setProgress() {
        loyalty_progress.alpha = 1
        loyalty_progress.startDegree = 0
        loyalty_progress.progressColor = UIColor(red: 33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        loyalty_progress.trackColor = Utilities.lightGrayColor
        loyalty_progress.trackWidth = 3
        loyalty_progress.progressWidth = 3
        percent = loyalty.visit / loyalty.goal
        progress = 360 * percent
        loyalty_progress.setEndDegree(CGFloat(progress), timing: TPPropertyAnimationTimingEaseInEaseOut, duration: 1.5, delay: 0)
    }
    
    func setLittleSize() {
        self.loyalty_about.font = UIFont(name: "Montserrat-Regular", size: 14)
    }
    
    
    func didBecomeActive() {
        print("entro el socket")
    }
    
}
