//
//  Home_VC.swift
//  Audit
//
//  Created by Mac on 10/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class Home_VC: UIViewController {
  
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_notifycount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
        lbl_notifycount.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        kAppDelegate.currentViewController = self
        lbl_notifycount.isHidden = true
        getNotificationCount()
    }
        
    func getNotificationCount() {
        /// API code here
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.NotifyCount, methodType: 1, forContent: 1, OnView: self, withParameters: MF.initializeDictWithUserId(), IsShowLoader: false) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
                if (dictJson["response"] as! NSDictionary)["count"] as? Int != 0 {
                    self.executeUIProcess({
                        self.lbl_notifycount.isHidden = false
                        self.lbl_notifycount.text =  String((dictJson["response"] as! NSDictionary)["count"] as! Int)
                    })
                }
            }
        }
    }
   
    @IBAction func action_open(_ sender: Any) {
        MF.OpenMenuView(viewController: self)
    }
    
    @IBAction func btn_NotificationList(_ sender: Any) {
        let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "NotificationListViewController") as! NotificationListViewController
        self.navigationController?.pushViewController(vc, animated: true)
       // NotificationBellCount()
    }
    
    func NotificationBellCount() {
        /// API code here
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.NotifyBellCount, methodType: 1, forContent: 1, OnView: self, withParameters: MF.initializeDictWithUserId(), IsShowLoader: false) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
                self.lbl_notifycount.isHidden = true
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
    }
    
    func setUpLanguageSetting() {
        view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_notifycount.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
    
}
