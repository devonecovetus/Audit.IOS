//
//  NotificationListViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 31/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class NotificationListViewController: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lbl_Title: UILabel!
    
    var pageno = 1
    var lodingApi: Bool!
    
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    var notificationList = [NotificationModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        kAppDelegate.currentViewController = self
        self.notificationList.removeAll()
        self.tblView.reloadData()
        getNotificationList()
    }

    // MARK: - Supporting Methods
    func setUpLanguageSetting() {
    }
    
    func getNotificationList() {
        /// API code here
        let dictP = NSMutableDictionary()
        dictP.setValue(UserProfile.id, forKey: "id")
        dictP.setValue(UserProfile.authToken, forKey: "auth_token")
        dictP.setValue(String(pageno), forKey: "pagenum")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.GetNotification, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
                let dictresponse = dictJson["response"] as! NSDictionary
                for i in 0..<(dictresponse["notification"] as! NSArray).count {
                    let obRequest = NotificationModel()
                    obRequest.initWith(dict: (dictresponse["notification"] as! NSArray)[i] as! NSDictionary)
                    self.notificationList.append(obRequest)
                }
                self.tblView.reloadData()
            }
        }
    }
 
}

extension NotificationListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        if notificationList.count > 0 {
            cell.setNotificationData(obNot: notificationList[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if notificationList[indexPath.row].type == NotificationType.Audit {
            let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "AuditOverViewController") as! AuditOverViewController
            vc.str_notify_id = notificationList[indexPath.row].notify_id!
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let height:Int = Int(tblView.contentOffset.y + tblView.frame.size.height)
        let TableHeight:Int =  Int(tblView.contentSize.height)
        
        if (height >= TableHeight)
        {
            if lodingApi == true
            {
                lodingApi = false
                self.pageno = self.pageno + 1
                self.getNotificationList()
            }
        } else {
            return;
        }
    }
}
