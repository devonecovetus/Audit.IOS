//
//  FolderViewCell.swift
//  Audit
//
//  Created by Rupesh Chhabra on 23/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol FolderOperationDelegate {
    func viewFolderDetails(index: Int)
    func archiveFolder(index: Int)
    func editFolder(index: Int)
}

class FolderViewCell: UITableViewCell {

    var intIndex = Int()
    var delegate: FolderOperationDelegate?
    
    @IBOutlet weak var imgView_Status: UIImageView!
    @IBOutlet weak var lbl_WorkStatus: UILabel!
    @IBOutlet weak var view_WorkStatus: UIView!
    
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Description: UILabel!
    @IBOutlet weak var btn_Edit: UIButton!
    @IBOutlet weak var btn_View: UIButton!
    @IBOutlet weak var btn_Archive: UIButton!

    @IBOutlet weak var colView_SLCount: UICollectionView!
    
    var arrSubLocationCountList = NSMutableArray()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func btn_Archive(_ sender: Any) {
        delegate?.editFolder(index: intIndex)
    }
    @IBAction func btn_View(_ sender: Any) {
        delegate?.viewFolderDetails(index: intIndex)
    }
    @IBAction func btn_Edit(_ sender: Any) {
        delegate?.editFolder(index: intIndex)
    }
}

extension FolderViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 76, height: 76)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      //  return arrSubLocationCountList.count
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubLocationCounterCell", for: indexPath) as! SubLocationCounterCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
