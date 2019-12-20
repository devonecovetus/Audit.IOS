//
//  SubLocationViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 17/01/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class SubLocationMediaViewController: UIViewController {

    var arrSubLocationMedia = [BuiltAuditSubLocationModel]()
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
         arrSubLocationMedia = obSqlite.getBuiltAuditSubLocationList(auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, subFolderId: intSubFolderId)
        colView.reloadData()
    }
    
    func setUpLanguageSetting() {
        view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        //   lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
    
    // MARK: - Navigation
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SubLocationMediaViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (ScreenSize.SCREEN_WIDTH / 3) - 16, height: 260)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrSubLocationMedia.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaViewCell", for: indexPath) as! MediaViewCell
        cell.setMediaData(strImg: "" , strName: arrSubLocationMedia[indexPath.row].subLocationName!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MediaGalleryStoryBoard.instantiateViewController(withIdentifier: "SubLocationSubFolderMediaViewController") as? SubLocationSubFolderMediaViewController
        vc?.intAuditId = intAuditId
        vc?.intLocationId = arrSubLocationMedia[indexPath.row].locationId!
        vc?.intSubLocationId = arrSubLocationMedia[indexPath.row].subLocationId!
        vc?.intFolderId = arrSubLocationMedia[indexPath.row].folderId!
        vc?.intSubFolderId = arrSubLocationMedia[indexPath.row].subFolderId!
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
