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
    @IBOutlet weak var webView_Content: UIWebView?
    @IBOutlet weak var lbl_Title: UILabel?

    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        kAppDelegate.currentViewController = self
        lbl_Title?.text = strTitle
        if (strLinkType?.count)! > 0 {
            // webView_Content.loadHTMLString(strLinkType!, baseURL: nil)
            //print("strLinkType - \(strLinkType)")
            webView_Content?.loadRequest(URLRequest(url: URL(string: strLinkType!)!))
        }
    }
    
    //MARK: Button Actions:
    @IBAction func btn_Back(_ sender: Any) {
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        
        webView_Content?.delegate = nil
        webView_Content = nil
        view.removeAllSubViews()
        self.navigationController?.popViewController(animated: true)
    }
    
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        webView_Content?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
    
}


