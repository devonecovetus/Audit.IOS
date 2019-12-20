//
//  SubLocationSubFolderMediaViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 21/01/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class SubLocationSubFolderMediaViewController: UIViewController {

    var arrSubLocationSubFolderMedia = [SubLocationSubFolderModel]()
    var intAuditId = Int()
    var intLocationId = Int()
    var intFolderId = Int()
    var intSubFolderId = Int()
    var intSubLocationId = Int()
    @IBOutlet weak var colView: UICollectionView!
    @IBOutlet weak var lbl_Title: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        kAppDelegate.currentViewController = self
        getSubLocationSubFolderMedia()
    }
    
    
    func getSubLocationSubFolderMedia() {
         arrSubLocationSubFolderMedia = obSqlite.getSubLocationSubFolderList(auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, sub_locationId: intSubLocationId, subFolderId: intSubFolderId)
        colView.reloadData()
    }

    
    // MARK: - Navigation
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
 
    func setUpLanguageSetting() {
        view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        //   lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }

}

extension SubLocationSubFolderMediaViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (ScreenSize.SCREEN_WIDTH / 3) - 16, height: 260)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrSubLocationSubFolderMedia.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaViewCell", for: indexPath) as! MediaViewCell
        cell.setMediaData(strImg: "" , strName: arrSubLocationSubFolderMedia[indexPath.row].subFolderName!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MediaGalleryStoryBoard.instantiateViewController(withIdentifier: "SubLocationSubMediaViewController") as? SubLocationSubMediaViewController
        vc?.intAuditId = intAuditId
        vc?.intLocationId = arrSubLocationSubFolderMedia[indexPath.row].locationId!
        vc?.intSubLocationId = arrSubLocationSubFolderMedia[indexPath.row].subLocationId!
        vc?.intFolderId = arrSubLocationSubFolderMedia[indexPath.row].folderId!
        vc?.intSubFolderId = arrSubLocationSubFolderMedia[indexPath.row].subFolderId!
        vc?.intSubLocationSubFolderId = arrSubLocationSubFolderMedia[indexPath.row].incId!
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
