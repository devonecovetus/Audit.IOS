//
//  LocationCell.swift
//  Audit
//
//  Created by Rupesh Chhabra on 03/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol  LocationDelegate {
    func enableEdit(index: Int)
}

class LocationCell: UITableViewCell {

    var delegate: LocationDelegate?
    var indexValue = Int()
    
    @IBOutlet weak var tf_Count: UITextField!
    @IBOutlet weak var tf_Title: UITextField!
    @IBOutlet weak var btn_Edit: UIButton!
    @IBAction func btn_Edit(_ sender: Any) {
        delegate?.enableEdit(index: indexValue)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension LocationCell: UITextFieldDelegate {
    
}
