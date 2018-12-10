//
//  EditProfileViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 25/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import iOSPhotoEditor

class EditProfileViewController: UIViewController {
    //MARK: Variables & OPutlets:
    var flagIsUploadPic = false
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var imgView_User: UIImageView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var tf_FirstName: DesignableUITextField!
    @IBOutlet weak var tf_LastName: DesignableUITextField!
    @IBOutlet weak var tf_ContactNumber: DesignableUITextField!
    @IBOutlet weak var tf_Email: DesignableUITextField!
    @IBOutlet weak var btn_Update: UIButton!
    @IBOutlet weak var btn_UploadPhoto: UIButton!
    
    //MARK: View Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if checkValidations().count > 0 {
            self.showAlertViewWithMessage(checkValidations(), vc: self)
        } else {
            submitUpdateProfileRequest()
        }
    }
    
    @IBAction func btn_UploadPhoto(_ sender: Any) {
        MF.openActionSheet(with: imagePicker, and: self, targetFrame: btn_UploadPhoto.frame)
    }
    
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Supporting Function:
    
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_FirstName.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_LastName.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_Email.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        tf_ContactNumber.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Update.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            tf_FirstName.textAlignment = NSTextAlignment.right
            tf_ContactNumber.textAlignment = NSTextAlignment.right
            tf_LastName.textAlignment = NSTextAlignment.right
            tf_Email.textAlignment = NSTextAlignment.right
        }
        
        tf_FirstName.placeholder = NSLocalizedString("FirstName", comment: "")
        tf_LastName.placeholder =  NSLocalizedString("LastName", comment: "")
        tf_Email.placeholder =  NSLocalizedString("Email", comment: "")
        tf_ContactNumber.placeholder =  NSLocalizedString("ContactNumber", comment: "")
        btn_Update.setTitle(NSLocalizedString("Update", comment: ""), for: UIControlState.normal)
        lbl_Title.text = NSLocalizedString("TitleEdit", comment: "")
    }
    
    func setUserProfileData() {
        tf_FirstName.text = UserProfile.firstName
        tf_LastName.text = UserProfile.lastName
        tf_Email.text = UserProfile.email
        tf_ContactNumber.text = UserProfile.phone
        let imgUrl = UserProfile.photo!
        imgView_User.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage.init(named: "login-logo.png"))
    }
    
    func checkValidations() -> String {
        var strMsg = String()
        
        if tf_FirstName.text?.count == 0 {
            strMsg = ValidationMessages.strEnterFirstName
        } else if tf_LastName.text?.count == 0 {
            strMsg = ValidationMessages.strEnterLastName
        } else if tf_ContactNumber.text?.count == 0 {
            strMsg = ValidationMessages.strEnterMobile
        } else if (tf_ContactNumber.text?.count)! < ValidationConstants.MobileNumberLength {
            strMsg = ValidationMessages.strMobileLength
        }
        return strMsg
    }
    
    func submitUpdateProfileRequest() {
        
    //    let imgData = imgView_User.image?.imageQuality(.medium)?.base64EncodedData()
        let imgBase64String = imgView_User.image?.imageQuality(.low)?.base64EncodedString(options: .lineLength64Characters)
        
     //   let imageData = UIImageJPEGRepresentation(imgView_User.image!, 0.1)! as NSData
        // let imgBase64String = imageData.base64EncodedString(options: .lineLength64Characters)
        
        let dictP = MF.initializeDictWithUserId()
        
        dictP.setValue(tf_FirstName.text, forKey: "firstname")
        dictP.setValue(tf_LastName.text, forKey: "lastname")
        dictP.setValue(tf_ContactNumber.text, forKey: "phone")
        dictP.setValue(imgBase64String, forKey: "photo")

        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.UpdateUser, methodType: 1, forContent: 1, OnView: self, withParameters: dictP) { (dictJson) in
            if dictJson["status"] as? Int == 1 {
                SHOWALERT.showAlertViewWithDuration(ValidationMessages.profileUpdatedSuccessfully)
                UserProfile.initWith(dict: (dictJson["response"] as! NSDictionary).mutableCopy() as! NSDictionary)
                let archiveUserData = NSKeyedArchiver.archivedData(withRootObject: (dictJson["response"] as! NSDictionary).mutableCopy())
                Preferences.set(archiveUserData , forKey: "UserData")
               self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.isFirstResponder {
            if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
                return false
            }
        }
        
        if textField == tf_ContactNumber {
           
            if MF.checkNumberInput(strInput: string) {
                let currentCharacterCount = tf_ContactNumber.text?.count ?? 0
                let newLength = currentCharacterCount + string.count - range.length
                if (range.length + range.location > currentCharacterCount){
                    return false
                }
                return newLength <= ValidationConstants.MaxMobileNumberLength
            } else {
                return false
            }
        }
        return true
    }
}

extension EditProfileViewController: PhotoEditorDelegate {
    
    func doneEditing(image: UIImage) {
        imgView_User.image = image
    }
    
    func canceledEditing() {
        print("Canceled")
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            self.flagIsUploadPic = true
//            self.imgView_User.image = pickedImage
//        }
//        dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        self.flagIsUploadPic = false
//        dismiss(animated: true, completion: nil)
//    }
    
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        //picker.dismiss(animated: true, completion: nil)
        picker.dismiss(animated: false, completion: nil)
        
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        
        photoEditor.photoEditorDelegate = self
        self.flagIsUploadPic = true
        photoEditor.image = image
        imgView_User.image = image
        //Colors for drawing and Text, If not set default values will be used
        //        photoEditor.colors = [.red,.blue,.green]
        
        //Stickers that the user will choose from to add on the image
        //        for i in 0...10 {
        //            photoEditor.stickers.append(UIImage(named: i.description )!)
        //        }
        
        //To hide controls - array of enum control
        //  photoEditor.hiddenControls = [.crop, .draw, .share]
        photoEditor.hiddenControls = [.share, .save, .sticker]
        
        present(photoEditor, animated: false, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.flagIsUploadPic = false
        dismiss(animated: true, completion: nil)
    }
}
