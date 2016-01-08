//
//  SimpleModalViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 24/12/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit


class SimpleModalViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var close_button: UIButton!
    @IBOutlet var title_label: UILabel!
    @IBOutlet var twitter_button: UIButton!
    @IBOutlet var instagram_button: UIButton!
    @IBOutlet var facebook_button: UIButton!
    @IBOutlet var share_text: UITextView!
    @IBOutlet var modal_text: UILabel!
    @IBOutlet var limit_label: UILabel!
    @IBOutlet var action_button: ModalButton!
    @IBOutlet var cancel_button: ModalButton!
    
    var normalAttrdict: [String:AnyObject]?
    var highlightAttrdict: [String:AnyObject]?
    var currentAttribute : [String:AnyObject]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if((cancel_button) != nil){
            cancel_button.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchDown)
            
            cancel_button.addTarget(self, action: "buttonReleased:", forControlEvents: UIControlEvents.TouchDragOutside)
            cancel_button.addTarget(self, action: "cancelTouched:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        action_button.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchDown)
        action_button.addTarget(self, action: "buttonReleased:", forControlEvents: UIControlEvents.TouchDragOutside)
        action_button.addTarget(self, action: "actionTouched:", forControlEvents: UIControlEvents.TouchUpInside)
        
        if((share_text) != nil){
            share_text.delegate = self
        }
        
        normalAttrdict = [NSFontAttributeName:UIFont(name: "Montserrat-Light",size: 16.0)!,NSForegroundColorAttributeName: UIColor.lightGrayColor()]
        highlightAttrdict = [NSFontAttributeName:UIFont(name: "Montserrat-Light",size: 16.0)!, NSForegroundColorAttributeName: Utilities.dopColor]
        
        currentAttribute = normalAttrdict
        
        
    }
    func startListening(){
       
    }
    func buttonPressed(sender: ModalButton){
        sender.selected = true
    }
    func buttonReleased(sender: ModalButton){
        sender.selected = false
    }
    func cancelTouched(sender: ModalButton){
        sender.selected = false
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
    }
    func actionTouched(sender: ModalButton){
        sender.selected = false
    }
  
    override func viewDidAppear(animated: Bool) {
        action_button.layoutIfNeeded()
        if(cancel_button != nil){
            cancel_button.layoutIfNeeded()
        }
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 140
        let currentString: String = textView.text!
        let newString: String = (currentString as NSString).stringByReplacingCharactersInRange(range, withString: text)

        if(newString.characters.count <= maxLength) {
            self.limit_label.text = "\(newString.characters.count)/\(maxLength)"
        }
        
        if(newString.characters.count >= 2){
            if(text == "#" && newString[newString.characters.endIndex.predecessor().predecessor()] == " "){
                currentAttribute = highlightAttrdict!
            }
            if(text == " "){
                currentAttribute = normalAttrdict!
            }
            
        }
        
        
        textView.typingAttributes = currentAttribute!
        
        
        
        
        return (newString.characters.count) <= maxLength
    }
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
