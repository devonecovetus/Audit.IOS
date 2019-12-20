//
//  MenuViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 26/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    var delegate:MenuViewDelegate?
    @IBOutlet weak var view_Menu: UIView?
    @IBOutlet weak var tblView: UITableView?
    @IBOutlet weak var lbl_FullName: UILabel?
    @IBOutlet weak var imgView_User: DesignableImage?
    @IBOutlet weak var xAxis_constraint: NSLayoutConstraint?
    
    //MARK: View Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        kAppDelegate.currentViewController = self

        setUserNameAndImage()
    }

    override func viewWillDisappear(_ animated: Bool) {
        releasedUnusedMemory()
    }
    
    func setUserNameAndImage() {
        let strName = String(format: "%@", UserProfile.name!)
        lbl_FullName?.text = strName
        let imgUrl = UserProfile.photo!
        imgView_User?.sd_setImage(with: URL(string: imgUrl)) { (imgProcessed, imgError, imgCache, imgUrl) in
            if imgError == nil {
                self.imgView_User?.image = imgProcessed
            } else {
                self.imgView_User?.image = UIImage.init(named: "img_user")
            }
        }
    }
    
    //MARK: Button Actions:
    @IBAction func btn_ViewProfile(_ sender: Any) {
    }

    @IBAction func btn_DismissView(_ sender: Any) {
        delegate?.disMissView()
    }
    
    // MARK: - Supporting Functions:
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        view_Menu?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_FullName?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        imgView_User?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            lbl_FullName?.textAlignment = NSTextAlignment.right
        }
    }
    
    func logout() {
        MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Action, title: NSLocalizedString("AppLogout", comment: "") , message: ValidationMessages.strLogout)
    }
    
    func clearUserAndAppSession() {
        delegate?.disMissView()
        MF.logoutAndClearAllSessionData()
    }
    
    func releasedUnusedMemory() {
        delegate = nil
        tblView?.delegate = nil
        tblView?.dataSource = nil
        view.removeAllSubViews()
        navigationController?.viewControllers.removeAll()
    }
}


extension MenuViewController: PopUpDelegate {
    func actionOnYes() {
        delegate?.submitLogoutRequest()
    }
    
    func actionOnNo() {
    }
}
