//
//  SubLocationCounterCell.swift
//  Audit
//
//  Created by Rupesh Chhabra on 23/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class SubLocationCounterCell: UICollectionViewCell {
    @IBOutlet weak var lbl_Count: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpLanguageSetting()
    }
    
    func setSubLocationCounterData() {
        
    }
    
    func setUpLanguageSetting() {
        lbl_Count.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
    
}
