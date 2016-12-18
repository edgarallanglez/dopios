//
//  RegisterViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 12/12/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var birthday_top: NSLayoutConstraint!
    
    @IBOutlet var welcome_label: UILabel!
    
    @IBOutlet var image_loader: UIActivityIndicatorView!
    @IBOutlet var email_text_top: NSLayoutConstraint!
    @IBOutlet var surnames_text_top: NSLayoutConstraint!
    @IBOutlet var names_text_top: NSLayoutConstraint!
    @IBOutlet var loader: MMMaterialDesignSpinner!
    @IBOutlet var gender_picker: UISegmentedControl!
    @IBOutlet var error_label: UILabel!
    @IBOutlet var accept_button: UIButton!
    @IBOutlet var birthday_picker: UIDatePicker!
    @IBOutlet var birthday_text: LoginTextView!
    @IBOutlet var surnames_text: LoginTextView!
    @IBOutlet var names_text: LoginTextView!
    @IBOutlet var pick_photo_button: UIButton!
    
    @IBOutlet var email_text: LoginTextView!
    
    static var user_image: UIImage!
    
    var validation:[String:Bool] = [:]
    
    var names_needed: Bool = true
    var surnames_needed: Bool = true
    var email_needed: Bool = true
    var birthday_needed: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .default
        
        self.pick_photo_button.layer.masksToBounds = true
        
        self.pick_photo_button.layer.cornerRadius = 60
        
        self.birthday_picker.alpha = 0
        self.birthday_picker.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)
        
        
        self.names_text.delegate = self
        self.surnames_text.delegate = self
        self.email_text.delegate = self
        self.birthday_text.delegate = self
        
        
        error_label.text = ""
        
        loader.startAnimating()
        loader.lineWidth = 3
        
        
        
        
        if User.userName != "" {
            self.names_text_top.isActive = false
            self.names_text.isHidden = true
            
            self.surnames_text_top.isActive = false
            self.surnames_text.isHidden = true
            
            names_needed = false
            surnames_needed = false
        }
        if User.userEmail != "" {
            self.email_text.isHidden = true
            self.birthday_top.priority = 100
            
            email_needed = false
        }
        
        
        validation["names"] = names_needed
        validation["surnames"] = surnames_needed
        validation["email"] = email_needed
        validation["birthday"] = birthday_needed
        
        image_loader.isHidden = true
        
        if User.userImageUrl != "" {
            self.pick_photo_button.setImage(nil, for: .normal)
            
            self.image_loader.isHidden = false
            self.image_loader.startAnimating()
            Alamofire.request(User.userImageUrl).responseImage { response in
                if let image = response.result.value{
                    self.image_loader.isHidden = true
                    self.pick_photo_button.setBackgroundImage(image, for: .normal)
                    //self.pick_photo_button.setImage(image, for: .normal)
                }
            }
        }
        
        loader.alpha = 0
        
        
        Utilities.applyPlainShadow(self.accept_button)
    }
    override func viewWillAppear(_ animated: Bool) {
        if RegisterViewController.user_image != nil{
            self.image_loader.isHidden = true
            pick_photo_button.setImage(RegisterViewController.user_image, for: .normal)
        }
    }
    func handleDatePicker() {
        self.birthday_text.text = self.dateToFriendlyString(date: self.birthday_picker.date)
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == birthday_text{
            birthday_text.resignFirstResponder()
            surnames_text.resignFirstResponder()
            names_text.resignFirstResponder()
            email_text.resignFirstResponder()
            Utilities.fadeInViewAnimation(birthday_picker, delay: 0, duration: 0.4)
            textField.text = self.dateToFriendlyString(date: birthday_picker.date)
            self.error_label.text = ""
            
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == birthday_text{
            
        }
        
        
        
        
    }
    
    func dateToFriendlyString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd / MMMM / yyyy"
        return dateFormatter.string(from: date)
    }
    
    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("SELECTED")
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.names_text || textField == self.surnames_text{
            let uppercase_text = textField.text?.localizedCapitalized
            textField.text = uppercase_text
            
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func tapScreen(_ sender: Any) {
        self.names_text.resignFirstResponder()
        self.surnames_text.resignFirstResponder()
        self.email_text.resignFirstResponder()
        self.birthday_text.resignFirstResponder()
        Utilities.fadeOutViewAnimation(birthday_picker, delay: 0, duration: 0.4)
    }
    @IBAction func accept(_ sender: Any) {
        error_label.text = ""
        
        if validateData() {
            Utilities.fadeInViewAnimation(loader, delay: 0, duration: 0.3)
            Utilities.fadeOutToBottomAnimation(accept_button, delay: 0, duration: 0.3, yPosition: 20)
            
            var image_to_send: Data?
            
            if RegisterViewController.user_image != nil {
                image_to_send = UIImageJPEGRepresentation(RegisterViewController.user_image, 0.2)
            }
            
            let names = names_text.text!
            let surnames = surnames_text.text!
            let email = email_text.text!
            let birthday = self.dateToString(date: self.birthday_picker.date)
            
            var gender: String = "male"
            if gender_picker.selectedSegmentIndex == 1{
                gender = "female"
            }
            
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    if image_to_send != nil{
                        multipartFormData.append(image_to_send!,
                                                 withName: "photo",
                                                 fileName: "photo",
                                                 mimeType: "image/jpeg")
                    }
                    if self.names_needed {
                        multipartFormData.append(names.data(using: String.Encoding.utf8)!, withName: "names")
                        multipartFormData.append(surnames.data(using: String.Encoding.utf8)!, withName: "surnames")
                    }
                    if self.birthday_needed {
                        multipartFormData.append(birthday.data(using: String.Encoding.utf8)!, withName: "birthday")
                    }
                    if self.email_needed {
                        multipartFormData.append(email.data(using: String.Encoding.utf8)!, withName: "email")
                    }
                    multipartFormData.append(gender.data(using: String.Encoding.utf8)!, withName: "gender")
                    
            },
                to: "\(Utilities.dopURL)user/profile/photo",
                headers: User.userToken,
                encodingCompletion: { encodingResult in
                    
                    switch encodingResult {
                        
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            print(response)
                            let json:JSON = JSON(response.result.value)
                            print(json)
                            Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.4)
                            
                            if json["message"].string! == "success" {
                
                                Utilities.fadeOutToBottomAnimation(self.welcome_label, delay: 0, duration: 0.4, yPosition: 10)
                                Utilities.fadeOutToBottomAnimation(self.pick_photo_button, delay: 0, duration: 0.4, yPosition: 10)
                                Utilities.fadeOutToBottomAnimation(self.gender_picker, delay: 0, duration: 0.4, yPosition: 10)
                                Utilities.fadeOutToBottomAnimation(self.names_text, delay: 0, duration: 0.4, yPosition: 10)
                                Utilities.fadeOutToBottomAnimation(self.surnames_text, delay: 0, duration: 0.4, yPosition: 10)
                                Utilities.fadeOutToBottomAnimation(self.email_text, delay: 0, duration: 0.3, yPosition: 10)
                                Utilities.fadeOutToBottomAnimation(self.birthday_text, delay: 0, duration: 0.4, yPosition: 10)
                                Utilities.fadeOutToBottomAnimation(self.birthday_picker, delay: 0, duration: 0.4, yPosition: 10)
                                Utilities.fadeOutToBottomWithCompletion(self.birthday_picker, delay: 0, duration: 0.4, yPosition: 10, completion: { (value) -> Void in
                                    let storyboard = UIStoryboard(name: "Tutorial", bundle: nil)
                                    let controller = storyboard.instantiateViewController(withIdentifier: "TutorialContentViewController")
                                    self.present(controller, animated: true, completion: {
                                        self.parent?.dismiss(animated: true, completion: nil)
                                    })
                                })
                                
                            }else{
                                self.error_label.text = "El email ya esta registrado 😱"
                                Utilities.fadeInFromBottomAnimation(self.accept_button, delay: 0, duration: 0.3, yPosition: 20)
                            }
                            //self.image_preview.isHidden = true
                        }
                        
                    case .failure( _):
                        Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)
                        Utilities.fadeInFromBottomAnimation(self.accept_button, delay: 0, duration: 0.3, yPosition: 20)
                        self.error_label.text = "Problemas de conexión ☹️"
                    }
            }
            )
        }
    }
    
    func validateData() -> Bool{
        var success: Bool = true
        for field in validation {
            if field.value == true {
                switch field.key {
                case "names":
                    if self.names_text.text == "" { success=false; error_label.text = "Asegúrate de llenar todos los campos"; break }
                case "surnames":
                    if self.surnames_text.text == "" { success=false; error_label.text = "Asegúrate de llenar todos los campos";break}
                case "email":
                    if self.email_text.text == "" { success=false; error_label.text = "Asegúrate de llenar todos los campos";break }
                    if !self.isValidEmail(testStr: email_text.text!) { success=false; error_label.text = "Verifica tu correo"; break;  }
                case "birthday":
                    if self.birthday_text.text == "" { success=false; error_label.text = "Asegúrate de llenar todos los campos"; break }
                default:
                    success = false
                    break
                }
            }
        }
        return success
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}
