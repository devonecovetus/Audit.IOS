//
//  NotificationCell.swift
//  Audit
//
//  Created by Rupesh Chhabra on 31/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var lbl_Count: UILabel!
    @IBOutlet weak var imgView_Type: UIImageView!
    @IBOutlet weak var lbl_Time: UILabel!
    @IBOutlet weak var lbl_Day: UILabel!
    @IBOutlet weak var lbl_Type: UILabel!
    @IBOutlet weak var lbl_Title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        // Initialization code
        setUpLanguageSetting()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    private func setUpLanguageSetting() {
        lbl_Count.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        imgView_Type.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Time.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Day.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Type.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)

        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            lbl_Type.textAlignment = NSTextAlignment.right
            lbl_Title.textAlignment = NSTextAlignment.right
        }
    }
    
    func setNotificationData(obNot: NotificationModel) {
        
        if obNot.type == "Audit"{
            imgView_Type.sd_setImage(with: URL(string: obNot.photo!), placeholderImage: UIImage.init(named: "img_user"))
        } else if obNot.type == "Report"{
            imgView_Type.image = UIImage.init(named: "icon_pdf")
        } else if obNot.type == "Chat"{
            imgView_Type.image = UIImage(named: "message_icon")
        }
        
        lbl_Count.text = obNot.notifyCount
        let datestr = dc.getTimeDifferenceBetweenTwoDates(strMsgDate: obNot.date!)
        if datestr != ""{
            //print(datestr)
            let arr = datestr.components(separatedBy: ",")
            lbl_Day.text = arr[0]
            lbl_Time.text = arr[1]
        } else {
            lbl_Day.text = ""
            lbl_Time.text = ""
        }
        lbl_Type.text = obNot.type
        lbl_Title.text = obNot.title
    }
    
}
