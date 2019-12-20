//
//  UserProfileViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 25/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {
    //MARK: Variables & Outlets
    
    @IBOutlet weak var lbl_UserName: UILabel?
    @IBOutlet weak var lbl_Title: UILabel?
    @IBOutlet weak var btn_UserType: UIButton?
    @IBOutlet weak var lbl_Email: UILabel?
    @IBOutlet weak var imgView_User: UIImageView?
    @IBOutlet weak var tblView: UITableView?
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        kAppDelegate.currentViewController = self

        lbl_UserName?.text = UserProfile.name
        lbl_Email?.text =  UserProfile.email
        btn_UserType?.setTitle(UserProfile.userRole!, for: UIControlState.normal)
        let imgUrl = UserProfile.photo!
        imgView_User?.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage.init(named: "img_user"))
    }
    
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        imgView_User?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_UserName?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Email?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_UserType?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            lbl_UserName?.textAlignment = NSTextAlignment.right
            lbl_Email?.textAlignment = NSTextAlignment.right
        }
    }
  
    //MARK: Button Actions:
    @IBAction func btn_Back(_ sender: Any) {
        view.removeAllSubViews()
        self.navigationController?.popViewController(animated: true)
    }
}

