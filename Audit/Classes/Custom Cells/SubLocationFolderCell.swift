//
//  SubLocationFolderCell.swift
//  Audit
//
//  Created by Rupesh Chhabra on 12/12/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol SubLocationFolderDelegate {
    func movetoNext(index: Int)
}

class SubLocationFolderCell: UITableViewCell {

    var intIndex: Int = Int()
    var delegate: SubLocationFolderDelegate?
    
    @IBAction func btn_Next(_ sender: Any) {
        delegate?.movetoNext(index: intIndex)
    }
    @IBOutlet weak var lbl_Counter: DesignableLabel!
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
        lbl_Counter.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        if kAppDelegate.strLanguageName == LanguageType.Arabic {
            lbl_Title.textAlignment = NSTextAlignment.right
        }
    }
}
