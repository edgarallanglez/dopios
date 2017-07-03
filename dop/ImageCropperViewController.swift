//
//  ImageCropperViewController.swift
//  ImageCropper
//
//  Created by Aatish Rajkarnikar on 10/4/16.
//  Copyright © 2016 iOSHub. All rights reserved.
//

import UIKit
import MobileCoreServices

class ImageCropperViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imgview: UIImageView!
    var imagepicked:UIImage!
    var  minZoomScale:CGFloat!
    let picker = UIImagePickerController()
    @IBOutlet weak var scrollViewSquare: UIScrollView!
    
    var first_time: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        scrollViewSquare.delegate = self
        picker.mediaTypes = [kUTTypeImage as String]
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        print("ENTRO SELECCION")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagepicked = image
            ImageViewInit()
        } else{
            print("Something went wrong")
        }
        
        
        dismiss(animated: false, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        if first_time == false{
            first_time = true
            self.Pick(sender: self)
        }
    }
    
    @IBAction func Pick(sender: AnyObject) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    func ImageViewInit(){
        imgview = UIImageView()
        imgview.frame =  CGRect(x: 0, y: 0, width: imagepicked.size.width, height: imagepicked.size.height)
        
        imgview.image = imagepicked
        imgview.contentMode = .scaleAspectFit
        imgview.backgroundColor = UIColor.lightGray
        scrollViewSquare.maximumZoomScale=4;
        scrollViewSquare.minimumZoomScale=0.02;
        scrollViewSquare.bounces=true;
        scrollViewSquare.bouncesZoom=true;
        scrollViewSquare.contentMode = .scaleAspectFit
        scrollViewSquare.contentSize = imagepicked.size
        scrollViewSquare.autoresizingMask = UIViewAutoresizing.flexibleWidth
        scrollViewSquare.addSubview(imgview)
        setZoomScale()
    }
    //fit imageview in the scrollview
    func setZoomScale(){
        let imageViewSize = imgview.bounds.size
        let scrollViewSize = scrollViewSquare.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        minZoomScale = max(widthScale, heightScale)
        scrollViewSquare.minimumZoomScale = minZoomScale
        scrollViewSquare.zoomScale = minZoomScale
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgview
    }
    
    //mapping the image from the scrollview to imageview to get the desired ratio
    @IBAction func Save(sender: AnyObject) {
        let offset = scrollViewSquare.contentOffset
        let visibleRect: CGRect = CGRect(x: offset.x, y: offset.y, width: offset.x+scrollViewSquare.frame.width, height: offset.y+scrollViewSquare.frame.height)
        let visibleImgRect: CGRect = CGRect(x: offset.x/scrollViewSquare.zoomScale, y: offset.y/scrollViewSquare.zoomScale, width: (offset.x+scrollViewSquare.frame.width)/scrollViewSquare.zoomScale, height: (offset.y+scrollViewSquare.frame.height)/scrollViewSquare.zoomScale)
        
        let vv = UIView(frame: visibleImgRect)
        vv.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
        self.view.addSubview(vv)
        if imagepicked == nil{
            self.dismiss(animated: true, completion: nil)
        }else{
            cropAndSave()
        }
    }
    
    
    
    
    func cropAndSave() {
        UIGraphicsBeginImageContextWithOptions(scrollViewSquare.bounds.size, true, UIScreen.main.scale)
        let offset = scrollViewSquare.contentOffset
        
        UIGraphicsGetCurrentContext()!.translateBy(x: -offset.x, y: -offset.y)
        scrollViewSquare.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        let ready_image = UIImageJPEGRepresentation(image!, 0.2)
        
        RegisterViewController.user_image = image
        self.dismiss(animated: true, completion: nil)
        //UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        
    }
    
    
}
