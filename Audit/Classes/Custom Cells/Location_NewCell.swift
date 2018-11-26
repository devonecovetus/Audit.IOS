//
//  Location_NewCell.swift
//  Audit
//
//  Created by Mac on 11/19/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol LocationFolderDelegate {
    func editValue(index: Int, indexPath: IndexPath)
    func nextValue(index: Int, indexPath: IndexPath)
}

class Location_NewCell: UITableViewCell {

    var index = Int()
    var indexpath = IndexPath()

    @IBOutlet weak var lbl_Text: UILabel!
    @IBOutlet weak var btn_Edit: UIButton!
    @IBOutlet weak var btn_Arrow: UIButton!
    
    var delegate: LocationFolderDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //MARK: Button Actions:
    @IBAction func btn_edit(_ sender: Any) {
        print("self tag = \(self.tag)")
        delegate?.editValue(index: index, indexPath:indexpath)
    }
    
    @IBAction func btn_next(_ sender: Any) {
        delegate?.nextValue(index: index, indexPath:indexpath)
    }

}
