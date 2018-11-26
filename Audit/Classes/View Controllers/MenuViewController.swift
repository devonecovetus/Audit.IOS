//
//  MenuViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 26/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var view_Menu: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lbl_FullName: UILabel!
    @IBOutlet weak var imgView_User: DesignableImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let strName = String(format: "%@", UserProfile.name!)
        lbl_FullName.text = strName
        let imgUrl = UserProfile.photo!
      //  imgView_User.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage.init(named: "login-logo.png"))
        imgView_User.sd_setImage(with: URL(string: imgUrl)) { (imgProcessed, imgError, imgCache, imgUrl) in
            if imgError == nil {
                self.imgView_User.image = imgProcessed
            } else {
                self.imgView_User.image = UIImage.init(named: "login-logo.png")
            }
        }
    }

    //MARK: Button Actions:
    @IBAction func btn_ViewProfile(_ sender: Any) {
    }

    @IBAction func btn_DismissView(_ sender: Any) {
        disMissView()
    }
    
    // MARK: - Supporting Functions:

    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        view_Menu.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_FullName.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        imgView_User.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            lbl_FullName.textAlignment = NSTextAlignment.right
        }
    }
    
    func disMissView() {
        var menuFrame = self.view.frame
        UIView.animate(withDuration: 0.40, delay: 0, options: [.curveEaseOut], animations: {
            menuFrame.origin.x = -menuFrame.width
            self.view.frame     = menuFrame
        }) { (compelete) in
            self.view.removeFromSuperview()
            if DeviceType.IS_IPHONE_4_OR_LESS {
                self.parent?.parent?.dismiss(animated: true, completion: nil)
                self.dismiss(animated: false, completion: nil)
            } else {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MF.setUpMenuContent().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "menu_cell", for: indexPath) as! menu_cell
        cell.setUpMenuData(dict: MF.setUpMenuContent()[indexPath.row] as! NSDictionary)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let navigationController = kAppDelegate.window?.rootViewController as! UINavigationController
        if (MF.setUpMenuContent()[indexPath.row] as! NSDictionary)["name"] as! String == MenuContent.Account {
            let vc = MainStoryBoard.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController
            navigationController.viewControllers.append(vc!)
            MF.animateViewNavigation(navigationController: navigationController)
        } else if (MF.setUpMenuContent()[indexPath.row] as! NSDictionary)["name"] as! String == MenuContent.Report {
            let vc = HomeStoryBoard.instantiateViewController(withIdentifier: "ReportListViewController") as? ReportListViewController
            navigationController.viewControllers.append(vc!)
            MF.animateViewNavigation(navigationController: navigationController)
        } else if (MF.setUpMenuContent()[indexPath.row] as! NSDictionary)["name"] as! String == MenuContent.Logout {
            logout()
        }
        
        /// This code manage the condition for logout feature, if we click logout then menu view will not dismissed
        if (MF.setUpMenuContent()[indexPath.row] as! NSDictionary)["name"] as! String !=  MenuContent.Logout {
            navigationController.isNavigationBarHidden = true
            kAppDelegate.window?.rootViewController = navigationController
            disMissView()
        }
    }
    
    func logout() {
        let alert = UIAlertController(title: "", message: ValidationMessages.strLogout, preferredStyle: UIAlertControllerStyle.alert)
        let messageFont = [NSAttributedStringKey.font: UIFont(name: "OpenSans-Regular", size: 16.0)!]
        let messageAttrString = NSMutableAttributedString(string: ValidationMessages.strLogout, attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        let okButton = UIAlertAction(title:"Yes", style: UIAlertActionStyle.default) { (UIAlertAction) in
            UIView.animate(withDuration: 0.2) { () -> Void in
                self.submitLogoutRequest() 
            }
        }
        let cancelButton = UIAlertAction(title:"No", style: UIAlertActionStyle.default) { (UIAlertAction) in
        }
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func clearUserAndAppSession() {
        disMissView()
        MF.logoutAndClearAllSessionData()
    }
    
    func submitLogoutRequest() {
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.Logout, methodType: 1, forContent: 1, OnView: self, withParameters: MF.initializeDictWithUserId()) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                self.clearUserAndAppSession()
                SHOWALERT.showAlertViewWithDuration(ValidationMessages.logoutSuccessfully)
            }
        }
    }
}
