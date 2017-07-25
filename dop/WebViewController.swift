//
//  WebViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 7/18/17.
//  Copyright © 2017 Edgar Allan Glez. All rights reserved.
//

import Foundation

class WebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var web_view: UIWebView!
    @IBOutlet weak var web_view_loader: MMMaterialDesignSpinner!
    @IBOutlet weak var web_title: UILabel!
    @IBOutlet weak var web_view_tools: UIView!
    
    var url: String!
    var webview_title: String?
    var url_request: URLRequest!
    
    override func viewDidLoad() {
        web_view_loader.lineWidth = 3
        web_view_loader.startAnimating()
        web_title.text = self.webview_title!
        
        
        let url = URL(string: self.url)!
        url_request = URLRequest(url: url)
        web_view.loadRequest(url_request)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        web_view_loader.stopAnimating()
        if web_view.canGoBack {
            Utilities.fadeInViewAnimation(web_view_tools, delay: 0, duration: 0.5)
        } else {
            Utilities.fadeOutViewAnimation(web_view_tools, delay: 0, duration: 0.5)
        }
    }
    
    @IBAction func closeView(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.subtype = kCATransitionFromBottom
        view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.web_view.goBack()
    }
    
}
