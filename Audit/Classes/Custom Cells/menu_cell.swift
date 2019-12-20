//
//  menu_cell.swift
//  Audit
//
//  Created by Mac on 10/15/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class menu_cell: UITableViewCell {

    @IBOutlet weak var img_icons: UIImageView!
    @IBOutlet weak var lbl_title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setUpMenuData(dict: NSDictionary) {
        img_icons.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            lbl_title.textAlignment = NSTextAlignment.right
        }
    
        img_icons.image = UIImage(named: dict["icon"] as! String)
        lbl_title.text = (dict["name"] as? String)
    }
    
}
