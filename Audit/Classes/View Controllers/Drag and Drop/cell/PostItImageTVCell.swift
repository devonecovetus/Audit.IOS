//
//  PostItImageTVCell.swift
//  Kanban
//

import UIKit

class PostItImageTVCell: UITableViewCell {
    
    // OUTLETs
    @IBOutlet weak var imagem: UIImageView!
    
    func awakeFromNib(image_Post_It: UIImage) {
        super.awakeFromNib()
        // Initialization code
        self.imagem.image = image_Post_It
        self.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

