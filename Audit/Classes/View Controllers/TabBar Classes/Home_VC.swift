//
//  Home_VC.swift
//  Audit
//
//  Created by Mac on 10/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import iOSPhotoEditor

class Home_VC: UIViewController {
  
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var img_editor: UIImageView!
    @IBOutlet weak var lbl_notifycount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
        self.lbl_notifycount.isHidden = true
        getNotificationCount()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lbl_notifycount.isHidden = true
        getNotificationCount()
    }
    
    func getNotificationCount() {
        /// API code here
        let dictP = NSMutableDictionary()
        dictP.setValue(UserProfile.id, forKey: "id")
        dictP.setValue(UserProfile.authToken, forKey: "auth_token")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.NotifyCount, methodType: 1, forContent: 1, OnView: self, withParameters: dictP, IsShowLoader: false) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
                if (dictJson["response"] as! NSDictionary)["count"] as? Int != 0{
                    self.lbl_notifycount.isHidden = false
                    self.lbl_notifycount.text =  String((dictJson["response"] as! NSDictionary)["count"] as! Int)
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
        let dictP = NSMutableDictionary()
        dictP.setValue(UserProfile.id, forKey: "id")
        dictP.setValue(UserProfile.authToken, forKey: "auth_token")
        
        OB_WEBSERVICE.getWebApiData(webService: WebServiceName.NotifyBellCount, methodType: 1, forContent: 1, OnView: self, withParameters: dictP, IsShowLoader: false) { (dictJson) in
            if dictJson["status"] as? Int == 1 { // Means user logined
                self.lbl_notifycount.isHidden = true
            }
        }
    }
    
    @IBAction func action_image(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.text = NSLocalizedString("TitleHome", comment: "")
    }
    
}

extension Home_VC: PhotoEditorDelegate {

    func doneEditing(image: UIImage) {
        img_editor.image = image
    }

    func canceledEditing() {
        print("Canceled")
    }
}

extension Home_VC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {

        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        picker.dismiss(animated: true, completion: nil)


        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))

        photoEditor.photoEditorDelegate = self

        photoEditor.image = image

        //Colors for drawing and Text, If not set default values will be used
        //        photoEditor.colors = [.red,.blue,.green]

        //Stickers that the user will choose from to add on the image
//        for i in 0...10 {
//            photoEditor.stickers.append(UIImage(named: i.description )!)
//        }

        //To hide controls - array of enum control
        //  photoEditor.hiddenControls = [.crop, .draw, .share]
        photoEditor.hiddenControls = [.share, .save, .sticker]

        present(photoEditor, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
