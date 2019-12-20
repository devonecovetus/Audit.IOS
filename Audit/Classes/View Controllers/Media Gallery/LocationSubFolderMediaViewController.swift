//
//  MediaFilesViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 17/01/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class LocationSubFolderMediaViewController: UIViewController {

    @IBOutlet weak var lbl_TItle: UILabel!
   
    var arrLocationSubFolderMedia = [LocationSubFolderListModel]()
    var intAuditId = Int()
    var intLocationId = Int()
    var intFolderId = Int()
    @IBOutlet weak var colView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        kAppDelegate.currentViewController = self
        getLocationSubFolderMedia(auditId: intAuditId, locationId: intLocationId)
    }
    
    func setUpLanguageSetting() {
        view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
    
    func getLocationSubFolderMedia(auditId: Int, locationId: Int) {
        arrLocationSubFolderMedia = obSqlite.getLocationSubFolderList(locationId: intLocationId, auditId: intAuditId, folderId: intFolderId)
        colView.reloadData()
    }
    
    // MARK: - Button Action:

    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension LocationSubFolderMediaViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (ScreenSize.SCREEN_WIDTH / 3) - 16, height: 260)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrLocationSubFolderMedia.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaViewCell", for: indexPath) as! MediaViewCell
        cell.setMediaData(strImg:arrLocationSubFolderMedia[indexPath.row].photo! , strName: arrLocationSubFolderMedia[indexPath.row].subFolderName!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MediaGalleryStoryBoard.instantiateViewController(withIdentifier: "SubLocationMediaViewController") as? SubLocationMediaViewController
        vc?.intAuditId = intAuditId
        vc?.intLocationId = arrLocationSubFolderMedia[indexPath.row].locationId!
        vc?.intFolderId = arrLocationSubFolderMedia[indexPath.row].folderId!
        vc?.intSubFolderId = arrLocationSubFolderMedia[indexPath.row].incId!
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
