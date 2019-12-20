//
//  MediaViewCell.swift
//  Audit
//
//  Created by Rupesh Chhabra on 16/01/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit


class MediaViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lbl_Name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpLanguageSetting()
    }
    
    func setUpLanguageSetting() {
         lbl_Name.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
         imgView.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
    
    func setMediaData(strImg: String, strName: String = "") {
        
        if strImg.count > 0 {
            DispatchQueue.global(qos: .background).async {
                let obFM = FileDownloaderManager()
                let image_download = UIImage(contentsOfFile: obFM.getAuditImagePath(imageName: strImg))
                DispatchQueue.main.async {
                    self.imgView.image = image_download
                    self.lbl_Name.text = strName
                }
            }
        } else {
            DispatchQueue.main.async {
                self.imgView.image = UIImage(named: "folder_icon0")
                self.lbl_Name.text = strName
            }
        }
    }

    
}
