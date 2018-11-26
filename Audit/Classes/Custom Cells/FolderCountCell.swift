//
//  FllderCountCell.swift
//  Audit
//
//  Created by Rupesh Chhabra on 03/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol FolderCountDelegate {
    func increaseCount(index: Int)
    func decreaseCount(index: Int)
    func addFolderCount(index:Int)
}

class FolderCountCell: UITableViewCell {
    
    var delegate: FolderCountDelegate?
    var indexValue = Int()
    
    @IBOutlet weak var btn_Add: UIButton!
    @IBOutlet weak var btn_Decrease: UIButton!
    
    @IBAction func btn_Decrease(_ sender: Any) {
        delegate?.decreaseCount(index: indexValue)
    }
    
    @IBAction func btn_Add(_ sender: Any) {
        delegate?.addFolderCount(index: indexValue)
    }
    @IBAction func btn_Increase(_ sender: Any) {
        delegate?.decreaseCount(index: indexValue)
    }
    @IBOutlet weak var btn_Increase: UIButton!
    @IBOutlet weak var tv_Description: UITextView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Count: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
