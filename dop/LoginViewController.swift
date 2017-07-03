//
//  ViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 5/4/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import JWTDecode

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, CLLocationManagerDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    
    @IBOutlet var forgot_password_cancel_button: UIButton!
    @IBOutlet var forgot_password_email: LoginTextView!
    @IBOutlet var login_view: UIView!
    @IBOutlet var forgot_password_view: UIView!
    @IBOutlet var sign_up_or_login_button_height: NSLayoutConstraint!
    @IBOutlet var sign_up_error_label: UILabel!
    @IBOutlet var sign_up_email: LoginTextView!
    @IBOutlet var swipe_down: UISwipeGestureRecognizer!
    
    @IBOutlet var sign_up_password: LoginTextView!
    @IBOutlet var signup_login_button: UIButton!
    
    @IBOutlet var forgot_password_error_label: UILabel!
    
    @IBOutlet var error_label: UILabel!
    @IBOutlet var sign_up_confirm_password: LoginTextView!
    @IBOutlet var fbLoginViewHeight: NSLayoutConstraint!
    @IBOutlet var fbButtonHeight: NSLayoutConstraint!
    @IBOutlet var email_login_button: UIButton!
    @IBOutlet var sign_up_view_scroll_content: UIView!
    @IBOutlet var login_email_text: UITextField!
    @IBOutlet var login_password_text: LoginTextView!
    @IBOutlet var sign_up_scroll: UIScrollView!
    @IBOutlet var sign_up_or_login_button: UIButton!
    
    @IBOutlet var sign_up_view_height_constrain: NSLayoutConstraint!
    @IBOutlet var sign_up_view_bottom_constrain: NSLayoutConstraint!
    @IBOutlet weak var MD_spinner: MMMaterialDesignSpinner!
    @IBOutlet weak var fbLoginView: FBSDKLoginButton!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var dopLogo: UIImageView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet var sign_up_view: UIView!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var flat_city_image: UIImageView!
    @IBOutlet weak var LoginButtonView: UIView!
    @IBOutlet weak var dop_logo_y_constraint: NSLayoutConstraint!
    
    var tutorial_checked = false
    
    var kClientId = "517644806961-ocmqel4aloa86mtsn5jsmmuvi3fcdpln.apps.googleusercontent.com";
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        
        if UserDefaults.standard.object(forKey: "tutorial_checked") != nil {
            tutorial_checked = UserDefaults.standard.value(forKeyPath: "tutorial_checked") as! Bool
        }
        
        let background = Utilities.Colors
        background.frame = self.view.bounds
        self.view.layer.insertSublayer(background, at: 0)
        Utilities.slideFromBottomAnimation(self.dopLogo, delay: 0, duration: 1.5, yPosition: 700)
        
        self.fbButton.alpha = 0
        self.MD_spinner.lineWidth = 3
        self.MD_spinner.startAnimating()
        self.MD_spinner.alpha = 0
        
        locationManager = CLLocationManager()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends", "user_birthday", "gender"]
        
        
        if (FBSDKAccessToken.current() != nil) {
            // User is already logged in, do work such as go to next view controller.
            self.getFBUserData()
        }
        
        sign_up_view_bottom_constrain.constant = -(UIScreen.main.bounds.height/2)
        
        self.signup_login_button.layer.borderColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 0.1).cgColor
        self.forgot_password_cancel_button.layer.borderColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 0.1).cgColor
        
        login_email_text.delegate = self
        login_password_text.delegate = self
        sign_up_email.delegate = self
        sign_up_password.delegate = self
        sign_up_confirm_password.delegate = self
        
        
        sign_up_scroll.delegate = self
        
        error_label.text = ""
        sign_up_error_label.text = ""
        forgot_password_error_label.text = ""
        
        self.LoginButtonView.clipsToBounds = true
        self.fbButton.clipsToBounds = true
        
        self.swipe_down.addTarget(self, action: #selector(swipeDown))
        self.swipe_down.direction = .down
        
    }
    func swipeDown(gesture: UIGestureRecognizer) {
        self.showSignUpAnimation(flag: false)
        
        self.login_email_text.resignFirstResponder()
        self.login_password_text.resignFirstResponder()
        self.sign_up_email.resignFirstResponder()
        self.sign_up_password.resignFirstResponder()
        self.sign_up_confirm_password.resignFirstResponder()
        self.forgot_password_email.resignFirstResponder()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.login_email_text.resignFirstResponder()
        self.login_password_text.resignFirstResponder()
        
        self.sign_up_email.resignFirstResponder()
        self.sign_up_password.resignFirstResponder()
        self.sign_up_confirm_password.resignFirstResponder()
        self.forgot_password_email.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == login_email_text {
            login_password_text.becomeFirstResponder()
        }
        if textField == login_password_text {
            self.emailLogIn(self)
        }
        if textField == sign_up_email {
            sign_up_password.becomeFirstResponder()
        }
        if textField == sign_up_password {
            sign_up_confirm_password.becomeFirstResponder()
        }
        if textField == sign_up_confirm_password {
            self.emailValidation(self)
        }
        if textField == forgot_password_email {
            self.forgotPassword(self)
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == sign_up_confirm_password {
            self.sign_up_view_bottom_constrain.constant = 100
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == sign_up_confirm_password{
            self.sign_up_view_bottom_constrain.constant = 0
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    @IBAction func touchScreen(_ sender: Any) {
        self.login_email_text.resignFirstResponder()
        self.login_password_text.resignFirstResponder()
        self.sign_up_email.resignFirstResponder()
        self.sign_up_password.resignFirstResponder()
        self.sign_up_confirm_password.resignFirstResponder()
        self.forgot_password_email.resignFirstResponder()

    }
    
    @IBAction func emailLogIn(_ sender: Any) {
        login_password_text.resignFirstResponder()
        login_email_text.resignFirstResponder()
        sign_up_email.resignFirstResponder()
        sign_up_password.resignFirstResponder()
        sign_up_confirm_password.resignFirstResponder()
        
        error_label.text = ""
        sign_up_error_label.text = ""
        
        if login_email_text.text != "" && login_password_text.text != ""{
            Utilities.fadeInFromBottomAnimation(self.MD_spinner, delay: 0, duration: 1, yPosition: 5)
            self.showSignUpAnimation(flag: false)
            
            
            
            let params:[String: String] = [
                "email" : login_email_text.text!,
                "password" : login_password_text.text!]
            
            
            
            LoginController.loginWithEmail("\(Utilities.dopURL)user/login/email", params: params as [String : AnyObject],
                                           success: { (loginData) -> Void in
                                            let json = loginData!
                                            
                                            Utilities.fadeOutViewAnimation(self.MD_spinner, delay: 0, duration: 1)
                                            
                                            
                                            print(json)
                                            
                                            if let token = json["token"].string {
                                                User.loginType = "email"
                                                A0SimpleKeychain().setString(token, forKey:"auth0-user-jwt")
                                                User.userToken = [ "Authorization": "\(token)" ]
                                                self.getUserData()
                                            }else{
                                                self.error_label.text = "Verifica tu correo y contraseña"
                                                
                                                self.showSignUpAnimation(flag: true)
                                            }
                                            
                                            
            },
                                           failure:{ (error) -> Void in
                                            self.error_label.text = "Problemas de conexión ☹️"
                                            Utilities.fadeOutViewAnimation(self.MD_spinner, delay: 0, duration: 1)
                                            
                                            self.showSignUpAnimation(flag: true)
                                            
            })
        }else{
            error_label.text = "No olvides escribir tu correo y password"
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        login_email_text.text = ""
        login_password_text.text = ""
        sign_up_email.text = ""
        sign_up_password.text = ""
        sign_up_confirm_password.text = ""
        
        /*sign_up_view_bottom_constrain.constant = -(UIScreen.main.bounds.height/2)
         self.view.layoutIfNeeded()
         
         self.fbButton.isUserInteractionEnabled = true
         self.sign_up_or_login_button.isUserInteractionEnabled = true*/
        
        
        
    }
    
    func goBackToFBLogin(_ sender: Any) {
        showSignUpAnimation(flag: false)
    }
    
    @IBAction func emailValidation(_ sender: Any) {
        login_password_text.resignFirstResponder()
        login_email_text.resignFirstResponder()
        sign_up_email.resignFirstResponder()
        sign_up_password.resignFirstResponder()
        sign_up_confirm_password.resignFirstResponder()
        
        error_label.text = ""
        sign_up_error_label.text = ""
        
        if sign_up_email.text != "" && sign_up_password.text != "" && sign_up_confirm_password.text != ""{
            if self.isValidEmail(testStr: sign_up_email.text!) {
                if (self.sign_up_password.text?.characters.count)! > 5{
                    if self.sign_up_password.text == self.sign_up_confirm_password.text{
                        
                        Utilities.fadeInFromBottomAnimation(self.MD_spinner, delay: 0, duration: 1, yPosition: 5)
                        
                        self.showSignUpAnimation(flag: false)
                        
                        let params:[String: String] = [
                            "email" : sign_up_email.text!,
                            "password" : sign_up_password.text!,
                            "device_os": "ios"]
                        
                        LoginController.verifyEmail("\(Utilities.dopURL)user/signup/email/verification", params: params as [String : AnyObject],
                                                    success: { (loginData) -> Void in
                                                        let json = loginData!
                                                        
                                                        print(json)
                                                        
                                                        if let token = json["token"].string{
                                                            User.loginType = "email"
                                                            A0SimpleKeychain().setString(token, forKey:"auth0-user-jwt")
                                                            User.userToken = [ "Authorization": "\(token)" ]
                                                            self.getUserData()
                                                        }else{
                                                            self.sign_up_error_label.text = "El email ya esta registrado 😱"
                                                            
                                                            self.showSignUpAnimation(flag: true)
                                                        }
                                                        
                                                        Utilities.fadeOutViewAnimation(self.MD_spinner, delay: 0, duration: 1)
                                                        
                        },
                                                    failure:{ (error) -> Void in
                                                        self.sign_up_error_label.text = "Problemas de conexión ☹️"
                                                        
                                                        Utilities.fadeOutViewAnimation(self.MD_spinner, delay: 0, duration: 1)
                                                        
                                                        self.showSignUpAnimation(flag: true)
                                                        
                        })
                    }else{
                        self.sign_up_error_label.text = "El password no coincide, verificalo"
                    }
                }else{
                    self.sign_up_error_label.text = "El password debe tener al menos 6 caracteres"
                }
            }else{
                self.sign_up_error_label.text = "Verifica tu email"
            }
        }else{
            self.sign_up_error_label.text = "No olvides llenar todos los campos"
        }
    }
    
    func showSignUpAnimation(flag: Bool){
        if flag == true {
            self.sign_up_view_bottom_constrain.constant = 0
            fbLoginViewHeight.isActive = false
            fbButtonHeight.isActive = false
            
            self.sign_up_or_login_button.setTitle("", for: .normal)
            self.sign_up_or_login_button.setImage(UIImage(named: "push_down"), for: .normal)
            self.sign_up_or_login_button.removeTarget(self, action: #selector(showSignUp(_:)), for: .touchUpInside)
            
            self.sign_up_or_login_button.addTarget(self, action: #selector(goBackToFBLogin(_:)), for: .touchUpInside)
            
            
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.dopLogo.alpha = 0
                
                self.login_email_text.resignFirstResponder()
                self.login_password_text.resignFirstResponder()
                self.sign_up_email.resignFirstResponder()
                self.sign_up_password.resignFirstResponder()
                self.sign_up_confirm_password.resignFirstResponder()
                self.forgot_password_email.resignFirstResponder()
                
            })
        }else{
            self.sign_up_or_login_button.removeTarget(self, action:  #selector(goBackToFBLogin(_:)), for: .touchUpInside)
            
            self.sign_up_or_login_button.setTitle("Iniciar sesion", for: .normal)
            self.sign_up_or_login_button.setImage(nil, for: .normal)
            self.sign_up_or_login_button.addTarget(self, action: #selector(showSignUp(_:)), for: .touchUpInside)
            
            self.sign_up_view_bottom_constrain.constant = -(UIScreen.main.bounds.height/2)
            fbLoginViewHeight.isActive = true
            fbButtonHeight.isActive = true
            
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.dopLogo.alpha = 1
                self.fbButton.alpha = 1
                
                self.login_email_text.resignFirstResponder()
                self.login_password_text.resignFirstResponder()
                self.sign_up_email.resignFirstResponder()
                self.sign_up_password.resignFirstResponder()
                self.sign_up_confirm_password.resignFirstResponder()
                self.forgot_password_email.resignFirstResponder()
                
            })
        }
        
    }
    
    
    @IBAction func slideToSignUp(_ sender: Any) {
        var frame = sign_up_scroll.frame;
        frame.origin.x = UIScreen.main.bounds.width
        frame.origin.y = 0;
        
        self.sign_up_scroll.contentInset = .zero
        
        
        self.sign_up_scroll.setContentOffset(frame.origin, animated: true)
        
        
    }
    
    
    func getUserData(){
        do {
            let payload = try decode(jwt: User.userToken["Authorization"]!)
            User.user_id = payload.body["id"]! as! Int
        } catch {
            self.performSegue(withIdentifier: "showLogin", sender: self)
            print("Failed to decode JWT: \(error)")
        }
        
        UserProfileController.getUserProfile(User.user_id, success: { (data) -> Void in
            let json = data!
            for (_, subJson): (String, JSON) in json["data"] {
                let names = subJson["names"].string ?? ""
                let surnames = subJson["surnames"].string ?? ""
                let facebook_key = subJson["facebook_key"].string ?? ""
                let user_id = subJson["user_id"].int!
                let birth_date = subJson["birth_date"].string ?? ""
                let privacy_status = subJson["privacy_status"].int ?? 0
                let main_image = subJson["main_image"].string ?? ""
                let level = subJson["level"].int ?? 0
                let exp = subJson["exp"].double ?? 0
                let is_friend = subJson["is_friend"].bool!
                let email = subJson["email"].string ?? ""
                //let total_used = subJson["total_used"].int!
                
                User.userName = names
                User.userSurnames = surnames
                User.userImageUrl = main_image
                User.userEmail = email
                // self.person = model
            }
            
            DispatchQueue.main.async(execute: {
                LoginController.getPrivacyInfo(success: { (response) in
                    let json = response!["data"][0]
                    
                    
                    User.privacy_status = json["privacy_status"].int!
                    User.first_following = json["first_following"].bool!
                    User.first_follower = json["first_follower"].bool!
                    User.first_company_fav = json["first_company_fav"].bool!
                    User.first_using = json["first_using"].bool!
                    
                    //User.adult = json["adult"].bool!
                    
                }, failure: { (userData) in
                    print(userData)
                })
                
                User.activeSession = true
                
                
                if User.userName == "" ||  User.userEmail == ""{
                    let storyboard = UIStoryboard(name: "Register", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "RegisterViewController")
                    self.present(controller, animated: true, completion: nil)
                } else {
                    if self.tutorial_checked {
                        self.performSegue(withIdentifier: "showDashboard", sender: self)
                        UIApplication.shared.registerForRemoteNotifications()
                    } else {
                        let storyboard = UIStoryboard(name: "Tutorial", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "TutorialContentViewController")
                        self.present(controller, animated: true, completion: nil)
                    }
                }
            })
            
            
        }, failure: { (error) -> Void in
            DispatchQueue.main.async(execute: {
                print("Error")
            })
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.MD_spinner.alpha = 0
        self.dop_logo_y_constraint.constant = -200
        UIView.animate(withDuration: 0.8, animations: { self.view.layoutIfNeeded() })
        Utilities.slideFromBottomAnimation(flat_city_image, delay: 0.4, duration: 1.5, yPosition: 700)
        Utilities.slideFromBottomAnimation(self.LoginButtonView, delay: 0.4, duration: 1.5, yPosition: 700)
        Utilities.slideFromBottomAnimation(self.sign_up_or_login_button, delay: 0.4, duration: 1.5, yPosition: 700)
        Utilities.fadeInViewAnimation(self.fbButton, delay: 1, duration: 0.7)
        
        self.sign_up_scroll.contentSize = CGSize(width: UIScreen.main.bounds.width*2, height: sign_up_scroll.frame.size.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func showSignUp(_ sender: Any) {
        self.showSignUpAnimation(flag: true)
        
        
        //self.fbButton.isUserInteractionEnabled = false
        //self.sign_up_or_login_button.isUserInteractionEnabled = false
        
    }
    
    //Google + login
    //    @IBAction func signInWithGoogle(sender: AnyObject) {
    ////        let signIn = GPPSignIn.sharedInstance();
    ////        signIn.authenticate();
    //    }
    //
    //    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
    //       if (GPPSignIn.sharedInstance().googlePlusUser != nil){
    //            print("Sign in")
    //            let user = GPPSignIn.sharedInstance().googlePlusUser
    //            let userId = GPPSignIn.sharedInstance().googlePlusUser.identifier
    //            let userEmail = user.emails.first?.value ?? ""
    //            let userImage =  user.image.url + "&sz=320"
    //
    //        print(userImage)
    //            let params:[String: String] = [
    //                "google_key" : userId,
    //                "names" : user.name.givenName,
    //                "surnames":user.name.familyName,
    //                "birth_date" : "2015-01-01",
    //                "email": userEmail,
    //                "main_image":userImage]
    //
    //            self.socialLogin("google", params: params)
    //        } else {
    //           print("Signed out.");
    //        }
    //    }
    
    //Twitter login
    //    @IBAction func signInWithTwitter(sender: UIButton) {
    //        Twitter.sharedInstance().logInWithCompletion { (session: TWTRSession!, error: NSError!) -> Void in
    //            if (session != nil) {
    //                Twitter.sharedInstance().logInWithCompletion { (session: TWTRSession!, error: NSError!) -> Void in
    //                    if (session != nil) {
    //                        Twitter.sharedInstance().APIClient.loadUserWithID(session.userID) { twtrUser,
    //                            NSError -> Void in
    //
    //                            var fullNameArr = twtrUser!.name.characters.split {$0 == " "}.map { String($0) }
    //                            let firstName: String = fullNameArr[0]
    //                            let lastName: String! = fullNameArr.count > 1 ? fullNameArr[1] : nil
    //                            let userImage = twtrUser!.profileImageLargeURL
    //
    //                            let params:[String: String] = [
    //                                "twitter_key" : twtrUser!.userID,
    //                                "names" : firstName,
    //                                "surnames": lastName,
    //                                "birth_date" : "2015-01-01",
    //                                "email" : "",
    //                                "main_image" : userImage
    //                            ]
    //
    //                            self.socialLogin("twitter", params: params)
    //
    //                        }
    //
    //                    } else {
    //                        print("error: \(error.localizedDescription)");
    //                    }
    //
    //                }
    //            } else {
    //                print("error: \(error.localizedDescription)");
    //            }
    //
    //        }
    //    }
    
    
    
    // Facebook Delegate Methods
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("User Logged In")
        if ((error) != nil) {
            // Process error
        } else if result.isCancelled {
            // Handle cancellations
        } else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email") {
                // Do work
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        self.performSegue(withIdentifier: "showLogin", sender: self)
    }
    
    func getFBUserData() {
        A0SimpleKeychain().deleteEntry(forKey: "auth0-user-jwt")
        
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, middle_name,last_name, email, birthday, gender"])
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            let json: JSON = JSON(result)
            if (error != nil) {
                // Process error
                print("Error: \(error)")
            } else {
                let userEmail = json["email"].string ?? ""
                let birthday = json["birthday"].string ?? "2015-01-01"
                let middle_name = json["middle_name"].string ?? ""
                let first_name = json["first_name"].string ?? ""
                let gender = json["gender"].string ?? ""
                let names = "\(first_name) \(middle_name)"
                print("\(birthday )")
                
                let params:[String: String] = [
                    "facebook_key" : json["id"].string!,
                    "names" : names,
                    "surnames": json["last_name"].string!,
                    "birth_date" : birthday,
                    "email": userEmail,
                    "gender": gender,
                    "main_image":"https://graph.facebook.com/\(json["id"].string!)/picture?type=large",
                    "device_os": "ios",
                    "device_token" : User.deviceToken]
                
                self.socialLogin("facebook", params: params)
            }
        })
    }
    
    @IBAction func FBlogin(_ sender: UIButton) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends", "user_birthday"], from: self, handler: { (result, error) -> Void in
            if (error != nil) {
                print("Process error")
            } else if (result?.isCancelled)! {
                print("Cancelled")
            } else if (result?.grantedPermissions.contains("email"))! {
                self.getFBUserData()
            }
        })
    }
    
    
    
    // Social login Call
    func socialLogin(_ type: String, params: [String:String]!){
        print("\(Utilities.dopURL)user/login/"+type)
        Utilities.fadeInFromBottomAnimation(self.MD_spinner, delay: 0, duration: 1, yPosition: 5)
        LoginController.loginWithSocial("\(Utilities.dopURL)user/login/" + type, params: params as [String : AnyObject],
                                        success: { (loginData) -> Void in
                                            User.loginType = type
                                            let json = loginData!
                                            
                                            let jwt = json["token"].string!
                                            
                                            User.userToken = ["Authorization": "\(jwt)"]
                                            User.userImageUrl =  params["main_image"]!
                                            User.userName =  params["names"]!
                                            User.userSurnames =  params["surnames"]!
                                            User.userEmail = params["email"]!
                                            
                                            do {
                                                let payload = try decode(jwt: (User.userToken["Authorization"])!)
                                                User.user_id = payload.body["id"]! as! Int
                                            } catch {
                                                print("Failed to decode JWT: \(error)")
                                            }
                                            
                                            DispatchQueue.main.async(execute: {
                                                
                                                if User.userName == "" || User.userEmail == ""{
                                                    let storyboard = UIStoryboard(name: "Register", bundle: nil)
                                                    let controller = storyboard.instantiateViewController(withIdentifier: "RegisterViewController")
                                                    self.present(controller, animated: true, completion: nil)
                                                } else {
                                                    if self.tutorial_checked {
                                                        self.performSegue(withIdentifier: "showDashboard", sender: self)
                                                        UIApplication.shared.registerForRemoteNotifications()
                                                    } else {
                                                        let storyboard = UIStoryboard(name: "Tutorial", bundle: nil)
                                                        let controller = storyboard.instantiateViewController(withIdentifier: "TutorialContentViewController")
                                                        self.present(controller, animated: true, completion: nil)
                                                    }
                                                }
                                                
                                                LoginController.getPrivacyInfo(success: { (response) in
                                                    let json = response!["data"][0]
                                                    
                                                    print("\(json)")
                                                    User.privacy_status = json["privacy_status"].int!
                                                    User.first_following = json["first_following"].bool!
                                                    User.first_follower = json["first_follower"].bool!
                                                    User.first_company_fav = json["first_company_fav"].bool!
                                                    User.first_using = json["first_using"].bool!
                                                    
                                                    //User.adult = json["adult"].bool!
                                                    
                                                }, failure: { (userData) in
                                                    print(userData)
                                                })
                                                User.activeSession = true
                                            })
        },
                                        failure:{ (error) -> Void in
                                            
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)  {
        
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    @IBAction func cancelForgotPassword(_ sender: Any) {
        self.login_view.alpha = 0
        self.login_view.isHidden = false
        
        Utilities.fadeOutToBottomWithCompletion(self.forgot_password_view, delay: 0, duration: 0.3, yPosition: 5) { (completion) in
            self.forgot_password_view.isHidden = true
            
            Utilities.fadeInFromBottomAnimation(self.login_view, delay: 0, duration: 0.3, yPosition: 5)
        }
        
    }
    @IBAction func forgotPassword(_ sender: Any) {
        if forgot_password_email.text != ""{
            if self.isValidEmail(testStr: forgot_password_email.text!) {
                let params:[String: String] = [ "email": forgot_password_email.text! ]
                LoginController.forgotPassword("\(Utilities.dopURL)user/forgot/password", params: params as [String : AnyObject],
                                               success: { (userData) -> Void in
                                                
                                                let json = userData!
                                                
                                                let result = json["data"].string!
                                                
                                                switch (result){
                                                    case "success":
                                                        self.cancelForgotPassword(self)
                                                        break;
                                                    case "user_not_found":
                                                        self.forgot_password_error_label.text = "El email no esta registrado, verifícalo"
                                                        break;
                                                    case "error":
                                                        self.forgot_password_error_label.text = "Ocurrió un error ☹️"
                                                        break;
                                                default:
                                                    self.forgot_password_error_label.text = "Ocurrió un error ☹️"

                                                        break;
                                                }
                                                
                                                
                },
                                               failure:{ (error) -> Void in
                                                self.forgot_password_error_label.text = "Ocurrió un error ☹️"

                                                
                })
            }else{
                forgot_password_error_label.text = "Verifica tu email"
            }
        }else{
            forgot_password_error_label.text = "Escribe tu email"
        }
        
    }
    @IBAction func showForgotPasswordView(_ sender: Any) {
        self.forgot_password_view.alpha = 0
        self.forgot_password_view.isHidden = false
        
        Utilities.fadeOutToBottomWithCompletion(self.login_view, delay: 0, duration: 0.3, yPosition: 5) { (completion) in
            self.login_view.isHidden = true
            
            Utilities.fadeInFromBottomAnimation(self.forgot_password_view, delay: 0, duration: 0.3, yPosition: 5)
        }
        
        self.forgot_password_email.text = self.login_email_text.text
    }
    
}
