//
//  UserProfileViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 25/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {

    @IBOutlet weak var lbl_UserName: UILabel!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var btn_UserType: UIButton!
    @IBOutlet weak var lbl_Email: UILabel!
    @IBOutlet weak var imgView_User: UIImageView!
    
    @IBOutlet weak var tblView: UITableView!
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print(UserProfile)
        kAppDelegate.currentViewController = self

        lbl_UserName.text = UserProfile.name
        lbl_Email.text =  UserProfile.email
        btn_UserType.setTitle(UserProfile.userRole!, for: UIControlState.normal)
        let imgUrl = UserProfile.photo!
        imgView_User.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage.init(named: "login-logo.png"))
    }
    
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_UserName.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Email.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_UserType.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.text = NSLocalizedString("TitleProfile", comment: "")
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            lbl_UserName.textAlignment = NSTextAlignment.right
            lbl_Email.textAlignment = NSTextAlignment.right
        }
    }
  
}

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
                    //popOver.sourceRect =
                    //popOver.barButtonItem
                }
            })
        } else if (MF.setUpProfileContent()[indexPath.row] as! NSDictionary)["name"] as! String == ProfileContent.HowUse {
            self.showAlertViewWithMessage("The work is in progress", vc: self)
        }
    }
    
}
