//
//  MediaViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 24/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MediaViewController: UIViewController {

    @IBOutlet weak var lbl_NoRecord: UILabel!
    @IBOutlet weak var colView: UICollectionView!
    var arrAuditList = [MyAuditListModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
//        if obSqlite.getAuditList(status: AuditStatus.Pending, fetchType: "media").count > 0 {
//                arrAuditList = obSqlite.getAuditList(status: AuditStatus.Pending, fetchType: "media")
//            colView.reloadData()
//        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        kAppDelegate.currentViewController = self
        arrAuditList = obSqlite.getAuditList(status: AuditStatus.Pending, fetchType: "media")
        if arrAuditList.count == 0 {
            lbl_NoRecord.alpha = 1.0
            colView.alpha = 0.0
        } else {
            lbl_NoRecord.alpha = 0.0
            colView.alpha = 1.0
        }
        colView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpLanguageSetting() {
        view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
     //   lbl_Title.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
    
}

extension MediaViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (ScreenSize.SCREEN_WIDTH / 3) - 16, height: DeviceType.IS_PHONE ? 150 : 260)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return arrAuditList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaViewCell", for: indexPath) as! MediaViewCell
        cell.setMediaData(strImg: "", strName: arrAuditList[indexPath.row].audit_title!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MediaGalleryStoryBoard.instantiateViewController(withIdentifier: "LocationMediaViewController") as? LocationMediaViewController
        vc?.intAuditId = arrAuditList[indexPath.row].audit_id!
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

