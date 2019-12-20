//
//  SubLocationSubMediaViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 17/01/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class SubLocationSubMediaViewController: UIViewController {

    var arrSubLocationSubMedia = [SubLocationSubFolder_PhotoModel]()
    var intAuditId = Int()
    var intLocationId = Int()
    var intFolderId = Int()
    var intSubFolderId = Int()
    var intSubLocationSubFolderId = Int()
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
        arrSubLocationSubMedia = obSqlite.getPhotosSubLocationSubFolder(auditId: intAuditId, locationId: intLocationId, folderId: intFolderId, subfolderId: intSubFolderId, sub_locationId: intSubLocationId, sub_locationsub_folderId: intSubLocationSubFolderId, main_photo: 0, fetchType: "media")
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

extension SubLocationSubMediaViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (ScreenSize.SCREEN_WIDTH / 3) - 16, height: 260)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrSubLocationSubMedia.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaViewCell", for: indexPath) as! MediaViewCell
        cell.setMediaData(strImg:arrSubLocationSubMedia[indexPath.row].imgName! , strName: arrSubLocationSubMedia[indexPath.row].subFolderName!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let strImg = arrSubLocationSubMedia[indexPath.row].imgName!
        if strImg.count > 0 {
            DispatchQueue.global(qos: .background).async {
                let obFM = FileDownloaderManager()
                let image_download = UIImage(contentsOfFile: obFM.getAuditImagePath(imageName: strImg))
                DispatchQueue.main.async {
                    let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT))
                    imgView.image = image_download
                    SJAvatarBrowser.showImage(imgView)
                    
                }
            }
        }
    }
}
