//
//  AuditOverView+CollectionView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 05/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension AuditOverViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160 , height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFiles!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FileDownloaderCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileDownloaderCell", for: indexPath) as! FileDownloaderCell
        cell.setFileData(file: arrFiles![indexPath.row] as! String)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        downloadFilesFromList(intIndex: indexPath.row)
    }
    
    @objc func downloadFiles() {
        let obFDM: FileDownloaderManager? = FileDownloaderManager()
        obFDM?.downloadFileDataInBackground(arrParam: arrP)
    }
    
    func downloadFilesFromList(intIndex: Int) {
        var strFilePath = arrFiles?[intIndex] as! String
        let arrFP = strFilePath.components(separatedBy: "/")
        let strFileName = arrFP.last
        let arrExt = strFileName?.components(separatedBy: ".")
        view_Files.alpha = 0.0
        
        strFilePath = strFilePath.replacingOccurrences(of: " ", with: "%20")
        arrP = [strFilePath, (arrExt?.first)!, (arrExt?.last)!]
        
        let obFDM: FileDownloaderManager?  = FileDownloaderManager()
        if obFDM?.checkFileExistOrNot(path: strFilePath, AndName: (arrExt?.first)!, AndFileExtension: (arrExt?.last)!).0 == true {
            //if obFDM?.checkMediaFileExistOrNot(arrParam: arrP) == true {
            /// FIle Already Downloaded, so need to open the file
            if (arrExt?.last)! == FileExtension.PDF || (arrExt?.last)! == FileExtension.XLSX || (arrExt?.last)! == FileExtension.DOC || (arrExt?.last)! == FileExtension.DOCX || (arrExt?.last)! == FileExtension.EXCEL || (arrExt?.last)! == FileExtension.XLS {
                /// File exist
                
                ///working
                if let url = URL(string: strFilePath) {
                    UIApplication.shared.open(url, options: [:])
                }
            } else {
                let imgView: UIImageView? = UIImageView(frame: CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT))
                imgView?.sd_setImage(with: URL(string: strFilePath)) { (imgP, errorI, cacheType, imgUrl) in
                    imgView?.image = imgP
                    if imgView?.image != nil {
                        SJAvatarBrowser.showImage(imgView)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                SVProgressHUD.show(withStatus: "Downloading....")
            }
            self.performSelector(inBackground: #selector(self.downloadFiles), with: nil)
        }
    }
}
