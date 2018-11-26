//
//  WebContentViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 25/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class WebContentViewController: UIViewController {
    //MARK: Outlets & Variables:
    var strLinkType: String?
    var strTitle: String?
    @IBOutlet weak var webView_Content: UIWebView!
    @IBOutlet weak var lbl_Title: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lbl_Title.text = strTitle
        if (strLinkType?.count)! > 0 {
            // webView_Content.loadHTMLString(strLinkType!, baseURL: nil)
            webView_Content.loadRequest(URLRequest(url: URL(string: strLinkType!)!))
        }
    }
    
    //MARK: Button Actions:
    
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        webView_Content.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
    
}

extension WebContentViewController: UIWebViewDelegate {
    //MARK: WebView Delegate Methods:
    
    func webViewDidStartLoad(_ webView: UIWebView){
        SVProgressHUD.show(withStatus: NSLocalizedString("loading...", comment: ""))
        print("webViewDidStartLoad")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
        print("webViewDidFinishLoad")
    }
    
    func webView(_webView: UIWebView, didFailLoadWithError error: NSError) {
        SVProgressHUD.dismiss()
        print("webview did fail load with error: \(error)")
    }
}
