//
//  UserProfile+TableView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 20/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MF.setUpProfileContent().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileViewCell", for: indexPath) as! ProfileViewCell
        cell.cellIndex = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (MF.setUpProfileContent()[indexPath.row] as! NSDictionary)["name"] as! String == ProfileContent.UpdateDetail {
            let vc = MainStoryBoard.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if (MF.setUpProfileContent()[indexPath.row] as! NSDictionary)["name"] as! String == ProfileContent.ChatAdmin {
            let vc = MainStoryBoard.instantiateViewController(withIdentifier: "ChatWithAdminViewController") as? ChatWithAdminViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if (MF.setUpProfileContent()[indexPath.row] as! NSDictionary)["name"] as! String == ProfileContent.ShareApp {
            let strMsg = String(format: "Let me recommend you this application for managing your audit task. You can download the Access4Mii app for: \nAndroid version:\n%@\n\n and For: iOS version\n%@", AppLinks.GoogleAppStoreLink, AppLinks.AppleAppStoreLink)
            
            let objectsToShare: Array = [strMsg] as [Any]
            let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            DispatchQueue.main.async(execute: {
                self.present(activityViewController, animated: true, completion: nil)
                if let popOver = activityViewController.popoverPresentationController {
                    popOver.sourceView = self.tblView
                }
            })
        } else if (MF.setUpProfileContent()[indexPath.row] as! NSDictionary)["name"] as! String == ProfileContent.HowUse {
            
        }
    }
}
