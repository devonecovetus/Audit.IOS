//
//  ProfileViewCell.swift
//  Audit
//
//  Created by Rupesh Chhabra on 25/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ProfileViewCell: UITableViewCell {

    @IBOutlet weak var lbl_Name: UILabel!
    @IBOutlet weak var imgView_Item: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setUpLanguageSetting()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var cellIndex: IndexPath? {
        didSet {
            lbl_Name.text = (MF.setUpProfileContent()[(cellIndex?.row)!] as! NSDictionary)["name"] as? String
            let imgName = (MF.setUpProfileContent()[(cellIndex?.row)!] as! NSDictionary)["icon"] as? String
            imgView_Item.image = UIImage(named: imgName!)
        }
    }
    
    func setUpLanguageSetting() {
        lbl_Name.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        imgView_Item.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            lbl_Name.textAlignment = NSTextAlignment.right
        }
    }
}
