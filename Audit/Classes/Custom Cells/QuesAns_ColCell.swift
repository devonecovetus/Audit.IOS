//
//  QuesAns_ColCell.swift
//  Audit
//
//  Created by Mac on 12/17/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol PhotoCollectionDelegate {
    func deleteClick(index: Int)
    func addphotoClick(index: Int)
}

class QuesAns_ColCell: UICollectionViewCell {
    @IBOutlet weak var img_photo: UIImageView?
    @IBOutlet weak var lbl_question: UILabel!
    @IBOutlet weak var btn_DeleteItem: UIButton!
    
    var delegate: PhotoCollectionDelegate?
    var intIndex: Int = Int()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpLanguageSetting()
    }
    
    func setUpLanguageSetting() {
        if lbl_question != nil {
            lbl_question.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        }
        if img_photo != nil {
            img_photo?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        }
    }
    
    func setphoto(filename: String) {
        
        if filename == "" {
            img_photo?.image = UIImage(named: "bg_gallery")
            let tapGestureRecognizer11 = UITapGestureRecognizer(target: self, action: #selector(self.addphoto(_:)))
            tapGestureRecognizer11.numberOfTapsRequired = 1
            img_photo?.addGestureRecognizer(tapGestureRecognizer11)
        } else {
            let obFM: FileDownloaderManager? = FileDownloaderManager()
            let image_download = UIImage(contentsOfFile: (obFM?.getAuditImagePath(imageName:filename))!)
            img_photo?.image = image_download
            let tapGestureRecognizer11 = UITapGestureRecognizer(target: self, action: #selector(self.showAvatar(_:)))
            tapGestureRecognizer11.numberOfTapsRequired = 1
            img_photo?.addGestureRecognizer(tapGestureRecognizer11)
        }
        
    }
    
    @IBAction func addphoto(_ sender: UITapGestureRecognizer) {
        delegate?.addphotoClick(index: intIndex)
    }
    
    @IBAction func showAvatar(_ sender: UITapGestureRecognizer) {
        let imgview = sender.view as! UIImageView
        if imgview.image != nil {
            SJAvatarBrowser.showImage(sender.view as? UIImageView)
        }
    }
    
    @IBAction func Imageclick(_ sender: Any) {
        delegate?.deleteClick(index: intIndex)
    }
}
