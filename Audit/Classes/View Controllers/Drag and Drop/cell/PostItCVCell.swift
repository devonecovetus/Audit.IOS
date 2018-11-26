//
//  PostItCVCell.swift
//  Audit
//
//  Created by Rupesh Chhabra on 26/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol PostItCVDelegate {
    func increaseValue(index: Int)
    func decreaseValue(index: Int)
    func deleteItem(index: Int, indexPath: IndexPath)
}

class PostItCVCell: UICollectionViewCell {
    
    var index = Int()
    var cellIndex = IndexPath()
    var delegate: PostItCVDelegate?
    @IBOutlet weak var btn_Down: UIButton!
    @IBOutlet weak var btn_Up: UIButton!
    @IBOutlet weak var btn_DeleteItem: UIButton!
    @IBOutlet weak var lbl_Name: UILabel!
    
    func awakeFromNib(conteudo_Post_It: String) {
        super.awakeFromNib()
        btn_Up.alpha = 0.0
        btn_Down.alpha = 0.0
        
        self.lbl_Name.text = conteudo_Post_It
        self.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
    }

    //MARK: Button Actions:
    @IBAction func btn_Up(_ sender: Any) {
        print("self tag = \(self.tag)")
        delegate?.increaseValue(index: index)
    }
    
    @IBAction func btn_Down(_ sender: Any) {
        delegate?.decreaseValue(index: index)
    }
    
    @IBAction func btn_DeleteItem(_ sender: Any) {
        delegate?.deleteItem(index: index, indexPath: cellIndex)
    }
}
