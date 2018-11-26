//
//  Supporting Functions.swift
//  Productivity Planner
//
//  Created by Gourav Joshi on 29/05/18.
//  Copyright © 2018 Gourav Joshi. All rights reserved.
//

import UIKit
import SystemConfiguration

class SupportingFunctions: NSObject {
    
    //MARK: Decode Data String
    func decodeDataIntoString(strMsg: String) -> String {
        
        let strDecodeMsg = strMsg
        var strString = ""
        if( strDecodeMsg.count > 0) {
            let jsonString = strDecodeMsg.cString(using: String.Encoding.utf8)
            let jsonData = NSData(bytes: jsonString!, length: jsonString!.count)
            let msgData: Data = jsonData as Data
            if(msgData.count > 0){
                if(String(data: msgData , encoding: String.Encoding.nonLossyASCII) != nil) {
                    strString = String(data: msgData , encoding: String.Encoding.nonLossyASCII)!
                } else {
                    strString = strDecodeMsg
                }
            } else {
                strString = strDecodeMsg
            }
        }
        return strString
    }
    
    func decodeUnicodeStringIntoSimpleString(strMsg: String) -> String {
        
        if strMsg.count > 0 {
            var simpleString = ""
            let datadec  = strMsg.data(using: String.Encoding.utf8)
            if datadec == nil {
                simpleString = self.decodeDataIntoString(strMsg: strMsg)
            } else {
                simpleString = String(data: datadec!, encoding: String.Encoding.nonLossyASCII)!
            }
            return simpleString
        }
        return ""
    }
    
    func animateViewNavigation(navigationController: UINavigationController) {
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.35
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        if kAppDelegate.intViewFlipStatus == 1 {
            transition.subtype = kCATransitionFromRight
        } else {
            transition.subtype = kCATransitionFromLeft
        }
        navigationController.view.layer.add(transition, forKey: kCATransition)
    }
    
    //MARK: Check Validation Inputs
    func checkNumberInput(strInput: String) ->Bool {
        let allowedCharacters = "1234567890"
        let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
        let typedCharacterSet = CharacterSet(charactersIn: strInput)
        let isNumber = allowedCharacterSet.isSuperset(of: typedCharacterSet)
        return isNumber
    }
    
    func checkAlphabetInput(strInput: String) -> Bool {
        let allowedCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
        let typedCharacterSet = CharacterSet(charactersIn: strInput)
        let isAlphabet = allowedCharacterSet.isSuperset(of: typedCharacterSet)
        return isAlphabet
    }
    
    //MARK: Image Picker
    func openActionSheet(with imagePicker: UIImagePickerController, and delegate: UIViewController, targetFrame: CGRect)  {
        let optionMenu = UIAlertController(title: nil, message: "Choose Photo", preferredStyle: .actionSheet)
        let openCapturePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            imagePicker.delegate = delegate as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            delegate.present(imagePicker, animated: true, completion: nil)
        })
        
        let openGalleryPhotoAction = UIAlertAction(title: "Choose from Library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            imagePicker.delegate = delegate as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            delegate.present(imagePicker, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            optionMenu.addAction(openCapturePhotoAction)
        }
        optionMenu.addAction(openGalleryPhotoAction)
        optionMenu.addAction(cancelAction)
        optionMenu.popoverPresentationController?.sourceRect = targetFrame
        optionMenu.popoverPresentationController?.sourceView = delegate.view
      
        delegate.present(optionMenu, animated: true, completion: nil)
    }
    
    //MARK: Menu View
    func OpenMenuView(viewController: UIViewController) {
        
        let modalViewController = HomeStoryBoard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        modalViewController.view.isOpaque = false
        
        modalViewController.view.backgroundColor = UIColor.clear
        modalViewController.modalPresentationStyle = .overCurrentContext
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            modalViewController.view.transform = CGAffineTransform(translationX: viewController.view.frame.size.width, y: 0)
        } else {
            modalViewController.view.transform = CGAffineTransform(translationX: -viewController.view.frame.size.width, y: 0)
        }
        
        viewController.view.superview?.insertSubview(modalViewController.view, aboveSubview: viewController.view)
        //viewController.view.frame.size.width
        
        UIView.animate(withDuration: 0.40,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        modalViewController.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { finished in
            viewController.present(modalViewController, animated: false, completion: nil)
        })
    }
    
    //MARK: Set TabBar View:
    func setUpTabBarView() -> UITabBarController {
        
         let vc1 = HomeStoryBoard.instantiateViewController(withIdentifier: "Home_VC") as! Home_VC
         let vc2 = HomeStoryBoard.instantiateViewController(withIdentifier: "ChatListViewController") as! ChatListViewController
         let vc3 = HomeStoryBoard.instantiateViewController(withIdentifier: "DraftsViewController") as! DraftsViewController
         let vc4 = HomeStoryBoard.instantiateViewController(withIdentifier: "MediaViewController") as! MediaViewController
         let vc5 = HomeStoryBoard.instantiateViewController(withIdentifier: "AuditViewController") as! AuditViewController
         let vc6 = HomeStoryBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
         
         let vcTabBarViewController = HomeStoryBoard.instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController
         if kAppDelegate.intViewFlipStatus == 1 {
           vcTabBarViewController?.viewControllers = [vc1, vc2, vc3, vc4, vc5, vc6]
           vcTabBarViewController?.selectedIndex = 0
         } else {
           vcTabBarViewController?.viewControllers = [vc6, vc5, vc4, vc3, vc2, vc1]
           vcTabBarViewController?.selectedIndex = 5
         }
        
        return vcTabBarViewController!
    }
    
    func setUpTabBarView(selectedIndex: Int) -> UITabBarController {
        
        let vc1 = HomeStoryBoard.instantiateViewController(withIdentifier: "Home_VC") as! Home_VC
        let vc2 = HomeStoryBoard.instantiateViewController(withIdentifier: "ChatListViewController") as! ChatListViewController
        let vc3 = HomeStoryBoard.instantiateViewController(withIdentifier: "DraftsViewController") as! DraftsViewController
        let vc4 = HomeStoryBoard.instantiateViewController(withIdentifier: "MediaViewController") as! MediaViewController
        let vc5 = HomeStoryBoard.instantiateViewController(withIdentifier: "AuditViewController") as! AuditViewController
        let vc6 = HomeStoryBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        
        let vcTabBarViewController = HomeStoryBoard.instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController
        if kAppDelegate.intViewFlipStatus == 1 {
            vcTabBarViewController?.viewControllers = [vc1, vc2, vc3, vc4, vc5, vc6]
            vcTabBarViewController?.selectedIndex = selectedIndex
        } else {
            vcTabBarViewController?.viewControllers = [vc6, vc5, vc4, vc3, vc2, vc1]
            vcTabBarViewController?.selectedIndex = selectedIndex
        }
        
        return vcTabBarViewController!
    }
    
    //MARK: Set TextView Underline
    func setTextViewUnderline(textField: UITextView)  {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: textField.frame.height - 1, width: textField.frame.width, height: 1.0)
        bottomLine.backgroundColor = TextObjects.themeColorGray.cgColor
        textField.layer.addSublayer(bottomLine)
    }
    
    //MARK: Set TextField Underline
    func setTextFieldUnderline(textField: UITextField)  {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: textField.frame.height - 1, width: textField.frame.width, height: 1.0)
        bottomLine.backgroundColor = TextObjects.themeColorGray.cgColor
        textField.borderStyle = UITextBorderStyle.none
        textField.layer.addSublayer(bottomLine)
    }
    
    //MARK: Set Button Underline
    func setButtonUnderline(textField: UIButton)  {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: textField.frame.height - 1, width: textField.frame.width, height: 1.0)
        bottomLine.backgroundColor = TextObjects.themeColorGray.cgColor
        textField.layer.addSublayer(bottomLine)
    }
    
    //MARK: Button Border and Backgrounds :
    func setGreenBorder(button: UIButton) {
        button.layer.borderColor = TextObjects.themeColorGreen.cgColor
        button.layer.borderWidth = 1.0
        button.setTitleColor(TextObjects.themeColorGreen, for: UIControlState.normal)
        button.clipsToBounds = true
    }
    
    func setGrayBorder(button: UIButton) {
        button.layer.borderColor = TextObjects.themeColorGray.cgColor
        button.layer.borderWidth = 1.0
        button.setTitleColor(UIColor.black, for: UIControlState.normal)
        button.clipsToBounds = true
    }
    
    func setWhiteBackground(button: UIButton) {
        button.backgroundColor = CustomColors.Blue
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
    }
    
    func setClearBackground(button: UIButton) {
        button.backgroundColor = UIColor.clear
        button.setTitleColor(CustomColors.Blue, for: UIControlState.normal)
    }
    
    func setButtonBorderAndText(button: UIButton, borderColor: UIColor, textColor: UIColor, backgroundColor: UIColor) {
        button.layer.borderColor = borderColor.cgColor
        button.layer.borderWidth = 1.0
        button.setTitleColor(textColor, for: UIControlState.normal)
        button.backgroundColor = backgroundColor
        button.clipsToBounds = true
    }
    
    func initializeDictWithUserId() -> NSMutableDictionary {
        
        let dictP = NSMutableDictionary()
        dictP.setValue(UserProfile.id, forKey: "id")
        dictP.setValue(UserProfile.authToken, forKey: "auth_token")
        dictP.setValue(kAppDelegate.strDeviceToken, forKey: "devicetoken")
        dictP.setValue(ValidationConstants.DeviceType, forKey: "platform")
        dictP.setValue(kAppDelegate.strLanguageName, forKey: "lang")
        
        return dictP
    }
    
    func logoutAndClearAllSessionData() {
        var isRemember = false
        var email = ""
        var password = ""
        
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key.description)
        }
        UserProfile = UserProfileModel.sharedInstance()
      
        let vc1 = MainStoryBoard.instantiateViewController(withIdentifier: "Login_VC") as! Login_VC
        let navigationController = kAppDelegate.window?.rootViewController as! UINavigationController
        navigationController.viewControllers = [vc1]
       // navigationController.isNavigationBarHidden = true
        kAppDelegate.window?.rootViewController = navigationController
    }
    
    func setTableViewCellHeight(strMsg: String, andFont withSize: CGFloat) -> CGFloat {
        var cellHeight = CGFloat(0)
        let textRect: CGRect = MF.decodeDataIntoString(strMsg: strMsg).boundingRect(with: CGSize(width: ScreenSize.SCREEN_WIDTH - 60, height: 500), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: withSize)], context: nil)
        let messageSize: CGSize  = textRect.size
       // print("messageSize = \(messageSize.height)")
        if(messageSize.height > 200 && messageSize.height <= 300 ) {
            cellHeight = cellHeight + messageSize.height + 15
        } else if(messageSize.height > 50 && messageSize.height <= 100 ) {
            cellHeight = cellHeight + messageSize.height
        } else if (messageSize.height > 100 && messageSize.height <= 200 ) {
            cellHeight = cellHeight + messageSize.height - 5
        } else if (messageSize.height > 30 && messageSize.height <= 50 ) {
            cellHeight = cellHeight + messageSize.height
        } else {
            cellHeight = cellHeight + messageSize.height 
        }
        return cellHeight
    }
    
    func addShadowToView(viewShadow: UIView, andRadius radius: Int) {
        viewShadow.layer.shadowColor = UIColor.black.cgColor
        viewShadow.layer.shadowOpacity = 1
        viewShadow.layer.shadowOffset = CGSize.zero
        viewShadow.layer.shadowRadius = CGFloat(radius)
    }
    
    func addBorderAndCornerRadius(view: UIView, andRadius radius: Int) {
        view.layer.cornerRadius = CGFloat(radius)
        view.clipsToBounds = false
        view.layer.masksToBounds = false
    }
    
    func setUpNotificationArray() -> NSMutableArray {
        let arr = NSMutableArray()
        arr.add(SettingContent.AssignAudit)
        arr.add(SettingContent.NewAudit)
        arr.add(SettingContent.SyncAudit)
        return arr
    }
    
    func setUpPageArray() -> NSMutableArray {
        let arr = NSMutableArray()
        arr.add(SettingContent.AboutUs)
        arr.add(SettingContent.TermsConditions)
        arr.add(SettingContent.Standars)
        arr.add(SettingContent.News)
        return arr
    }
    
    func setUpContactUsArray() -> NSMutableArray {
        let arr = NSMutableArray()
        arr.add(SettingContent.ContactUs)
        arr.add(SettingContent.ChangePassword)
        arr.add(SettingContent.Help)
        arr.add(SettingContent.Logout)
        return arr
    }
    
    func setUpSettingContent() -> NSMutableArray {
        let arrSetting = NSMutableArray()
        
        let d1 = NSMutableDictionary()
        d1.setValue(SettingContent.Sections.PushNotification, forKey: "SectionName")
        d1.setValue(setUpNotificationArray(), forKey: "SectionArray")
        
        let d2 = NSMutableDictionary()
        d2.setValue(SettingContent.Sections.Pages, forKey: "SectionName")
        d2.setValue(setUpPageArray(), forKey: "SectionArray")
        
        let d3 = NSMutableDictionary()
        d3.setValue(SettingContent.Sections.ContactUs, forKey: "SectionName")
        d3.setValue(setUpContactUsArray(), forKey: "SectionArray")
        
        arrSetting.add(d1)
        arrSetting.add(d2)
        arrSetting.add(d3)
        
        return arrSetting
    }
    
    func setUpProfileContent() -> NSMutableArray {
        let arr = NSMutableArray()
        
        let d1 = NSMutableDictionary()
        d1.setValue(ProfileContent.UpdateDetail, forKey: "name")
        d1.setValue("user_icon", forKey: "icon")
        arr.add(d1)
        
        let d2 = NSMutableDictionary()
        d2.setValue(ProfileContent.ChatAdmin, forKey: "name")
        d2.setValue("chat_icon", forKey: "icon")
        arr.add(d2)
        
        let d3 = NSMutableDictionary()
        d3.setValue(ProfileContent.ShareApp, forKey: "name")
        d3.setValue("share_icon", forKey: "icon")
        arr.add(d3)
        
        let d4 = NSMutableDictionary()
        d4.setValue(ProfileContent.HowUse, forKey: "name")
        d4.setValue("help_icon1", forKey: "icon")
        arr.add(d4)
        
        return arr
    }
    
    func setUpMenuContent() -> NSMutableArray {
        
        let arr = NSMutableArray()
        
        let d1 = NSMutableDictionary()
        d1.setValue(MenuContent.Account, forKey: "name")
        d1.setValue("account_icon", forKey: "icon")
        arr.add(d1)
        
        let d2 = NSMutableDictionary()
        d2.setValue(MenuContent.History, forKey: "name")
        d2.setValue("history_icon", forKey: "icon")
        arr.add(d2)
        
        let d3 = NSMutableDictionary()
        d3.setValue(MenuContent.Report, forKey: "name")
        d3.setValue("report_icon", forKey: "icon")
        arr.add(d3)
        
        let d4 = NSMutableDictionary()
        d4.setValue(MenuContent.Setting, forKey: "name")
        d4.setValue("setting_icon", forKey: "icon")
        //arr.add(d4)
        
        let d5 = NSMutableDictionary()
        d5.setValue(MenuContent.Help, forKey: "name")
        d5.setValue("help_icon", forKey: "icon")
        arr.add(d5)
        
        let d6 = NSMutableDictionary()
        d6.setValue(MenuContent.Logout, forKey: "name")
        d6.setValue("logout_icon", forKey: "icon")
        arr.add(d6)
        
        return arr
    }
    
    func setAuditStatus(intStatus: Int) -> UIColor {
        switch intStatus {
        case 1:
            return CustomColors.themeColorGreen
        case 2:
            return UIColor.yellow
        case 3:
            return CustomColors.Orange
        default:
            print("Invalid setAuditStatus")
        }
        return UIColor.clear
    }
    
    //MARK: Check INternet Connection
    
    func isInternetAvailable() -> Bool   {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
}
