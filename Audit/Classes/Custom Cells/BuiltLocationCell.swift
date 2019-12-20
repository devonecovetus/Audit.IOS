//
//  BuiltLocationCell.swift
//  Audit
//
//  Created by Rupesh Chhabra on 15/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol BuiltLocationDelegate {
    func increaseValue(index: Int)
    func decreaseValue(index: Int)
    func deleteItem(index: Int, indexPath: IndexPath)
}

class BuiltLocationCell: UICollectionViewCell {
    var index = Int()
    var cellIndex = IndexPath()
    var delegate: BuiltLocationDelegate?
    @IBOutlet weak var btn_Down: UIButton!
    @IBOutlet weak var btn_Up: UIButton!
    @IBOutlet weak var btn_DeleteItem: UIButton!
    @IBOutlet weak var lbl_Name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpLanguageSetting() 
    }
    
    func setUpLanguageSetting() {
        lbl_Name.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
    
    //MARK: Button Actions:
    @IBAction func btn_Up(_ sender: Any) {
        delegate?.increaseValue(index: index)
    }
    
    @IBAction func btn_Down(_ sender: Any) {
        delegate?.decreaseValue(index: index)
    }
    
    @IBAction func btn_DeleteItem(_ sender: Any) {
        delegate?.deleteItem(index: index, indexPath: cellIndex)
    }
    
}
