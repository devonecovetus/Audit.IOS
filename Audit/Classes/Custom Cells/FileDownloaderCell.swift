//
//  FIleDownloaderCell.swift
//  Audit
//
//  Created by Mac on 11/17/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class FileDownloaderCell: UICollectionViewCell {

    @IBOutlet weak var lbl_Name: UILabel!
    @IBOutlet weak var imgView_Item: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setFileData(file: String) {
        
        let arrFP = file.components(separatedBy: "/")
        let strFileName = arrFP.last
        
        let arrExt = strFileName?.components(separatedBy: ".")
        let str_name = arrExt![0]
        
        if str_name.count > 10{
            lbl_Name.text = String(str_name.prefix(10))
        } else {
            lbl_Name.text = str_name
        }
        
        if (arrExt?.last)! == FileExtension.PDF {
            imgView_Item.image = UIImage(named: "pdf")
        } else if (arrExt?.last)! == FileExtension.PNG {
            imgView_Item.image = UIImage(named: "png")
        } else if (arrExt?.last)! == FileExtension.JPEG {
            imgView_Item.image = UIImage(named: "jpg")
        } else if (arrExt?.last)! == FileExtension.JPG {
            imgView_Item.image = UIImage(named: "jpg")
        } else if (arrExt?.last)! == FileExtension.EXCEL {
            imgView_Item.image = UIImage(named: "xls")
        } else if (arrExt?.last)! == FileExtension.XLSX  || (arrExt?.last)! == FileExtension.XLS {
            imgView_Item.image = UIImage(named: "xls")
        } else if (arrExt?.last)! == FileExtension.DOC || (arrExt?.last)! == FileExtension.DOCX {
            imgView_Item.image = UIImage(named: "doc")
        }
        
    }
    
}
