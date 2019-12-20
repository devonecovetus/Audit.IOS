//
//  EditProfileViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 25/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
    //MARK: Variables & Outlets:
    var delegate:EditProfileDelegate?
    var flagIsUploadPic = false
    var imagePicker:UIImagePickerController? = UIImagePickerController()
    @IBOutlet weak var imgView_User: UIImageView?
    @IBOutlet weak var lbl_Title: UILabel?
    @IBOutlet weak var tf_FirstName: DesignableUITextField?
    @IBOutlet weak var tf_LastName: DesignableUITextField?
    @IBOutlet weak var tf_ContactNumber: DesignableUITextField?
    @IBOutlet weak var tf_Email: DesignableUITextField?
    @IBOutlet weak var btn_Update: UIButton?
    @IBOutlet weak var btn_UploadPhoto: UIButton?
    
    //MARK: View Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        IQKeyboardManager.sharedManager().enable = true
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        kAppDelegate.currentViewController = self
        if !flagIsUploadPic {
            setUserProfileData()
        }
    }
    
    //MARK:Button Actions:
    
    @IBAction func btn_Update(_ sender: Any) {
        if (delegate?.checkValidations().count)! > 0 {
            self.showAlertViewWithMessage((delegate?.checkValidations())!, vc: self)
        } else {
            delegate?.submitUpdateProfileRequest()
        }
    }
    
    @IBAction func btn_UploadPhoto(_ sender: Any) {
        MF.openActionSheet(with: imagePicker!, and: self, targetFrame: (btn_UploadPhoto?.frame)!)
    }
    
    @IBAction func btn_Back(_ sender: Any) {
        delegate = nil
        view.removeAllSubViews()
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Supporting Function:
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        imgView_User?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_FirstName?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_LastName?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_Email?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_ContactNumber?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Update?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            tf_FirstName?.textAlignment = NSTextAlignment.right
            tf_ContactNumber?.textAlignment = NSTextAlignment.right
            tf_LastName?.textAlignment = NSTextAlignment.right
            tf_Email?.textAlignment = NSTextAlignment.right
        }
        
    }
    
    func setUserProfileData() {
        tf_FirstName?.text = UserProfile.firstName
        tf_LastName?.text = UserProfile.lastName
        tf_Email?.text = UserProfile.email
        tf_ContactNumber?.text = UserProfile.phone
        let imgUrl = UserProfile.photo!
        imgView_User?.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage.init(named: "img_user"))
    }
}
