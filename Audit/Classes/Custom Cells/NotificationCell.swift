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
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setNotificationData(obNot: NotificationModel) {
        
        if obNot.type == "Audit"{
            imgView_Type.sd_setImage(with: URL(string: obNot.photo!), placeholderImage: UIImage.init(named: ""))
        } else if obNot.type == "Report"{
            imgView_Type.image = UIImage.init(named: "icon_pdf")
        } else if obNot.type == "Message"{
            imgView_Type.image = UIImage.init(named: "icon_message")
        }
        
        lbl_Count.text = obNot.notifyCount
        let datestr = dc.getTimeDifferenceBetweenTwoDates(strMsgDate: obNot.date!)
        if datestr != ""{
            print(datestr)
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
