//
//  LocationMediaViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 21/01/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class LocationMediaViewController: UIViewController {
    @IBOutlet weak var lbl_TItle: UILabel!
    @IBOutlet weak var colView: UICollectionView!
    var arrLocationMedia = [LocationModel]()
    var intAuditId = Int()
    var intLocationId = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        getLocationSubFolderListPhotos()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        kAppDelegate.currentViewController = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpLanguageSetting() {
        view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        //   lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
    
    func getLocationSubFolderListPhotos() {
        if intAuditId > 0 {
            arrLocationMedia = obSqlite.getLocationList(isModified: AuditStatus.Pending, auditId: intAuditId)
            colView.reloadData()
        }
        
        //print("arrMediaList = \(arrLocationMedia.count)")
    }
    
    // MARK: - Button Action:
    
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension LocationMediaViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (ScreenSize.SCREEN_WIDTH / 3) - 16, height: 260)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrLocationMedia.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaViewCell", for: indexPath) as! MediaViewCell
        cell.setMediaData(strImg: "", strName: arrLocationMedia[indexPath.row].locationName!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MediaGalleryStoryBoard.instantiateViewController(withIdentifier: "LocationFolderMediaViewController") as? LocationFolderMediaViewController
        vc?.intAuditId = intAuditId
        vc?.intLocationId = arrLocationMedia[indexPath.row].locationId!
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

