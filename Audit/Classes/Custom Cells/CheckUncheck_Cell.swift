//
//  CheckUncheck_Cell.swift
//  Audit
//
//  Created by Mac on 12/26/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class CheckUncheck_Cell: UITableViewCell {
    
    var intIndex = Int()
    
    @IBOutlet weak var btn_CheckUnCheck: UIButton!
    @IBOutlet weak var img_Checkuncheck: UIImageView!
    @IBOutlet weak var lbl_Title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpLanguageSetting()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setUpLanguageSetting() {
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        img_Checkuncheck.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            lbl_Title.textAlignment = .right
        }
        
    }
    
    func setCheckUnCheckData(obAns: AnswerTypeModel) {
        lbl_Title.text = obAns.strAnswer
        if obAns.status == 0 {
            img_Checkuncheck.image = UIImage(named: "uncheck_icon")
        } else {
            img_Checkuncheck.image = UIImage(named: "check_icon")
        }
    }
    
    func setRadioData(obAns: AnswerTypeModel) {
        lbl_Title.text = obAns.strAnswer
        if obAns.status == 0 {
            img_Checkuncheck.image = UIImage(named: "radio_unselected")
        } else {
            img_Checkuncheck.image = UIImage(named: "radio_selected")
        }
    }
    
    func setPlaceHolderRadioData(obAns: AnswerTypeModel) {
        lbl_Title.text = NSLocalizedString("SelectOption", comment: "")
        if obAns.status == 0 {
            img_Checkuncheck.image = UIImage(named: "radio_unselected")
        } else {
            img_Checkuncheck.image = UIImage(named: "radio_selected")
        }
    }
    
    func setDropDownData(obAns: AnswerTypeModel) {
        
        lbl_Title.text = obAns.strAnswer
        img_Checkuncheck.image = UIImage()
    }
    
    func setPlaceHolderDropDownData() {
        lbl_Title.text = NSLocalizedString("SelectOption", comment: "")
        img_Checkuncheck.image = UIImage()
    }
}
