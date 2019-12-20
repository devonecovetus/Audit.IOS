//
//  LocationFolderMediaViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 21/01/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class LocationFolderMediaViewController: UIViewController {

    @IBOutlet weak var lbl_TItle: UILabel!
    
    var arrLocationFolderMedia = [LocationFolderModel]()
    var intAuditId = Int()
    var intLocationId = Int()
     @IBOutlet weak var colView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        kAppDelegate.currentViewController = self
        getLocationFolderMedia()
    }
    
    func getLocationFolderMedia() {
        arrLocationFolderMedia = obSqlite.getLocationFolderList(locationId: intLocationId, auditId: intAuditId)
        colView.reloadData()
    }
    
    func setUpLanguageSetting() {
        view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        //   lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
    
    // MARK: - Button Action:
    
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension LocationFolderMediaViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (ScreenSize.SCREEN_WIDTH / 3) - 16, height: 260)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrLocationFolderMedia.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaViewCell", for: indexPath) as! MediaViewCell
        cell.setMediaData(strImg:arrLocationFolderMedia[indexPath.row].photo! , strName: arrLocationFolderMedia[indexPath.row].folderName!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MediaGalleryStoryBoard.instantiateViewController(withIdentifier: "LocationSubFolderMediaViewController") as? LocationSubFolderMediaViewController
        vc?.intAuditId = intAuditId
        vc?.intLocationId = arrLocationFolderMedia[indexPath.row].locationId!
        vc?.intFolderId = arrLocationFolderMedia[indexPath.row].primaryId!
       
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
