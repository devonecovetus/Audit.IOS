//
//  ChatListCell.swift
//  Audit
//
//  Created by Mac on 11/29/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol ChatcellDelegate {
    func msgAction(index: Int, indexPath: IndexPath)
}

class ChatListCell: UITableViewCell {
    
    var index = Int()
    var indexpath = IndexPath()
    var delegate: ChatcellDelegate?
    
    @IBOutlet weak var img_profilepic: UIImageView!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_msg: UILabel!
    @IBOutlet weak var lbl_date: UILabel!

    @IBOutlet weak var btn_msg: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: Button Actions:
    @IBAction func btn_msg(_ sender: Any) {
        print("self tag = \(self.tag)")
        delegate?.msgAction(index: index, indexPath:indexpath)
    }

}
