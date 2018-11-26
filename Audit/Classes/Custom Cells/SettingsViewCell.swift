//
//  SettingsViewCell.swift
//  Audit
//
//  Created by Rupesh Chhabra on 25/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol SettingsDelegate {
    func setNotificationOnOff(index: Int)
}

class SettingsViewCell: UITableViewCell {

    @IBAction func btn_Logout(_ sender: Any) {
    }
    
    @IBOutlet weak var btn_Logout: UIButton!
    @IBOutlet weak var imgView_Arrow: UIImageView!
    @IBOutlet weak var lbl_Name: UILabel!
    
    @IBAction func btn_Switch(_ sender: Any) {
        
    }
    @IBOutlet weak var btn_Switch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        setUpLanguageSetting()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var cellIndex: IndexPath? {
        didSet {
            let section = (MF.setUpSettingContent()[(cellIndex?.section)!] as! NSDictionary)
            lbl_Name.text = (section["SectionArray"] as! NSArray)[(cellIndex?.row)!] as? String
            
            if lbl_Name.text == SettingContent.Logout {
                btn_Logout.alpha = 1.0
            } else {
                btn_Logout.alpha = 0.0
            }
            
           setSectionViewSetting(strSectionName: section["SectionName"] as! String)
            
            
        }
    }
    
    private func setSectionViewSetting(strSectionName: String) {
        imgView_Arrow.alpha = 0.0
        btn_Switch.alpha = 0.0
      //  btn_Logout.alpha = 0.0
        if strSectionName == SettingContent.Sections.PushNotification {
            btn_Switch.alpha = 1.0
            
        } else if strSectionName == SettingContent.Sections.Pages {
            imgView_Arrow.alpha = 1.0
        } else if strSectionName == SettingContent.Sections.ContactUs {
            
        }
    }
    
   private func setUpLanguageSetting() {
        //self.contentView.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Name.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        btn_Switch.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
             lbl_Name.textAlignment = NSTextAlignment.right
        }        
    }
    
}
